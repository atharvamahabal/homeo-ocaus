import re
import json
import os
from dotenv import load_dotenv
from sentence_transformers import SentenceTransformer
from postgrest import SyncPostgrestClient
from tqdm import tqdm

load_dotenv()

# Supabase configuration
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")
# Medical-domain model for better homeopathic term recognition
MODEL_NAME = "pritamdeka/S-PubMedBert-MS-MARCO"

print("Loading AI model...")
model = SentenceTransformer(MODEL_NAME)

def parse_remedy_text(text):
    """
    Parses raw remedy text into structured sections using regex and common headers.
    """
    sections = {
        "keynotes": "",
        "modalities_worse": "",
        "modalities_better": "",
        "mental_symptoms": "",
        "physical_symptoms": "",
        "miasm": "",
        "constitution": ""
    }

    if not text:
        return sections

    # Normalize text: uppercase for matching headers
    lines = text.split('\n')
    
    current_section = None
    
    # Simple keyword mapping
    header_map = {
        r'^(MIND|MENTAL|EMOTIONS)': 'mental_symptoms',
        r'^(CHARACTERISTICS|KEYNOTES|GUIDING|SUMMARY)': 'keynotes',
        r'^(AGGRAVATION|WORSE|AGG\.)': 'modalities_worse',
        r'^(AMELIORATION|BETTER|AMEL\.)': 'modalities_better',
        r'^(MIASM|DIATHESIS)': 'miasm',
        r'^(CONSTITUTION|TEMPERAMENT|APPEARANCE)': 'constitution',
        r'^(HEAD|EYES|EARS|NOSE|FACE|MOUTH|THROAT|STOMACH|ABDOMEN|STOOL|URINE|MALE|FEMALE|RESPIRATORY|HEART|BACK|EXTREMITIES|SLEEP|FEVER|SKIN)': 'physical_symptoms'
    }

    for line in lines:
        stripped = line.strip()
        if not stripped: continue
        
        # Check if line is a header
        is_header = False
        for pattern, section_key in header_map.items():
            if re.match(pattern, stripped, re.IGNORECASE):
                current_section = section_key
                is_header = True
                break
        
        if is_header:
            continue
            
        if current_section:
            sections[current_section] += stripped + " "
        else:
            # Default to keynotes if no section identified yet
            sections["keynotes"] += stripped + " "

    # Final cleanup
    for k in sections:
        sections[k] = sections[k].strip()
        
    return sections

def process_and_update():
    headers = {
        "apikey": SUPABASE_KEY,
        "Authorization": f"Bearer {SUPABASE_KEY}"
    }
    client = SyncPostgrestClient(f"{SUPABASE_URL}/rest/v1", headers=headers)

    print("Fetching remedies from Supabase...")
    # Fetch all columns to satisfy NOT NULL constraints during upsert
    res = client.from_("remedies").select("id, full_text, name, slug, author_id, url").execute()
    remedies = res.data

    print(f"Found {len(remedies)} remedies to process.")

    batch_size = 25
    for i in tqdm(range(0, len(remedies), batch_size), desc="Structuring Remedies"):
        batch = remedies[i:i+batch_size]
        updates = []
        
        for r in batch:
            structured = parse_remedy_text(r["full_text"])
            
            # 1. Generate main 'full_text' embedding
            full_text_limited = " ".join(r["full_text"].split()[:512])
            main_embedding = model.encode(full_text_limited).tolist()
            
            # 2. Prepare update data - Include required non-null columns
            update_data = {
                "id": r["id"],
                "name": r["name"],
                "slug": r["slug"],
                "author_id": r["author_id"],
                "full_text": r["full_text"],
                "url": r["url"],
                "embedding": main_embedding
            }
            update_data.update(structured)
            
            # 3. Generate section-specific embeddings
            for section, text in structured.items():
                if text:
                    # Limit text length for embedding
                    embed_text = " ".join(text.split()[:512])
                    embedding = model.encode(embed_text).tolist()
                    update_data[f"{section}_embedding"] = embedding
                else:
                    update_data[f"{section}_embedding"] = None
            
            updates.append(update_data)
        
        # Upsert to update existing rows
        try:
            client.from_("remedies").upsert(updates, on_conflict="id").execute()
        except Exception as e:
            print(f"Error updating batch: {e}")

if __name__ == "__main__":
    process_and_update()
