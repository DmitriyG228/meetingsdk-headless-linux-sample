# Download Zoom Meeting SDK for Linux - Automated Guide

## Overview
This guide will help you download the Zoom Meeting SDK for Linux using browser automation.

## Steps to Download

Based on the official documentation, follow these steps:

1. **Navigate to Zoom App Marketplace**
   - Go to: https://marketplace.zoom.us/
   - Sign in with your Zoom account

2. **Access Developer Section**
   - Click "Develop" in the top-right corner
   - Select "Build App"

3. **Access Your Meeting SDK App**
   - If you haven't created an SDK app:
     - Select "Create" in the SDK section
     - Choose "Meeting SDK" application type
     - Fill out the required information
   - If you have created an SDK app:
     - Select "View here" to access your existing app

4. **Download Linux SDK**
   - In your app's page, select "Linux" platform
   - Click "Download" button in the upper-right corner (next to "Release Note" button)

5. **Extract and Install**
   - Extract the downloaded TAR file
   - Copy all contents to `lib/zoomsdk/` directory:
     ```bash
     cd /Users/dmitriygrankin/dev/meetingsdk-headless-linux-sample
     tar -xzf /path/to/downloaded/zoom-meeting-sdk-linux_x86_64-*.tar.gz
     cp -r zoom-meeting-sdk-linux_x86_64-*/* lib/zoomsdk/
     ```

## Expected File Structure

After extraction, `lib/zoomsdk/` should contain:
- `h/` - Header files directory
- `lib*.so` - Meeting SDK libraries (including `libmeetingsdk.so`)
- `qt_libs/` - Dependency libraries folder
- Other supporting files

## Verification

Run the setup check script:
```bash
./check-setup.sh
```

This will verify that all required SDK files are in place.

## Troubleshooting

If the download link requires authentication or you encounter issues:
1. Make sure you're signed in to your Zoom account
2. Ensure you have a Meeting SDK app created in the marketplace
3. Check that your app has the necessary permissions
4. Try accessing the marketplace directly: https://marketplace.zoom.us/user/build

## Alternative: Manual Download

If browser automation doesn't work, you can manually:
1. Open https://marketplace.zoom.us/ in your browser
2. Sign in and follow the steps above
3. Download the SDK TAR file
4. Extract and copy to `lib/zoomsdk/` as described





