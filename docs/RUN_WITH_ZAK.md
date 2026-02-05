# Run the app with a ZAK token

ZAK (Zoom Access Key) lets the bot **join or start a meeting as the host** (or as the authenticated user). Use it when you need to join as host, start a meeting, or when the meeting has "Only signed-in users" and you join as that user.

**ZAK expires in ~5 minutes** — obtain it right before joining.

**Using an existing OAuth app:** Ensure it has **Redirect URL** `http://localhost:8080/callback` (Basic Information) and **scope** `user:read:zak` (Scopes → "View a user's Zoom Access Key"). The authorize URL you open in the browser must include `&scope=user:read:zak`.

## 1. Create a Zoom OAuth app (one-time)

You need a **separate** Zoom **OAuth** app (in addition to your Meeting SDK app) to get ZAK.

1. Go to [marketplace.zoom.us](https://marketplace.zoom.us/) → **Develop** → **Build App**.
2. Choose **OAuth** (not Meeting SDK). Create the app.
3. In the app:
   - Set **Redirect URL** (e.g. `http://localhost:8080/callback` for local testing).
   - Under **Scopes**, add **`user:read:zak`** (Zoom Access Key).
   - Copy the **Client ID** and **Client Secret** (OAuth app credentials, not the Meeting SDK ones).

## 2. Get a refresh token (one-time per user)

The first time, you need to complete the OAuth flow to get a **refresh token** for the Zoom user (typically the host).

**Required:** The OAuth app must have these scopes in the Marketplace (Develop → your app → **Scopes**): **`user:read:zak`** (View a user's Zoom Access Key) and **`user:read:token`** (View a user's token). The Zoom API that returns the ZAK requires both. The **authorize URL** must include **`scope=user:read:zak user:read:token`** so Zoom prompts for both permissions.

**Option A – Manual in browser**

1. Build the authorize URL (use **URL-encoded** redirect_uri):
   - Redirect URI: `http://localhost:8080/callback` → encoded: `http%3A%2F%2Flocalhost%3A8080%2Fcallback`
   - **Scopes:** `user:read:zak` and `user:read:token` (both required for the ZAK API)
   ```
   https://zoom.us/oauth/authorize?response_type=code&client_id=YOUR_OAUTH_CLIENT_ID&redirect_uri=http%3A%2F%2Flocalhost%3A8080%2Fcallback&scope=user:read:zak%20user:read:token
   ```
   Replace `YOUR_OAUTH_CLIENT_ID` with your OAuth app’s Client ID (e.g. from Basic Information in the Marketplace).
2. Open that URL in a browser. Sign in to Zoom (as the user who will host meetings) and approve. Zoom redirects to `http://localhost:8080/callback?code=...` — copy the `code` from the URL (the page may show "connection refused"; the code is in the address bar).
3. Exchange the code for tokens (run in terminal, replace placeholders; use the **same** redirect_uri as in step 1):
   ```bash
   curl -s -X POST "https://zoom.us/oauth/token" \
     -u "YOUR_OAUTH_CLIENT_ID:YOUR_OAUTH_CLIENT_SECRET" \
     -d "grant_type=authorization_code" \
     -d "code=THE_CODE_FROM_REDIRECT" \
     -d "redirect_uri=http://localhost:8080/callback"
   ```
4. From the JSON response, save **`refresh_token`** (and optionally `access_token`). You will use `refresh_token` with the script below.

**Example authorize URL** (with redirect `http://localhost:8080/callback` and scopes `user:read:zak` and `user:read:token`; replace the client_id with your OAuth app’s Client ID):
```
https://zoom.us/oauth/authorize?response_type=code&client_id=60dwGbk7QdKPoQaSPg3sxg&redirect_uri=http%3A%2F%2Flocalhost%3A8080%2Fcallback&scope=user:read:zak%20user:read:token
```

**Option B – Use a small local callback server**

Run a local HTTP server that serves your redirect_uri, then open the authorize URL; when Zoom redirects back, the server can print the code so you can exchange it for tokens.

## 3. Get a ZAK token

From the project root, run the helper script. It uses your **refresh token** to get an access token, then calls Zoom to get a ZAK.

```bash
chmod +x scripts/get-zak.sh

ZOOM_CLIENT_ID="your_oauth_client_id" \
ZOOM_CLIENT_SECRET="your_oauth_client_secret" \
ZOOM_REFRESH_TOKEN="your_refresh_token" \
./scripts/get-zak.sh
```

The script prints the **ZAK** to stdout. It is valid for **about 5 minutes**.

## 4. Launch the app with ZAK

**Option A – Pass ZAK on the command line**

```bash
ZAK=$(ZOOM_CLIENT_ID="..." ZOOM_CLIENT_SECRET="..." ZOOM_REFRESH_TOKEN="..." ./scripts/get-zak.sh)
docker compose run --rm app ./bin/entry.sh --zak "$ZAK"
```

Or with a local build (no Docker):

```bash
ZAK=$(./scripts/get-zak.sh)   # after exporting OAuth env vars
./bin/entry.sh --zak "$ZAK"
```

**Option B – Put ZAK in config.toml**

Add a line to `config.toml` (get a fresh ZAK first; it expires in ~5 min):

```toml
zak="eyJ..."
```

Then run as usual: `docker compose up` or `./bin/entry.sh`.

## Checklist

- [ ] Meeting SDK app credentials in `config.toml` (`client-id`, `client-secret`) — same as usual.
- [ ] Zoom OAuth app created with scope **user:read:zak**.
- [ ] Refresh token obtained for the Zoom user who will host (or start) the meeting.
- [ ] Meeting to join is one that **this user** hosts or can start (ZAK is for that user).
- [ ] ZAK obtained right before run (script or manual API call); pass via `--zak` or `zak=` in config.

For more on ZAK, OBF, and join options, see [ZOOM_JOIN_OPTIONS_RESEARCH.md](ZOOM_JOIN_OPTIONS_RESEARCH.md).
