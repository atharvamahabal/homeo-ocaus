import psycopg2
from postgrest import SyncPostgrestClient
import os
import json
from tqdm import tqdm
from dotenv import load_dotenv

# Load credentials
load_dotenv()
LOCAL_DB_URL = os.getenv("DATABASE_URL")
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")

def migrate():
    if not all([LOCAL_DB_URL, SUPABASE_URL, SUPABASE_KEY]):
        print("Error: Missing credentials in .env file.")
        return

    try:
        # 1. Connect to local PostgreSQL
        print("Connecting to local PostgreSQL...")
        local_conn = psycopg2.connect(LOCAL_DB_URL)
        local_cur = local_conn.cursor()

        # 2. Connect to Supabase via Postgrest
        print("Connecting to Supabase...")
        headers = {
            "apikey": SUPABASE_KEY,
            "Authorization": f"Bearer {SUPABASE_KEY}"
        }
        client = SyncPostgrestClient(f"{SUPABASE_URL}/rest/v1", headers=headers)

        # 3. Migrate Authors
        print("\n--- Migrating Authors ---")
        local_cur.execute("SELECT slug, name FROM authors")
        authors = local_cur.fetchall()
        
        authors_data = [{"slug": a[0], "name": a[1]} for a in authors]
        client.from_("authors").upsert(authors_data, on_conflict="slug").execute()
        print(f"Synced {len(authors_data)} authors.")

        # Get author ID mapping from Supabase
        sb_authors = client.from_("authors").select("id, slug").execute()
        author_map = {row["slug"]: row["id"] for row in sb_authors.data}

        # 4. Migrate Remedies
        print("\n--- Migrating Remedies ---")
        local_cur.execute("""
            SELECT a.slug, r.slug, r.name, r.full_text, r.url, r.embedding 
            FROM remedies r
            JOIN authors a ON r.author_id = a.id
        """)
        remedies = local_cur.fetchall()
        
        batch_size = 50
        remedies_to_sync = []
        
        for r in tqdm(remedies, desc="Preparing data"):
            remedies_to_sync.append({
                "author_id": author_map[r[0]],
                "slug": r[1],
                "name": r[2],
                "full_text": r[3],
                "url": r[4],
                "embedding": r[5] # This is already a list in the local DB
            })

        print(f"Syncing {len(remedies_to_sync)} remedies in batches...")
        for i in tqdm(range(0, len(remedies_to_sync), batch_size), desc="Uploading"):
            batch = remedies_to_sync[i:i + batch_size]
            client.from_("remedies").upsert(batch, on_conflict="author_id, slug").execute()

        local_cur.close()
        local_conn.close()
        print("\nMigration completed successfully!")

    except Exception as e:
        print(f"Migration failed: {e}")

if __name__ == "__main__":
    migrate()
