# Load Balancing to Telegram

## Before running __watcher.sh__, you must set BOT_TOKEN and CHANNEL_ID in __tokens.sh__.

```bash
BOT_TOKEN="YourBOTToken"
CHANNEL_ID="channel_id"
```

Within the ***costants.sh*** file you can change the cap on the values for CPU, RAM, DISK and TEMPERATURE:

```bash
CPU_PERCENTAGE_CAP="Value"
RAM_PERCENTAGE_CAP="Value"
DISK_PERCENTAGE_CAP="Value"
TEMP_PERCENTAGE_CAP="Value"
```

the time interval to be checked from the first value that exceeds the limit:

```bash
CPU_CHECK_TIMEFRAME="Value"
RAM_CHECK_TIMEFRAME="Value"
DISK_CHECK_TIMEFRAME="Value"
TEMP_CHECK_TIMEFRAME="Value"
```

and the limit of times the cap on the values is activated:

```bash
CPU_CHECK_COUNTER="Value"
RAM_CHECK_COUNTER="Value"
DISK_CHECK_COUNTER="Value"
TEMP_CHECK_COUNTER="Value"
```

You can also change the name of the server in the message (default is "$HOSTNAME", which is the default name of the machine):

```bash
SERVER_NAME="Name"
```

Once the activity values **exceed the threshold as many times as the counter in the timeframe limit**, a message is sent on the telegram channel set, indicating which threshold has been exceeded and by how much.

For **BOT_TOKEN**, you can use your own bot.
Create a bot and get a token from [Telegram Botfather](https://telegram.me/botfather).

For **CHANNEL_ID** you can link the bot a telegram group or create one.

Trough this [link](https://api.telegram.org/bot) you can get the **CHANNEL_ID** of the group/user and get the updates of the bot messages.

https://api.telegram.org/bot"BOT_TOKEN"/getUpdates

With this command you can send a message to the group/user.

```bash
curl https://api.telegram.org/botBOT_TOKENsendMessage?chat_id=CHANNEL_ID&text=TEXT
```
