import os
import socket
from dotenv import load_dotenv
from urllib.parse import urlparse

load_dotenv()

def debug_supabase_connectivity():
    url = os.getenv("SUPABASE_URL")
    key = os.getenv("SUPABASE_KEY")
    
    print(f"Checking Supabase URL: {url}")
    
    if not url:
        print("❌ Error: SUPABASE_URL is not set in .env")
        return

    try:
        # 1. Test DNS Resolution
        domain = urlparse(url).netloc
        print(f"Resolving domain: {domain}...")
        ip = socket.gethostbyname(domain)
        print(f"✅ DNS Resolved: {domain} -> {ip}")
        
        # 2. Test TCP Connectivity (Port 443)
        print(f"Testing TCP connection to {domain}:443...")
        s = socket.create_connection((domain, 443), timeout=5)
        print(f"✅ TCP Connection successful!")
        s.close()
        
    except socket.gaierror as e:
        print(f"❌ DNS Error: {e}. This usually means the computer cannot find the Supabase server.")
    except socket.timeout:
        print(f"❌ Connection Timeout: Could not reach Supabase on port 443.")
    except Exception as e:
        print(f"❌ Connectivity Error: {e}")

if __name__ == "__main__":
    debug_supabase_connectivity()
