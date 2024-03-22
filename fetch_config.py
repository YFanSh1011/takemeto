import sys
import os
import time
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import os

DASHBOARD_URL = sys.argv[1]
VPN_CREDENTIALS_PATH = os.environ.get("VPN_CREDENTIALS_PATH")

def load_credentials():
    with open(VPN_CREDENTIALS_PATH, "r") as f:
        lines = f.readlines()
        username = lines[0].strip()
        password = lines[1].strip()
        return username, password

def configure_webdriver():
    options = webdriver.ChromeOptions()
    options.add_argument('--ignore-certificate-errors')
    driver = webdriver.Chrome(options=options)
    return driver

def login_to_dashboard(driver, username, password):
    driver.get(DASHBOARD_URL)
    print("Attempting to connect to", DASHBOARD_URL)

    # Wait until the login page is loaded
    WebDriverWait(driver, 10).until(
        lambda driver: driver.find_element(By.ID, "username")
        and driver.find_element(By.ID, "password")
        and driver.find_element(By.ID, "go")
    )

    # Register login username and password
    username_textbox = driver.find_element(By.ID, "username")
    password_textbox = driver.find_element(By.ID, "password")
    signin_button = driver.find_element(By.ID, "go")

    # Enter the credentials and click login
    username_textbox.send_keys(username)
    password_textbox.send_keys(password)
    signin_button.click()

def download_client_profile(driver):
    # Wait until the profile is displayed
    WebDriverWait(driver, 10).until(
        lambda driver: driver.find_element(By.XPATH, "//ul[@id='select-profile']//button")
    )

    # Click the button for download
    element_locator = (By.XPATH, "//ul[@id='select-profile']//button")
    element = WebDriverWait(driver, 10).until(
        EC.element_to_be_clickable(element_locator)
    )
    time.sleep(2)
    driver.execute_script("arguments[0].click();", element)
    time.sleep(2)  # Wait for download to start

    
def main():
    username, password = load_credentials()
    driver = configure_webdriver()
    login_to_dashboard(driver, username, password)
    download_client_profile(driver)
    

if __name__ == '__main__':
    main()