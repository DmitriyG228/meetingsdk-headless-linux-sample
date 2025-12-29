# Setup Instructions

## Current Status

✅ Repository cloned
✅ Config file created with your Zoom credentials

## Next Steps Required

### 1. Download Zoom Meeting SDK for Linux

The Zoom SDK must be downloaded manually from the Zoom Marketplace:

1. **Visit Zoom Marketplace**: https://marketplace.zoom.us/
2. **Sign in** with your Zoom account
3. **Navigate to**: Develop → Build App → Meeting SDK
4. **Download** the latest Linux version of the SDK
5. **Extract** the downloaded archive
6. **Copy contents** to `lib/zoomsdk/`:
   ```bash
   cd /Users/dmitriygrankin/dev/meetingsdk-headless-linux-sample
   # Extract the SDK archive you downloaded
   # Then copy all contents to lib/zoomsdk/
   cp -r /path/to/extracted/sdk/* lib/zoomsdk/
   ```

The SDK should include:
- `libmeetingsdk.so` (main library file)
- `h/` directory (header files)
- `qt_libs/` directory (Qt libraries)
- Other supporting files

### 2. Configure Meeting Details

Edit `config.toml` and add either:
- A `join-url` for the meeting, OR
- A `meeting-id` and `password`

Example:
```toml
join-url="https://zoom.us/j/123456789?pwd=abcdef"
```

Or:
```toml
meeting-id="123456789"
password="abcdef"
```

### 3. Run the Application

Once the SDK is in place, run:
```bash
docker compose up
```

The container will:
- Build the C++ application
- Set up PulseAudio for audio
- Start the Zoom Meeting SDK client

## Troubleshooting

### SDK Not Found
If you see errors about missing SDK files, ensure:
- `lib/zoomsdk/libmeetingsdk.so` exists
- `lib/zoomsdk/h/` directory contains header files
- All SDK files are properly extracted

### Audio Issues
The Docker container sets up PulseAudio automatically. If you encounter audio issues:
- Check that the container has proper permissions
- Verify PulseAudio is running inside the container

### Build Errors
If CMake fails:
- Ensure all dependencies are installed (handled by Dockerfile)
- Check that vcpkg packages are available
- Verify the SDK structure matches expected layout





