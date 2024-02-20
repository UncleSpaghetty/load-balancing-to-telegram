import requests
import sys

if __name__ == "__main__":

    if len(sys.argv) != 4:
            print("Usage: python main.py <bot token> <chat id> <message>")
            sys.exit(1)
 
    bot = sys.argv[1]
    chat = sys.argv[2]
    message = sys.argv[3]
    url = f"https://api.telegram.org/bot{bot}/sendMessage?chat_id={chat}&text={message}"
    requests.post(url)
