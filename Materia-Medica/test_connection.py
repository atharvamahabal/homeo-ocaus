import requests

def test_backend():
    url = "http://127.0.0.1:8000/"
    try:
        response = requests.get(url)
        print(f"Local Status: {response.status_code}")
        print(f"Response: {response.json()}")
        
        # Test with the local IP too
        local_ip = "192.168.43.147"
        url_ip = f"http://{local_ip}:8000/"
        response_ip = requests.get(url_ip)
        print(f"Network IP Status: {response_ip.status_code}")
        print("Success! Your backend is reachable on the network.")
        
    except Exception as e:
        print(f"Connection failed: {e}")
        print("\nPossible reasons:")
        print("1. The backend is not running.")
        print("2. Windows Firewall is blocking Python.")
        print("3. You are not on the 192.168.43.x network.")

if __name__ == "__main__":
    test_backend()
