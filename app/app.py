import os
from base64 import b64decode
import boto3
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions
import requests


FILENAME = "/tmp/screen.png"
SLACK_TOKEN = os.environ.get("SLACK_TOKEN")
SLACK_CHANNEL_ID = os.environ.get("SLACK_CHANNEL_ID")
SLACK_USERNAME = os.environ.get("SLACK_USERNAME")
SLACK_PASSWORD = os.environ.get("SLACK_PASSWORD")
SLACK_LOGIN_URL = os.environ.get("SLACK_LOGIN_URL")
SLACK_ATTEND_CHANNEL_URL = os.environ.get("SLACK_ATTEND_CHANNEL_URL")

chrome_path = "/usr/bin/chromium-browser"
chromedriver_path = "/usr/lib/chromium/chromedriver"
kms = boto3.client("kms")


def handler(event, context):
    o = Options()
    o.binary_location = chrome_path
    o.add_argument('--headless')
    o.add_argument('--disable-gpu')
    o.add_argument('--no-sandbox')
    o.add_argument('--disable-dev-shm-usage')
    o.add_argument('--window-size=1920x1080')
    o.add_argument('--disable-application-cache')
    o.add_argument('--disable-infobars')
    o.add_argument('--hide-scrollbars')
    o.add_argument('--enable-logging')
    o.add_argument('--log-level=0')
    o.add_argument('--single-process')
    o.add_argument('--ignore-certificate-errors')
    o.add_argument('--disable-desktop-notifications')
    o.add_argument("--disable-extensions")
    o.add_argument("--lang=ja-JP")
    o.add_argument("--remote-debugging-port=9222")

    """
    Use the Chrome DriverService.
    https://chromedriver.chromium.org/getting-started
    """
    print("Start Chrome Session")
    s = Service(executable_path=chromedriver_path)
    s.start()
    d = webdriver.Remote(
        s.service_url,
        desired_capabilities=o.to_capabilities()
    )
    wait = WebDriverWait(d, 10)

    d.get(SLACK_LOGIN_URL)

    print(f"PageTitle {d.title}")
    email = wait.until(expected_conditions.visibility_of_element_located((By.ID, "email")))
    email.send_keys(SLACK_USERNAME)

    email = d.find_element(by=By.ID, value="password")
    email.send_keys(decode_slack_password())

    signin_btn = d.find_element(by=By.ID, value="signin_btn")
    signin_btn.click()

    d.implicitly_wait(10)
    print(f"PageTitle {d.title}")
    # print(d.page_source)

    d.get(SLACK_ATTEND_CHANNEL_URL)

    wait.until(expected_conditions.visibility_of_element_located((By.CLASS_NAME, "p-message_pane")))

    day_button_elements = d.find_elements_by_class_name("c-button-unstyled")

    days_pickers = [x.text for x in day_button_elements]
    print(f"day_button_elements: {days_pickers}")
    if "今日" in days_pickers or "Today" in days_pickers:
        print(f"Take ScreenShot")
        print(d.save_screenshot(FILENAME))
        url = "https://slack.com/api/files.upload"
        data = {
            "token": SLACK_TOKEN,
            "channels": SLACK_CHANNEL_ID,
            "title": "attend",
            "initial_comment": "本日のattendです"
        }
        files = {"file": open(FILENAME, "rb")}
        print(f"Upload To Slack")
        resp = requests.post(url, data=data, files=files)
        print(resp.text)

    else:
        print(d.page_source)
        print(f"Nothing Attend Today")

    print(f"Quit Chrome Session")
    d.quit()
    return "OK"


def decode_slack_password():
    decoded = kms.decrypt(CiphertextBlob=b64decode(SLACK_PASSWORD))['Plaintext']
    return decoded.decode(encoding="utf-8")


if __name__ == '__main__':
    handler(None, None)
