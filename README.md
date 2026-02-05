# Zoom Meeting SDK for Linux Headless Sample

This sample demonstrates how you can run the Zoom Meeting SDK for Linux within a Docker container and configure it for a
variety of use cases through an intuitive CLI or through a configuration file.

## Prerequisites

1. [Docker](https://www.docker.com/)
1. [Zoom Account](https://support.zoom.us/hc/en-us/articles/207278726-Plan-Types-)
1. [Zoom Meeting SDK Credentials](#config:-sdk-credentials) (Instructions below)
    1. Client ID
    1. Client Secret
1. [AssemblyAI Key](https://www.assemblyai.com/)
1. [Anthropic Key](https://www.anthropic.com/)

## 1. Clone the Repository

```bash
# Clone down this repository
git clone git@github.com:zoom/meetingsdk-headless-linux-sample.git
```

## 2. Download the Zoom Linux SDK

**Option A – Setup script (recommended)**  
On your host machine, run:

```bash
./scripts/setup-zoomsdk.sh
```

This opens the Zoom Marketplace and prints instructions. After you download the Linux SDK (e.g. `zoom-meeting-sdk-linux_x86_64-*.tar`), run:

```bash
./scripts/setup-zoomsdk.sh ~/Downloads/zoom-meeting-sdk-linux_x86_64-5.x.x.x.tar
```

The script will extract the archive into [lib/zoomsdk](lib/zoomsdk).

**Option B – Manual**  
Download the Zoom Meeting SDK for Linux from the [Zoom Marketplace](https://marketplace.zoom.us/) (your app → Download → Linux), extract the archive, and copy all extracted files into the [lib/zoomsdk](lib/zoomsdk) folder.

## 3. Configure the App

### Zoom App Setup (Marketplace)

In the [Zoom Developer Portal](https://marketplace.zoom.us/), open your **Meeting SDK** app and complete:

1. **Open your app** (signed in with the Zoom account that owns the app):
   - [Your app – Build / Test](https://marketplace.zoom.us/develop/applications/hUTy6lMDRN-E9uR8P7XSBQ/test?mode=dev)

2. **App credentials**
   - **App Credentials** (or **Basic Information**): confirm **Client ID** and **Client Secret** match what you use in `config.toml`.

3. **Features / scopes**
   - Ensure the app type is **Meeting SDK** (not only OAuth or other types).
   - Enable any **Meeting SDK** or “Join meeting”–related feature if your app has toggles.

4. **Development vs production**
   - In **development**, the bot can join only meetings **hosted by the same Zoom account** that owns the app (MeetingFailCode 8 or 63 otherwise).
   - To join meetings from any host, **publish** the app and switch to **production** credentials in `config.toml`.

5. **Save** any changes before running the bot.

If you don't already have them, follow the section on how
to [Get your Zoom Meeting SDK Credentials](#get-your-zoom-meeting-sdk-credentials).


#### Copy the sample config file

```bash
cp sample.config.toml config.toml
```

#### Fill out the config.toml

Here, you can set any of the CLI options so that the app has them available when it runs. Start by adding your Client ID and Client Secret in the relevant fields.

**At a minimum, you need to provide an Client ID and Client Secret along with information about the meeting you would like to join.**

You can either provide a Join URL, or a Meeting ID and Password.

### Continue setup (after Marketplace authentication)

1. **Install the Zoom Linux SDK** (required once). Download the Linux SDK from your app in the [Marketplace](https://marketplace.zoom.us/develop/applications) (your app → Download → Linux). Then from the project root:
   ```bash
   ./scripts/setup-zoomsdk.sh ~/Downloads/zoom-meeting-sdk-linux_x86_64-5.x.x.x.tar
   ```
   (Use the actual filename you downloaded.)

2. **Start the meeting** with the same Zoom account that owns the Meeting SDK app (in development the bot can only join that account’s meetings).

3. **Run the app** (see [Run the App](#4-run-the-app) below).

## 4. Run the App

Run the Docker container in order to build and run the app

```shell
docker compose up
```

The app will authenticate with your SDK credentials, then **join the meeting** (or start it if you used a start URL). The bot appears in the meeting with the name set in `display-name` in config.toml (default: "Zoom Bot").

**Quick checklist for the bot to join:**
- `config.toml` exists (copy from `sample.config.toml`) and is in the project root
- `client-id` and `client-secret` are filled
- Either `join-url` is set (e.g. `https://zoom.us/j/MEETING_ID?pwd=PASSWORD`) or both `meeting-id` and `password` are set
- `display-name` is set (optional; defaults to "Zoom Bot")

You can use the `--help` argument in [entry.sh](bin/entry.sh) to see the available CLI and config.toml options.

### Recording output and playback

After a run, the bot writes to `out/`:

- **out/meeting-video.mp4** – Color video (H.264).
- **out/meeting-audio.pcm** – Raw PCM audio (no header). To get a playable file and a single file with both video and audio, run:
  ```bash
  ./scripts/convert-recorded.sh
  ```
  This creates `out/meeting-audio.wav` and `out/meeting-with-audio.mp4` (default 32 kHz). If the audio is too fast, try `./scripts/convert-recorded.sh 16000`; if too slow, try `./scripts/convert-recorded.sh 48000`.

___
### Get your Zoom Meeting SDK Credentials

In your web browser, navigate to [Zoom Developer Portal](https://developers.zoom.us/) and register/log into your
developer account.

Click the "Build App" button at the top and choose to "Meeting SDK" application.

1. Name your app
2. Choose whether to list your app on the marketplace or not
3. Click "Create"
4. Fill out the prerequisite information
5. Copy the Client ID and Client Secret to the config.toml file

For more information, you can follow [this guide](https://developers.zoom.us/docs/meeting-sdk/developer-accounts/)

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

Make sure to review [our documentation](https://developers.zoom.us/docs/meeting-sdk/linux/) as a reference when building
with the Zoom Meeting SDK for Linux.
