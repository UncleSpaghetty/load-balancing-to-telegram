import requests
import sys

if __name__ == "__main__":

    if len(sys.argv) != 4:
            print("Usage: python main.py <bot token> <chat id> <message>")
            sys.exit(1)

    print("Sending message...")
    bot = sys.argv[1]
    chat = sys.argv[2]
    message = sys.argv[3]
    url = f"https://api.telegram.org/bot{bot}/sendMessage?chat_id={chat}&text={message}"
    response = requests.post(url)
    if not response.ok:
        message = response.json()['description']
        chat = response.json()['parameters']['migrate_to_chat_id']
        url = f"https://api.telegram.org/bot{bot}/sendMessage?chat_id={chat}&text={message}"
        response = requests.post(url)
    sys.exit(1)
