#!/bin/bash
# Generate the daily public log summary
# Called by cron at 23:59 AST
# Uses persistent browser session for @BoloMichelin

set -e
cd "$(dirname "$0")/.."

ACTIVITY_FILE="$(pwd)/nox/activity.json"
TWEET_FILE="$(pwd)/nox/tweet_text.txt"

if [ ! -f "$ACTIVITY_FILE" ]; then
  echo "No activity file found for today."
  exit 0
fi

# Generate tweet text from activity data
# This is a helper — the actual tweet generation happens in the agent
# We just produce the tweet text here

python3 -c "
import json, sys
with open('$ACTIVITY_FILE') as f:
    data = json.load(f)

items = data.get('items', [])
help_items = data.get('needed_help', [])
date = data.get('date', 'today')

lines = []
lines.append(f'Nox daily log — {date}')
lines.append('')

for item in items[:3]:
    task = item.get('task') or item.get('detail')
    if task:
        lines.append(f'• {task}')

if help_items:
    lines.append('')
    lines.append(f'Help: {help_items[0]}')

tweet = '\n'.join(lines)

# Trim to 280 chars preserving last line
if len(tweet) > 280:
    while len(tweet) > 277:
        lines = lines[:-1]
        tweet = '\n'.join(lines)
    tweet += '..'

print(tweet)
sys.stdout.flush()
" 2>/dev/null > "$TWEET_FILE"

echo "Tweet text saved to $TWEET_FILE"
cat "$TWEET_FILE"
