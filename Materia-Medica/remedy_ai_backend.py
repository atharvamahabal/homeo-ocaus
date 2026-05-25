from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import json
import os
from dotenv import load_dotenv
from sentence_transformers import SentenceTransformer
import numpy as np
from postgrest import SyncPostgrestClient

load_dotenv()

app = FastAPI()

# Supabase configuration
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")
MODEL_NAME = "all-MiniLM-L6-v2"

# Load the AI model once on startup
print("Loading AI model...")
model = SentenceTransformer(MODEL_NAME)
print("Model loaded.")

class ChatQuery(BaseModel):
    message: str

def cosine_similarity(v1, v2):
    return np.dot(v1, v2) / (np.linalg.norm(v1) * np.linalg.norm(v2))

def clean_remedy_text(text):
    """Cleans up the raw scraped text by removing repetitive headers and navigation indices."""
    if not text: return ""
    lines = text.split('\n')
    filtered_lines = []
    
    # Common junk words to filter
    junk_patterns = [
        "materia medica by",
        "was written in 1901",
        "read the full book here",
        "index",
        "123"
    ]
    
    for line in lines:
        line_strip = line.strip()
        # Skip single letters (A, B, C...) from the navigation index
        if len(line_strip) <= 2 and line_strip.isalpha(): continue
        # Skip junk patterns
        if any(pattern in line_strip.lower() for pattern in junk_patterns): continue
        if line_strip:
            filtered_lines.append(line_strip)
    
    return "\n".join(filtered_lines)

@app.post("/chat")
async def chat_with_remedies(query: ChatQuery):
    try:
        # 1. Generate embedding for the user's question
        query_embedding = model.encode(query.message)
        
        # 2. Connect to Supabase via Postgrest
        headers = {
            "apikey": SUPABASE_KEY,
            "Authorization": f"Bearer {SUPABASE_KEY}"
        }
        client = SyncPostgrestClient(f"{SUPABASE_URL}/rest/v1", headers=headers)
        
        # 3. Use the match_remedies RPC function for high-performance vector search
        # This is much faster than fetching all rows and calculating similarity in Python
        rpc_res = client.rpc("match_remedies", {
            "query_embedding": query_embedding.tolist(),
            "match_threshold": 0.4,
            "match_count": 3
        }).execute()
        
        top_results = rpc_res.data
        
        if not top_results:
            return {"reply": "I couldn't find a specific homeopathic remedy for that. Could you describe the symptoms in more detail?"}
        
        # 4. Fetch full text for these results to provide descriptions
        # (RPC returns IDs and names, we need the text)
        ids = [res["id"] for res in top_results]
        remedies_res = client.from_("remedies").select("id, name, full_text").in_("id", ids).execute()
        
        # Map them back to keep the similarity order
        remedy_map = {r["id"]: r for r in remedies_res.data}
        
        # 5. Format the response
        reply = "Based on Materia Medica (Cloud), here are the most relevant remedies:\n\n"
        for i, res in enumerate(top_results):
            remedy_data = remedy_map.get(res["id"])
            if remedy_data:
                cleaned_text = clean_remedy_text(remedy_data["full_text"])
                reply += f"{i+1}. {res['name']} (Match: {int(res['similarity']*100)}%)\n{cleaned_text[:400]}...\n\n"
            
        return {"reply": reply}

    except Exception as e:
        print(f"Error in /chat: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/")
async def root():
    return {"status": "Homeo AI Backend (Supabase Mode) is running"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
