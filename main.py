from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from webdriver_manager.chrome import ChromeDriverManager
import time
import re
from threading import Thread, Lock
from flask import Flask, jsonify

app = Flask(__name__)

# Shared data structure and lock for thread safety
scraped_data = {
    "Normal Stock": [],
    "Mirage Stock": [],
    "Update Times": {}
}
data_lock = Lock()  # Lock to ensure thread-safe access to `scraped_data`

def get_seconds_from_time(update_time_text):
    match = re.search(r"UPDATES IN: (\d+) HOURS, (\d+) MINUTES, (\d+) SECONDS", update_time_text)
    if match:
        hours = int(match.group(1))
        minutes = int(match.group(2))
        seconds = int(match.group(3))
        return hours * 3600 + minutes * 60 + seconds
    return 0

def scrape_website():
    chrome_options = Options()
    chrome_options.add_argument("--headless")  # Run in headless mode
    chrome_options.add_argument("--no-sandbox")  # Required for cloud environments

    while True:
        driver = webdriver.Chrome(service=Service("/opt/render/project/.render/chrome/usr/bin/chromedriver"), options=chrome_options)
        #driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=chrome_options)
        
        driver.get("https://fruityblox.com/stock")
        
        time.sleep(10)  # Allow page to load

        try:
            # Scrape Normal Stock
            normal_stock_section = driver.find_element(By.XPATH, "//div[h2[text()='NORMAL STOCK']]")
            normal_update_time = normal_stock_section.find_element(By.XPATH, "./p").text.strip()
            normal_items = normal_stock_section.find_elements(By.XPATH, "./div/a")
            
            # Use a lock to safely update `scraped_data`
            with data_lock:
                scraped_data["Normal Stock"].clear()
                for item in normal_items:
                    name = item.find_element(By.XPATH, ".//h3").text.strip()
                    price_usd = item.find_element(By.XPATH, ".//p[contains(@class, 'text-[#21C55D]')]").text.strip()
                    price_robux = item.find_element(By.XPATH, ".//p[contains(@class, 'text-[#FACC14]')]").text.strip()
                    scraped_data["Normal Stock"].append((name, price_usd, price_robux))
                scraped_data["Update Times"]["Normal Stock"] = normal_update_time

            # Scrape Mirage Stock
            mirage_stock_section = driver.find_element(By.XPATH, "//div[h2[text()='MIRAGE STOCK']]")
            mirage_update_time = mirage_stock_section.find_element(By.XPATH, "./p").text.strip()
            mirage_items = mirage_stock_section.find_elements(By.XPATH, "./div/a")
            
            # Use a lock to safely update `scraped_data`
            with data_lock:
                scraped_data["Mirage Stock"].clear()
                for item in mirage_items:
                    name = item.find_element(By.XPATH, ".//h3").text.strip()
                    price_usd = item.find_element(By.XPATH, ".//p[contains(@class, 'text-[#21C55D]')]").text.strip()
                    price_robux = item.find_element(By.XPATH, ".//p[contains(@class, 'text-[#FACC14]')]").text.strip()
                    scraped_data["Mirage Stock"].append((name, price_usd, price_robux))
                scraped_data["Update Times"]["Mirage Stock"] = mirage_update_time

            # Print scraped data
            print("Scraped data:", scraped_data)

            # Calculate sleep time
            normal_stock_seconds = get_seconds_from_time(normal_update_time)
            mirage_stock_seconds = get_seconds_from_time(mirage_update_time)
            sleep_time = min(normal_stock_seconds, mirage_stock_seconds) + 10

            print(f"Sleeping for {sleep_time} seconds...")
            driver.quit()
            time.sleep(sleep_time)

        except Exception as e:
            print(f"An error occurred: {e}")
            driver.quit()
            time.sleep(60)

# Flask endpoint to return scraped data
@app.route("/", methods=["GET"])
def get_scraped_data():
    with data_lock:  # Ensure thread-safe access to `scraped_data`
        return jsonify(scraped_data)

# Start the scraper in a background thread
def start_scraper_in_background():
    scraper_thread = Thread(target=scrape_website, daemon=True)
    scraper_thread.start()

if __name__ == "__main__":
    # Start the scraper in the background
    start_scraper_in_background()

    # Start the Flask app
    app.run(host="0.0.0.0", port=5000)