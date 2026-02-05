# Zoom Meeting SDK for Linux Headless Sample

This sample demonstrates how you can run the Zoom Meeting SDK for Linux within a Docker container and configure it for a
variety of use cases through an intuitive CLI or through a configuration file.

## Prerequisites

1. [Docker](https://www.docker.com/)
1. [Zoom Account](https://support.zoom.us/hc/en-us/articles/207278726-Plan-Types-)
1. [Zoom Meeting SDK Credentials](#2-set-up-your-app-on-the-zoom-marketplace) (Instructions below)
    1. Client ID
    1. Client Secret
1. [AssemblyAI Key](https://www.assemblyai.com/)
1. [Anthropic Key](https://www.anthropic.com/)

## 1. Clone the Repository

```bash
# Clone down this repository
git clone git@github.com:zoom/meetingsdk-headless-linux-sample.git
```

## 2. Set up your app on the Zoom Marketplace

You must create a **Meeting SDK** app in the Zoom Marketplace and get credentials before running this sample. Follow this flow exactly.

### Step 1: Create a Meeting SDK app

1. Log in to the [Zoom App Marketplace](https://marketplace.zoom.us/) with your Zoom account.
2. Go to **Develop** → **Build App** (or click **Develop** in the top nav, then **Build App**).
3. Choose **Meeting SDK** as the app type (not OAuth or other types).
4. Click **Create**.
5. Enter an **App name** and choose whether to list the app on the marketplace. Click **Create**.

### Step 2: Configure the app and permissions

1. In your app’s dashboard, complete any **prerequisite** or **App credentials** steps if prompted.
2. Ensure the app is configured as a **Meeting SDK** app (e.g. under **App type** or **Features** it should show Meeting SDK, not only OAuth).
3. If there are toggles for **Meeting SDK** or “Join meeting”–related features, enable them so the SDK can join meetings.
4. **Save** any changes.

### Step 3: Get your credentials

1. Open the **App credentials** (or **Basic Information**) section of your app.
2. Copy the **Client ID** and **Client Secret**.  
   These are your **development** credentials. You will put them in `config.toml` in [Configure the app](#4-configure-the-app).

### Step 4: Development vs production

- **Development:** The bot can join only meetings **hosted by the Zoom account that owns the app**. If you try to join another account’s meeting, you may see MeetingFailCode 8 or 63.
- **Production:** To join meetings from any host, submit your app for review, get it approved, then switch to **production** credentials in the Marketplace and in `config.toml`.

When testing, start or host the meeting with the **same Zoom account** that owns the Meeting SDK app.

For more detail, see Zoom’s [Get credentials](https://developers.zoom.us/docs/meeting-sdk/get-credentials/) and [Meeting SDK](https://developers.zoom.us/docs/meeting-sdk/linux/) docs.

---

## 3. Download the Zoom Linux SDK

The Linux SDK is tied to your Marketplace app. You download it from **your app** in the Marketplace.

**Option A – Setup script (recommended)**

1. From the project root, run:
   ```bash
   ./scripts/setup-zoomsdk.sh
   ```
   This opens the Zoom Marketplace and prints instructions.
2. In the Marketplace, open **Develop** → **Your apps** → your Meeting SDK app → **Download** → choose **Linux** and download the archive (e.g. `zoom-meeting-sdk-linux_x86_64-5.x.x.x.tar`).
3. Run the script with the path to the downloaded file:
   ```bash
   ./scripts/setup-zoomsdk.sh ~/Downloads/zoom-meeting-sdk-linux_x86_64-5.x.x.x.tar
   ```
   The script extracts the archive into [lib/zoomsdk](lib/zoomsdk).

**Option B – Manual**

Download the Zoom Meeting SDK for Linux from your app in the [Zoom Marketplace](https://marketplace.zoom.us/develop/applications) (your app → **Download** → **Linux**). Extract the archive and copy all extracted files into [lib/zoomsdk](lib/zoomsdk).

## 4. Configure the App

#### Copy the sample config file

```bash
cp sample.config.toml config.toml
```

#### Fill out config.toml

Set at least:

- **client-id** and **client-secret** – from your Meeting SDK app’s [App credentials](#step-3-get-your-credentials).
- **Meeting to join** – either **join-url** (e.g. `https://zoom.us/j/MEETING_ID?pwd=PASSWORD`) or both **meeting-id** and **password**.
- **display-name** (optional; default is `"Zoom Bot"`).

You can set any other CLI options in `config.toml` as needed; see [entry.sh](bin/entry.sh) `--help` for all options.

## 5. Run the App

Run the Docker container in order to build and run the app

```shell
docker compose up
```

The app will authenticate with your SDK credentials, then **join the meeting** (or start it if you used a start URL). The bot appears in the meeting with the name set in `display-name` in config.toml (default: "Zoom Bot").

**Quick checklist for the bot to join:**
- [Marketplace app](#2-set-up-your-app-on-the-zoom-marketplace) created (Meeting SDK), credentials in `config.toml`
- [Linux SDK](#3-download-the-zoom-linux-sdk) installed under `lib/zoomsdk`
- `config.toml` exists (copy from `sample.config.toml`) with `client-id`, `client-secret`, and either `join-url` or `meeting-id` + `password`
- Meeting is hosted by the same Zoom account that owns the app (when using development credentials)

**Join with ZAK (as host):** To join or start a meeting as the host using a ZAK token, see [Run with ZAK token](docs/RUN_WITH_ZAK.md). Use `--zak YOUR_ZAK` or set `zak="..."` in config; obtain ZAK via the OAuth app (scope `user:read:zak`) and [scripts/get-zak.sh](scripts/get-zak.sh).

You can use the `--help` argument in [entry.sh](bin/entry.sh) to see the available CLI and config.toml options.

### Recording output and playback

After a run, the bot writes to `out/`:

- **out/meeting-video.mp4** – Color video (H.264).
- **out/meeting-audio.pcm** – Raw PCM audio (no header). To get a playable file and a single file with both video and audio, run:
  ```bash
  ./scripts/convert-recorded.sh
  ```
  This creates `out/meeting-audio.wav` and `out/meeting-with-audio.mp4` (default 32 kHz). If the audio is too fast, try `./scripts/convert-recorded.sh 16000`; if too slow, try `./scripts/convert-recorded.sh 48000`.

### Keeping secrets secret

Remember, credentials should never be stored in a plaintext file for production use cases.

> :warning: **Never commit config.toml to version control:** The file likely contains Zoom SDK and Zoom OAuth
> Credentials

### Testing

At this time there are no tests.

## Need help?

If you're looking for help, try [Developer Support](https://devsupport.zoom.us) or
our [Developer Forum](https://devforum.zoom.us). Priority support is also available
with [Premier Developer Support](https://zoom.us/docs/en-us/developer-support-plans.html) plans.

### Documentation

- [Zoom Meeting SDK for Linux](https://developers.zoom.us/docs/meeting-sdk/linux/) — official reference when building with the SDK.
- [Joining options and limitations (OBF, ZAK, RTMS)](docs/ZOOM_JOIN_OPTIONS_RESEARCH.md) — research document on how to join any meeting (if allowed by host), token options, and how companies like Recall.ai and Fireflies integrate with Zoom.
- [Run with ZAK token](docs/RUN_WITH_ZAK.md) — join or start as host using a ZAK token.
- [Run with OBF token](docs/RUN_WITH_OBF.md) — join on behalf of a user who is in the meeting (e.g. dmitry@vexa.ai).
