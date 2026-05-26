import requests
from bs4 import BeautifulSoup
import json
import os
import time
import random
import psycopg2
from psycopg2.extras import execute_values
from tqdm import tqdm
from dotenv import load_dotenv

print("FILE EXECUTION STARTED")

# --- CONFIGURATION ---
CONFIG = {
    "BASE_URL": "https://www.materiamedica.info",
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
    "EMBEDDING_MODEL": "pritamdeka/S-PubMedBert-MS-MARCO",
    "BATCH_SIZE": 50,
    "DELAY": 3.0
}

# Load environment variables
load_dotenv()
# Format: postgresql://user:password@host:port/dbname
# For your local setup: postgresql://postgres:123@localhost:5432/Materia-Medica
DB_URL = os.getenv("DATABASE_URL") 

def get_soup(url):
    time.sleep(random.uniform(CONFIG["DELAY"], CONFIG["DELAY"] + 2.0))
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
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
    
    if os.path.exists(CONFIG["JSON_BACKUP"]):
        try:
            with open(CONFIG["JSON_BACKUP"], 'r', encoding='utf-8') as f:
                all_remedies = json.load(f)
                scraped_urls = {item["url"] for item in all_remedies}
            print(f"Resuming: found {len(all_remedies)} already scraped remedies.")
        except Exception as e:
            print(f"Could not load backup: {e}")

    for author in tqdm(CONFIG["AUTHORS"], desc="Authors"):
        author_slug = author["slug"]
        index_url = f"{CONFIG['BASE_URL']}/en/materia-medica/{author_slug}/index"
        soup = get_soup(index_url)
        if not soup: continue
            
        links = soup.find_all('a', href=True)
        remedy_links = list(set([
            CONFIG["BASE_URL"] + link['href'] if link['href'].startswith('/') else link['href']
            for link in links 
            if f"/en/materia-medica/{author_slug}/" in link['href'] and not link['href'].endswith('/index')
        ]))
        
        for url in tqdm(remedy_links, desc=f"Remedies for {author_slug}", leave=False):
            if url in scraped_urls: continue
            remedy_soup = get_soup(url)
            if not remedy_soup: continue
                
            try:
                name = remedy_soup.find('h1').get_text(strip=True) if remedy_soup.find('h1') else "Unknown"
                content_div = remedy_soup.find('div', id='content') or remedy_soup.find('main') or remedy_soup.body
                
                # Clone content to avoid modifying the original soup if needed
                import copy
                clean_content = copy.copy(content_div)

                # Remove navigation, scripts, and the A-Z index lists
                for tag in clean_content.find_all(['nav', 'header', 'footer', 'script', 'style', 'ul', 'ol']):
                    tag.decompose()
                
                text = clean_content.get_text(separator='\n', strip=True)
                
                # Remove repetitive headers and the A-Z string if it still exists
                lines = text.split('\n')
                filtered_lines = []
                for line in lines:
                    line_strip = line.strip()
                    # Skip very short lines (like single letters A, B, C from the index)
                    if len(line_strip) <= 2 and line_strip.isalpha(): continue
                    # Skip common repetitive header text
                    if "Materia Medica by" in line: continue
                    if "was written in 1901" in line: continue
                    if "read the full book here" in line: continue
                    if "Index" == line_strip: continue
                    if "123" == line_strip: continue
                    filtered_lines.append(line_strip)
                
                final_text = "\n".join(filtered_lines)

                all_remedies.append({
                    "author_slug": author_slug,
                    "slug": url.split('/')[-1],
                    "name": name,
                    "full_text": final_text,
                    "url": url
                })
                scraped_urls.add(url)
                if len(all_remedies) % 10 == 0:
                    with open(CONFIG["JSON_BACKUP"], 'w', encoding='utf-8') as f:
                        json.dump(all_remedies, f, ensure_ascii=False, indent=4)
            except Exception as e:
                print(f"Error parsing {url}: {e}")
                
    return all_remedies

def embed_step(data):
    print("\n--- STEP 2: EMBEDDING ---")
    from sentence_transformers import SentenceTransformer
    model = SentenceTransformer(CONFIG["EMBEDDING_MODEL"])
    
    for item in tqdm(data, desc="Generating Embeddings"):
        if "embedding" in item: continue
        text = item["full_text"]
        words = text.split()
        if len(words) > 512: text = " ".join(words[:512])
        item["embedding"] = model.encode(text).tolist()
        
    with open(CONFIG["JSON_BACKUP"], 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    return data

def upload_step(data):
    print("\n--- STEP 3: UPLOADING TO LOCAL POSTGRESQL ---")
    if not DB_URL:
        print("Error: DATABASE_URL not found in .env")
        return
        
    try:
        conn = psycopg2.connect(DB_URL)
        cur = conn.cursor()
        
        # 1. Upsert Authors
        authors_data = [(a["slug"], a["name"]) for a in CONFIG["AUTHORS"]]
        execute_values(cur, """
            INSERT INTO authors (slug, name) VALUES %s 
            ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name
        """, authors_data)
        
        cur.execute("SELECT id, slug FROM authors")
        author_map = {slug: id for id, slug in cur.fetchall()}
        
        # 2. Upsert Remedies
        remedies_data = [(
            author_map[item["author_slug"]],
            item["slug"],
            item["name"],
            item["full_text"],
            item["url"],
            json.dumps(item["embedding"]) # Convert list to JSON string for JSONB column
        ) for item in data]
        
        execute_values(cur, """
            INSERT INTO remedies (author_id, slug, name, full_text, url, embedding) 
            VALUES %s 
            ON CONFLICT (author_id, slug) 
            DO UPDATE SET 
                name = EXCLUDED.name, 
                full_text = EXCLUDED.full_text, 
                url = EXCLUDED.url, 
                embedding = EXCLUDED.embedding
        """, remedies_data)
        
        conn.commit()
        cur.close()
        conn.close()
        print("Upload complete.")
    except Exception as e:
        print(f"Database error: {e}")

def main():
    try:
        data = scrape_step()
        if data:
            data = embed_step(data)
            upload_step(data)
            print("\nAll steps completed successfully!")
    except Exception as e:
        print(f"\nFATAL ERROR: {e}")

if __name__ == "__main__":
    main()
