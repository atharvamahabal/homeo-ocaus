import requests
from bs4 import BeautifulSoup

def test_fetch():
    url = "https://www.materiamedica.info/en/materia-medica/james-tyler-kent/index"
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7",
        "Accept-Language": "en-US,en;q=0.9",
        "Referer": "https://www.materiamedica.info/en/materia-medica/",
        "DNT": "1",
        "Connection": "keep-alive",
        "Upgrade-Insecure-Requests": "1"
    }
    try:
        response = requests.get(url, headers=headers, timeout=10)
        print(f"Status Code: {response.status_code}")
        if response.status_code == 200:
            soup = BeautifulSoup(response.text, 'html.parser')
            print(f"Title: {soup.title.string}")
            print(f"Found {len(soup.find_all('a'))} links")
        else:
            print(f"Response Text: {response.text[:500]}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    test_fetch()
