#!/bin/sh
# Upload every Kobo screenshot in the internal storage to a Telegram chat.
# Invoked by NickelMenu, see the menu config in ../nm/screenshot_upload.
# Plain POSIX sh: on the Kobo this runs under busybox ash.

set -u

screenshot_path="${SCREENSHOT_DIR:-/mnt/onboard/}"

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

. "$SCRIPTPATH/telegram.config"

if [ -z "${TELEGRAM_BOT_TOKEN}" ] || [ -z "${CHAT_ID}" ] ||
   [ "${TELEGRAM_BOT_TOKEN}" = "YOUR_TELEGRAM_BOT_TOKEN" ] ||
   [ "${CHAT_ID}" = "YOUR_TELEGRAM_CHAT_ID" ]; then
    echo "Invalid Telegram credentials: put your bot token and chat id in $SCRIPTPATH/telegram.config first."
    exit 1
fi

if [ -x "$SCRIPTPATH/qndb" ]; then
    QNDB="$SCRIPTPATH/qndb"
elif command -v qndb >/dev/null 2>&1; then
    QNDB=qndb
else
    echo "qndb not found: copy the ARM qndb binary into $SCRIPTPATH (see README)."
    exit 1
fi

"$QNDB" -t 5000 -m wfmConnectWirelessSilently

connected=0
for _ in 1 2 3 4 5 6 7 8 9 10; do
    if ping -c1 -W2 8.8.8.8 >/dev/null 2>&1; then
        connected=1
        break
    fi
    sleep 1
done

if [ "$connected" -ne 1 ]; then
    echo "Error: no internet connection detected. Is this Wi-Fi network known to the Kobo?"
    exit 1
fi

files=$(find "$screenshot_path" -maxdepth 1 -type f -name "*.png")

if [ -z "$files" ]; then
    echo "No screenshot found, sorry."
    exit 0
fi

sent=0
failed=0
for screenshot in $files; do
    if "$SCRIPTPATH/curl" -sf -o /dev/null \
        "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendPhoto" \
        -F "chat_id=${CHAT_ID}" \
        -F "photo=@${screenshot}"; then
        sent=$((sent + 1))
    else
        failed=$((failed + 1))
        echo "Upload failed for $(basename "$screenshot"): check the Telegram credentials and the connection."
    fi
done

if [ "$sent" -gt 0 ]; then
    "$QNDB" -m wfmSetAirplaneMode --enable
    "$QNDB" -m mwcToast 3000 "Sent ${sent} screenshot(s). Wi-Fi turned off."
fi

if [ "$failed" -gt 0 ]; then
    exit 1
fi
exit 0
