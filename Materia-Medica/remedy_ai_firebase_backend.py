import firebase_admin
from firebase_admin import credentials, firestore
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import json
import os
import re
from dotenv import load_dotenv
from sentence_transformers import SentenceTransformer
import numpy as np
import threading
import socket
from notification_listener import start_notification_listener

def get_local_ip():
    """Gets the local IP address of the machine."""
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        local_ip = s.getsockname()[0]
        s.close()
        return local_ip
    except Exception:
        return "127.0.0.1"

load_dotenv()

# Initialize FastAPI
app = FastAPI()

# Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 1. Initialize Firebase Admin (Reuse existing logic from listener)
service_account_json = os.getenv("FIREBASE_SERVICE_ACCOUNT")
try:
    if service_account_json:
        import json
        service_account_info = json.loads(service_account_json)
        cred = credentials.Certificate(service_account_info)
    else:
        cert_path = os.path.join(os.path.dirname(__file__), "serviceAccountKey.json")
        if not os.path.exists(cert_path):
            raise FileNotFoundError("FIREBASE_SERVICE_ACCOUNT or serviceAccountKey.json not found")
        cred = credentials.Certificate(cert_path)
        
    # Check if app is already initialized
    try:
        firebase_admin.get_app()
    except ValueError:
        firebase_admin.initialize_app(cred)
    
    db = firestore.client()
    print("Firebase Admin initialized for /chat.")
except Exception as e:
    print(f"Error initializing Firebase for /chat: {e}")

# Load AI model
MODEL_NAME = "pritamdeka/S-PubMedBert-MS-MARCO"
print("Loading AI model...")
model = SentenceTransformer(MODEL_NAME)
print("Model loaded.")

class ChatQuery(BaseModel):
    message: str
    symptoms: list[str] = []

def cosine_similarity(v1, v2):
    return np.dot(v1, v2) / (np.linalg.norm(v1) * np.linalg.norm(v2))

def clean_remedy_text(text):
    if not text: return ""
    lines = text.split('\n')
    filtered_lines = []
    junk_patterns = ["materia medica by", "was written in 1901", "read the full book here", "index"]
    for line in lines:
        line_strip = line.strip()
        if len(line_strip) <= 2 and line_strip.isalpha(): continue
        if any(pattern in line_strip.lower() for pattern in junk_patterns): continue
        if line_strip: filtered_lines.append(line_strip)
    return "\n".join(filtered_lines)

def classify_symptom(symptom):
    s = symptom.lower()
    worse_keywords = ["worse", "aggravation", "agg", "<", "after", "cold", "heat", "night"]
    better_keywords = ["better", "amelioration", "amel", ">", "relief", "open air"]
    mental_keywords = ["mind", "mental", "fear", "anxiety", "depression", "anger"]
    physical_keywords = ["pain", "head", "stomach", "skin", "cough", "fever", "heart"]
    if any(k in s for k in worse_keywords): return "modalities_worse"
    if any(k in s for k in better_keywords): return "modalities_better"
    if any(k in s for k in mental_keywords): return "mental_symptoms"
    if any(k in s for k in physical_keywords): return "physical_symptoms"
    return "keynotes"

@app.post("/chat")
async def chat_with_remedies(query: ChatQuery):
    try:
        symptoms_to_search = query.symptoms if query.symptoms else [query.message]
        repertory_map = {} # {remedy_id: {data}}
        
        for symptom in symptoms_to_search:
            target_category = classify_symptom(symptom)
            print(f"Searching for symptom: {symptom} (Targeting: {target_category})")
            symptom_embedding = model.encode(symptom).tolist()
            
            # Since Firestore doesn't support vector search natively, we'll do a fallback:
            # We search for remedies that have ANY keyword from the symptom in their name or text
            # OR we fetch a set of common remedies and rank them by embedding similarity locally.
            
            # OPTIMIZATION: For now, we'll fetch remedies and rank them. 
            # In a real production Firebase app, you'd use a companion like Pinecone or Algolia.
            # But for this local backend, we can load-and-rank.
            
            remedies_ref = db.collection("remedies")
            # Limit to 100 remedies for performance during this transition
            docs = remedies_ref.limit(100).stream()
            
            for doc in docs:
                r_data = doc.to_dict()
                rid = doc.id
                
                # Check if this remedy has the target embedding
                target_emb = r_data.get(f"{target_category}_embedding")
                if not target_emb:
                    target_emb = r_data.get("embedding") # Fallback to main
                
                if target_emb:
                    sim = cosine_similarity(np.array(symptom_embedding), np.array(target_emb))
                    
                    if sim > 0.15: # Threshold
                        if rid not in repertory_map:
                            repertory_map[rid] = {
                                "name": r_data.get("name", "Unknown"),
                                "matched_symptoms": [],
                                "similarities": [],
                                "data": r_data
                            }
                        repertory_map[rid]["matched_symptoms"].append(f"{symptom} ({target_category})")
                        repertory_map[rid]["similarities"].append(sim)

        # Ranking logic (Same as Supabase version)
        final_candidates = []
        for rid, data in repertory_map.items():
            coverage_count = len(data["matched_symptoms"])
            avg_sim = sum(data["similarities"]) / len(data["similarities"])
            final_candidates.append({
                "id": rid,
                "name": data["name"],
                "matched_symptoms": data["matched_symptoms"],
                "coverage_count": coverage_count,
                "avg_similarity": avg_sim,
                "score": (coverage_count * 1000) + (avg_sim * 10),
                "data": data["data"]
            })

        final_candidates.sort(key=lambda x: x["score"], reverse=True)
        top_candidates = final_candidates[:5]

        if not top_candidates:
            return {"reply": "I couldn't find any remedies in Firebase matching these symptoms."}

        reply = f"✨ **FIREBASE REPERTORIZATION** ✨\n"
        reply += f"Symptoms analyzed: {', '.join(symptoms_to_search)}\n\n"
        
        for i, res in enumerate(top_candidates):
            r_data = res["data"]
            cleaned_text = clean_remedy_text(r_data.get("full_text", ""))
            tag = "🏆 SIMILLIMUM" if i == 0 and len(res["matched_symptoms"]) == len(symptoms_to_search) else f"Rank #{i+1}"
            
            reply += f"{tag}\n🌿 **{res['name'].upper()}**\n"
            reply += f"✅ Matches: {', '.join(res['matched_symptoms'])}\n"
            if r_data.get("modalities_worse"):
                reply += f"⚠️ Worse: {r_data['modalities_worse'][:100]}...\n"
            reply += f"🎯 Match: {int(res['avg_similarity']*100)}%\n"
            reply += f"📖 Snippet: {cleaned_text[:200]}...\n\n"

        return {"reply": reply.strip()}

    except Exception as e:
        print(f"Error in Firebase /chat: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/")
async def root():
    return {"status": "Homeo AI Backend (Firebase Mode) is running"}

if __name__ == "__main__":
    local_ip = get_local_ip()
    print(f"\nFIREBASE BACKEND STARTING ON: {local_ip}:8000\n")
    
    # Start notification listener
    threading.Thread(target=start_notification_listener, daemon=True).start()
    
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
