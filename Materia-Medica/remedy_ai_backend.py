from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import json
import os
from dotenv import load_dotenv
from sentence_transformers import SentenceTransformer
import numpy as np
from postgrest import SyncPostgrestClient
import threading
import socket
from notification_listener import start_notification_listener

def get_local_ip():
    """Gets the local IP address of the machine."""
    try:
        # Create a dummy socket to find the primary interface
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        local_ip = s.getsockname()[0]
        s.close()
        return local_ip
    except Exception:
        return "127.0.0.1"

load_dotenv()

app = FastAPI()

# Supabase configuration
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")
# Medical-domain model for better homeopathic term recognition
MODEL_NAME = "pritamdeka/S-PubMedBert-MS-MARCO"

# Load the AI model once on startup
print("Loading AI model...")
model = SentenceTransformer(MODEL_NAME)
print("Model loaded.")

class ChatQuery(BaseModel):
    message: str
    symptoms: list[str] = []

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

def classify_symptom(symptom):
    """
    Classifies a symptom into a clinical category for targeted searching.
    """
    s = symptom.lower()
    
    worse_keywords = ["worse", "aggravation", "agg", "<", "after", "during", "from", "cold", "heat", "weather", "night", "morning"]
    better_keywords = ["better", "amelioration", "amel", ">", "relief", "improved by", "open air", "pressure", "rest"]
    mental_keywords = ["mind", "mental", "fear", "anxiety", "depression", "anger", "weeping", "sad", "irritable", "will"]
    physical_keywords = ["pain", "head", "stomach", "skin", "cough", "fever", "stool", "urine", "heart", "throat"]
    miasm_keywords = ["psora", "syphilis", "sycosis", "tubercular", "miasm"]
    constitution_keywords = ["tall", "thin", "fat", "chilly", "hot", "temperament", "complexion", "dark", "fair"]

    if any(k in s for k in worse_keywords): return "modalities_worse"
    if any(k in s for k in better_keywords): return "modalities_better"
    if any(k in s for k in mental_keywords): return "mental_symptoms"
    if any(k in s for k in physical_keywords): return "physical_symptoms"
    if any(k in s for k in miasm_keywords): return "miasm"
    if any(k in s for k in constitution_keywords): return "constitution"
    
    return "keynotes"

@app.post("/chat")
async def chat_with_remedies(query: ChatQuery):
    try:
        # Use symptoms list if provided, otherwise fall back to the single message
        symptoms_to_search = query.symptoms if query.symptoms else [query.message]
        
        # 1. Connect to Supabase via Postgrest
        headers = {
            "apikey": SUPABASE_KEY,
            "Authorization": f"Bearer {SUPABASE_KEY}"
        }
        client = SyncPostgrestClient(f"{SUPABASE_URL}/rest/v1", headers=headers)

        # 2. Search each symptom independently and collect candidates
        # Structure: {remedy_id: {"name": str, "matched_symptoms": list, "similarities": list}}
        repertory_map = {}
        
        for symptom in symptoms_to_search:
            target_category = classify_symptom(symptom)
            print(f"Searching for symptom: {symptom} (Targeting: {target_category})")
            symptom_embedding = model.encode(symptom)
            
            # 1. Try targeted category search
            rpc_res = client.rpc("match_remedies_structured", {
                "query_embedding": symptom_embedding.tolist(),
                "match_threshold": 0.18, # Lowered threshold slightly for better recall
                "match_count": 25,
                "target_column": target_category
            }).execute()
            
            # 2. Fallback to keynotes if targeted search failed
            if not rpc_res.data and target_category != "keynotes":
                print(f"No targeted matches for {target_category}, falling back to keynotes...")
                rpc_res = client.rpc("match_remedies_structured", {
                    "query_embedding": symptom_embedding.tolist(),
                    "match_threshold": 0.18,
                    "match_count": 25,
                    "target_column": "keynotes"
                }).execute()

            # 3. Final fallback to the main 'full_text' embedding column
            if not rpc_res.data:
                print(f"No matches in clinical sections, falling back to full_text embedding...")
                rpc_res = client.rpc("match_remedies_structured", {
                    "query_embedding": symptom_embedding.tolist(),
                    "match_threshold": 0.18,
                    "match_count": 25,
                    "target_column": "full_text" # This triggers the ELSE case in SQL
                }).execute()

            for res in rpc_res.data:
                rid = res["id"]
                if rid not in repertory_map:
                    repertory_map[rid] = {
                        "name": res["name"],
                        "matched_symptoms": [],
                        "similarities": []
                    }
                # Track which symptom this remedy matched
                if symptom not in repertory_map[rid]["matched_symptoms"]:
                    repertory_map[rid]["matched_symptoms"].append(f"{symptom} ({target_category})")
                    repertory_map[rid]["similarities"].append(res["similarity"])

        # 3. Calculate final scores
        # Score = (Symptoms Covered * 1000) + (Sum of Similarities)
        final_candidates = []
        total_symptoms = len(symptoms_to_search)
        
        for rid, data in repertory_map.items():
            coverage_count = len(data["matched_symptoms"])
            avg_sim = sum(data["similarities"]) / len(data["similarities"])
            coverage_pct = (coverage_count / total_symptoms) * 100
            
            # Primary ranking by coverage, secondary by similarity
            final_candidates.append({
                "id": rid,
                "name": data["name"],
                "matched_symptoms": data["matched_symptoms"],
                "coverage_count": coverage_count,
                "coverage_pct": int(coverage_pct),
                "avg_similarity": avg_sim,
                "score": (coverage_count * 1000) + (sum(data["similarities"]) * 10)
            })

        # 4. Sort by score (Coverage is king)
        final_candidates.sort(key=lambda x: x["score"], reverse=True)
        top_candidates = final_candidates[:5]

        if not top_candidates:
            return {"reply": "I couldn't find any remedies matching these symptoms. Please try broader terms."}

        # 5. Fetch full text and structured fields for the winners
        ids = [res["id"] for res in top_candidates]
        remedies_res = client.from_("remedies").select("id, full_text, keynotes, mental_symptoms, physical_symptoms, modalities_worse, modalities_better").in_("id", ids).execute()
        remedy_data_map = {r["id"]: r for r in remedies_res.data}

        # 6. Format the response
        reply = f"✨ **STRUCTURED REPERTORIZATION** ✨\n"
        reply += f"Symptoms analyzed: {', '.join(symptoms_to_search)}\n\n"
        
        for i, res in enumerate(top_candidates):
            r_data = remedy_data_map.get(res["id"], {})
            full_text = r_data.get("full_text", "")
            cleaned_text = clean_remedy_text(full_text)
            
            tag = "🏆 SIMILLIMUM" if i == 0 and res["coverage_count"] == total_symptoms else f"Rank #{i+1}"
            
            reply += f"{tag}\n"
            reply += f"🌿 **{res['name'].upper()}**\n"
            reply += f"📊 Coverage: {res['coverage_count']}/{total_symptoms} ({res['coverage_pct']}%)\n"
            reply += f"✅ Matches: {', '.join(res['matched_symptoms'])}\n"
            
            # Show targeted clinical snippets if available
            if r_data.get("mental_symptoms"):
                reply += f"🧠 Mind: {r_data['mental_symptoms'][:150]}...\n"
            if r_data.get("modalities_worse"):
                reply += f"⚠️ Worse: {r_data['modalities_worse'][:150]}...\n"
            if r_data.get("modalities_better"):
                reply += f"✅ Better: {r_data['modalities_better'][:150]}...\n"
                
            reply += f"🎯 Avg. Match: {int(res['avg_similarity']*100)}%\n"
            reply += f"📖 Clinical Snippet: {cleaned_text[:300]}...\n\n"
            reply += "-------------------\n\n"

        return {"reply": reply.strip()}

    except Exception as e:
        print(f"Error in /chat: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/")
async def root():
    return {"status": "Homeo AI Backend (Supabase Mode) is running", "notifications": "Listener Active"}

if __name__ == "__main__":
    # Start the notification listener in a separate background thread
    print("\n" + "="*50)
    print("      HOMEOPATHY AI BACKEND STARTING")
    print("="*50)
    
    local_ip = get_local_ip()
    print(f"\n📡 NETWORK INFO:")
    print(f"   PC Local IP: {local_ip}")
    print(f"   In Flutter App Settings, enter: {local_ip}")
    print(f"   Status: Running on Port 8000")
    print("\n" + "="*50 + "\n")

    print("Starting notification listener thread...")
    notification_thread = threading.Thread(target=start_notification_listener, daemon=True)
    notification_thread.start()
    
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
