# Kobo Screenshot Uploader

Upload the screenshots taken on your Kobo e-reader to a private Telegram chat with one tap, from the main menu, the library, the reader or the browser.

Tapping `send_screenshots` in [NickelMenu](https://github.com/pgaskin/NickelMenu) runs `send.sh`, which:

1. turns Wi-Fi on silently,
2. waits for a connection,
3. uploads every `*.png` in the root of the internal storage through the Telegram Bot API,
4. turns Wi-Fi off again and shows a confirmation toast.

## Requirements

- A Kobo e-reader with [NickelMenu](https://github.com/pgaskin/NickelMenu) installed. Use the **latest NickelMenu release**: older versions do not work on newer devices/firmware (Clara 2E and later).
- The ARM binary of [qndb](https://github.com/pgaskin/qndb) (used to control Wi-Fi and show toasts).
- A Telegram bot token (from [@BotFather](https://t.me/BotFather)) and your chat ID (from [@getmyid_bot](https://t.me/getmyid_bot)).

## Installation

1. Download the latest [release zip](https://github.com/luke-gto/kobo-screenshot-uploader/releases) and extract it to the **root** of the Kobo internal storage while connected over USB. You should end up with:
   - `.adds/nm/screenshot_upload` — the NickelMenu menu entries
   - `.adds/screenshot_upload/` — the script, the bundled `curl` binary and the config file
2. Download the ARM (`arm`) `qndb` binary from the [qndb releases](https://github.com/pgaskin/qndb/releases) and copy it to `.adds/screenshot_upload/qndb`.
3. Edit `.adds/screenshot_upload/telegram.config` (note the **underscore** in the folder name) and paste your bot token and chat ID:

   ```
   TELEGRAM_BOT_TOKEN="123456789:AA..."
   CHAT_ID="123456789"
   ```

4. Safely eject the Kobo. `send_screenshots` now appears in the NickelMenu menus; tap it to upload your screenshots. An internet connection (a Wi-Fi network already configured on the Kobo) is required.

## Troubleshooting

- **`send_screenshots` does not appear in the menu**: NickelMenu itself is missing or too old for your device (this is the most common cause on Clara 2E and newer), or the menu config is not at `.adds/nm/screenshot_upload`. Update NickelMenu, check the path, and reboot the Kobo.
- **"Invalid Telegram credentials"**: the config still contains the placeholders, or you edited a different file. The config lives in `.adds/screenshot_upload/telegram.config`.
- **"qndb not found"**: step 2 of the installation was skipped.
- **"no internet connection detected"**: the script only reconnects silently to networks the Kobo already knows; it cannot configure a new one. Connect once from the Kobo settings first.
- Any other failure is printed in the NickelMenu dialog that shows the script output.

## Repository layout and development

- `nm/screenshot_upload` — the NickelMenu menu config shipped as `.adds/nm/screenshot_upload`
- `screenshot_upload/` — the payload shipped as `.adds/screenshot_upload/` (`send.sh`, the ARM `curl` binary, the config template)

`send.sh` is plain POSIX shell (it runs under busybox ash on the Kobo). For off-device testing the scanned directory can be overridden with the `SCREENSHOT_DIR` environment variable.

The bundled `curl` binary and `qndb` are separate projects with their own licenses; everything else is BSD-3-Clause, see [LICENSE](LICENSE).
