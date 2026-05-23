import os
import json
import time
import requests
from bs4 import BeautifulSoup
from tqdm import tqdm
from dotenv import load_dotenv
try:
    from supabase import create_client, Client
    SUPABASE_AVAILABLE = True
except ImportError:
    from postgrest import SyncPostgrestClient
    SUPABASE_AVAILABLE = False
from sentence_transformers import SentenceTransformer

# --- CONFIGURATION ---
CONFIG = {
    "BASE_URL": "https://www.materiamedica.info",
    "START_URL": "https://www.materiamedica.info/en/free-materia-medica-books.php",
    "AUTHORS": [
        {"slug": "james-tyler-kent", "name": "James Tyler Kent"},
        {"slug": "benoit-mure", "name": "Benoit Mure"},
        {"slug": "william-boericke", "name": "William Boericke"},
        {"slug": "john-henry-clarke", "name": "John Henry Clarke"},
        {"slug": "henry-c-allen", "name": "Henry C. Allen"},
        {"slug": "william-boericke-short", "name": "William Boericke (Short)"},
        {"slug": "cyrus-maxwell-boger", "name": "Cyrus Maxwell Boger"},
        {"slug": "adolf-zur-lippe", "name": "Adolf zur Lippe"},
    ],
    "JSON_BACKUP": "scraped_data.json",
    "EMBEDDING_MODEL": "all-MiniLM-L6-v2",
    "BATCH_SIZE": 50,
    "DELAY": 1.5
}

# Load environment variables
load_dotenv()
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")

def get_soup(url):
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
    }
    try:
        response = requests.get(url, headers=headers, timeout=10)
        response.raise_for_status()
        return BeautifulSoup(response.text, 'html.parser')
    except Exception as e:
        print(f"Error fetching {url}: {e}")
        return None

def scrape_step():
    print("\n--- STEP 1: SCRAPING ---")
    all_remedies = []
    scraped_urls = set()
    
    # Load existing progress if any
    if os.path.exists(CONFIG["JSON_BACKUP"]):
        try:
            with open(CONFIG["JSON_BACKUP"], 'r', encoding='utf-8') as f:
                all_remedies = json.load(f)
                scraped_urls = {item["url"] for item in all_remedies}
            print(f"Resuming: found {len(all_remedies)} already scraped remedies.")
        except Exception as e:
            print(f"Could not load backup for resume, starting fresh: {e}")

    for author in tqdm(CONFIG["AUTHORS"], desc="Authors"):
        author_slug = author["slug"]
        index_url = f"{CONFIG['BASE_URL']}/en/materia-medica/{author_slug}/index"
        soup = get_soup(index_url)
        if not soup:
            continue
            
        # Extract remedy links
        links = soup.find_all('a', href=True)
        remedy_links = []
        for link in links:
            href = link['href']
            if f"/en/materia-medica/{author_slug}/" in href and not href.endswith('/index'):
                full_url = CONFIG["BASE_URL"] + href if href.startswith('/') else href
                if full_url not in scraped_urls:
                    remedy_links.append(full_url)
        
        # Remove duplicates
        remedy_links = list(set(remedy_links))
        
        if not remedy_links:
            continue

        for url in tqdm(remedy_links, desc=f"Remedies for {author_slug}", leave=False):
            time.sleep(CONFIG["DELAY"])
            remedy_soup = get_soup(url)
            if not remedy_soup:
                continue
                
            try:
                name = remedy_soup.find('h1').get_text(strip=True) if remedy_soup.find('h1') else "Unknown"
                content_div = remedy_soup.find('div', id='content') or remedy_soup.find('main') or remedy_soup.body
                
                for nav in content_div.find_all(['nav', 'header', 'footer', 'script', 'style']):
                    nav.decompose()
                
                full_text = content_div.get_text(separator='\n', strip=True)
                remedy_slug = url.split('/')[-1]
                
                all_remedies.append({
                    "author_slug": author_slug,
                    "slug": remedy_slug,
                    "name": name,
                    "full_text": full_text,
                    "url": url
                })
                scraped_urls.add(url)
            except Exception as e:
                print(f"Error parsing {url}: {e}")
        
        # Save incrementally after each author
        with open(CONFIG["JSON_BACKUP"], 'w', encoding='utf-8') as f:
            json.dump(all_remedies, f, indent=2, ensure_ascii=False)
                
    print(f"Scraped {len(all_remedies)} remedies. Final save to {CONFIG['JSON_BACKUP']}")
    return all_remedies

def embed_step(data):
    print("\n--- STEP 2: EMBEDDING ---")
    model = SentenceTransformer(CONFIG["EMBEDDING_MODEL"])
    
    for item in tqdm(data, desc="Generating Embeddings"):
        text = item["full_text"]
        # Truncate to first 512 words
        words = text.split()
        if len(words) > 512:
            text = " ".join(words[:512])
            
        embedding = model.encode(text).tolist()
        item["embedding"] = embedding
        
    # Update JSON with embeddings
    with open(CONFIG["JSON_BACKUP"], 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        
    return data

def upload_step(data):
    print("\n--- STEP 3: UPLOADING TO SUPABASE ---")
    if not SUPABASE_URL or not SUPABASE_KEY:
        print("Error: SUPABASE_URL or SUPABASE_KEY not found in .env")
        return
        
    if SUPABASE_AVAILABLE:
        client = create_client(SUPABASE_URL, SUPABASE_KEY)
    else:
        # Use postgrest client directly
        headers = {
            "apikey": SUPABASE_KEY,
            "Authorization": f"Bearer {SUPABASE_KEY}"
        }
        client = SyncPostgrestClient(f"{SUPABASE_URL}/rest/v1", headers=headers)
    
    # 1. Upsert Authors
    authors_data = [{"slug": a["slug"], "name": a["name"]} for a in CONFIG["AUTHORS"]]
    try:
        if SUPABASE_AVAILABLE:
            client.table("authors").upsert(authors_data, on_conflict="slug").execute()
        else:
            client.from_("authors").upsert(authors_data, on_conflict="slug").execute()
        print("Authors upserted.")
    except Exception as e:
        print(f"Error upserting authors: {e}")
        return

    # Get author IDs mapping
    try:
        if SUPABASE_AVAILABLE:
            author_res = client.table("authors").select("id, slug").execute()
        else:
            author_res = client.from_("authors").select("id, slug").execute()
        author_map = {row["slug"]: row["id"] for row in author_res.data}
    except Exception as e:
        print(f"Error fetching authors: {e}")
        return
    
    # 2. Upsert Remedies in batches
    remedies_to_upload = []
    for item in data:
        remedies_to_upload.append({
            "author_id": author_map[item["author_slug"]],
            "slug": item["slug"],
            "name": item["name"],
            "full_text": item["full_text"],
            "url": item["url"],
            "embedding": item["embedding"]
        })
        
    for i in tqdm(range(0, len(remedies_to_upload), CONFIG["BATCH_SIZE"]), desc="Uploading Batches"):
        batch = remedies_to_upload[i:i + CONFIG["BATCH_SIZE"]]
        try:
            if SUPABASE_AVAILABLE:
                client.table("remedies").upsert(batch, on_conflict="author_id, slug").execute()
            else:
                client.from_("remedies").upsert(batch, on_conflict="author_id, slug").execute()
        except Exception as e:
            print(f"Error uploading batch starting at {i}: {e}")
            
    print("Upload complete.")

def verify_step():
    print("\n--- STEP 4: VERIFYING ---")
    if not SUPABASE_URL or not SUPABASE_KEY:
        return
        
    if SUPABASE_AVAILABLE:
        client = create_client(SUPABASE_URL, SUPABASE_KEY)
    else:
        headers = {
            "apikey": SUPABASE_KEY,
            "Authorization": f"Bearer {SUPABASE_KEY}"
        }
        client = SyncPostgrestClient(f"{SUPABASE_URL}/rest/v1", headers=headers)
    
    # Count total rows
    try:
        if SUPABASE_AVAILABLE:
            count_res = client.table("remedies").select("id", count="exact").execute()
        else:
            count_res = client.from_("remedies").select("id", count="exact").execute()
        total = count_res.count if hasattr(count_res, 'count') else len(count_res.data)
        print(f"Total remedies in database: {total}")
    except Exception as e:
        print(f"Error counting remedies: {e}")

    # Similarity search test
    query = "burning stomach pain worse at night"
    model = SentenceTransformer(CONFIG["EMBEDDING_MODEL"])
    query_embedding = model.encode(query).tolist()
    
    try:
        print(f"\nRunning test search for: '{query}'")
        
        if SUPABASE_AVAILABLE:
            res = client.rpc("match_remedies", {
                "query_embedding": query_embedding,
                "match_threshold": 0.5,
                "match_count": 3
            }).execute()
        else:
            # Manual RPC via requests
            rpc_url = f"{SUPABASE_URL}/rest/v1/rpc/match_remedies"
            headers = {
                "apikey": SUPABASE_KEY,
                "Authorization": f"Bearer {SUPABASE_KEY}",
                "Content-Type": "application/json"
            }
            payload = {
                "query_embedding": query_embedding,
                "match_threshold": 0.5,
                "match_count": 3
            }
            rpc_res = requests.post(rpc_url, headers=headers, json=payload)
            rpc_res.raise_for_status()
            res_data = rpc_res.json()
            
            if res_data:
                for i, row in enumerate(res_data):
                    print(f"{i+1}. {row['name']} (by {row.get('author_name', 'Unknown')}) - Similarity: {row.get('similarity', 0):.4f}")
            else:
                print("No matches found.")
            return

        if res.data:
            for i, row in enumerate(res.data):
                print(f"{i+1}. {row['name']} (by {row.get('author_name', 'Unknown')}) - Similarity: {row.get('similarity', 0):.4f}")
        else:
            print("No matches found or 'match_remedies' function not found in Supabase.")
            
    except Exception as e:
        print(f"Similarity search failed: {e}")

def main():
    print("Script started...")
    # Step 1: Scrape
    data = scrape_step()
    
    # Step 2: Embed
    # Only embed if not already embedded
    if data and "embedding" not in data[0]:
        data = embed_step(data)
    
    # Step 3: Upload
    upload_step(data)
    
    # Step 4: Verify
    verify_step()

if __name__ == "__main__":
    main()
