# Run the app with an OBF (On-Behalf-Of) token

OBF lets the bot **join a meeting on behalf of a user** who is in the call (the "chaperone"). Use it to join any meeting where that user is a participant and the host allows the bot (e.g. admits from waiting room).

**Important:** The user whose OAuth tokens you use (e.g. dmitry@vexa.ai) must **be in the meeting** when the bot joins. If they leave, the bot is disconnected.

**OBF is per meeting and valid ~2 hours** — obtain it shortly before joining (with the correct `meeting_id`).

**Using an existing OAuth app:** You can use the same OAuth app as for ZAK. It must have scope **`user:read:token`** (View a user's token). Add it under Scopes if you only had `user:read:zak` before. The authorize URL must include `scope=user:read:token` (and optionally `user:read:zak` if you use both).

## 1. Zoom OAuth app (one-time)

Use your existing **OAuth** app (the one you use for ZAK) or create one:

1. [marketplace.zoom.us](https://marketplace.zoom.us/) → **Develop** → **Build App** → **OAuth**.
2. Set **Redirect URL** (e.g. `http://localhost:8080/callback`).
3. Under **Scopes**, add **`user:read:token`** (View a user's token).
4. Copy **Client ID** and **Client Secret**.

## 2. Get a refresh token for the participant (one-time per user)

The **participant** who will be in the meeting (e.g. **dmitry@vexa.ai**) must authorize your app once. You will get a **refresh token** for that Zoom user.

**Authorize URL** (use **URL-encoded** redirect_uri and scope):

- Scopes for OBF only: `user:read:token`
- Example (replace `YOUR_OAUTH_CLIENT_ID` with your OAuth app Client ID):

```
https://zoom.us/oauth/authorize?response_type=code&client_id=YOUR_OAUTH_CLIENT_ID&redirect_uri=http%3A%2F%2Flocalhost%3A8080%2Fcallback&scope=user:read:token
```

**Steps:**

1. Open the authorize URL in a browser.
2. Sign in as the **participant** (e.g. dmitry@vexa.ai) and approve.
3. Zoom redirects to `http://localhost:8080/callback?code=...` — copy the `code`.
4. Exchange the code for tokens:

   ```bash
   curl -s -X POST "https://zoom.us/oauth/token" \
     -u "YOUR_OAUTH_CLIENT_ID:YOUR_OAUTH_CLIENT_SECRET" \
     -d "grant_type=authorization_code" \
     -d "code=THE_CODE_FROM_REDIRECT" \
     -d "redirect_uri=http://localhost:8080/callback"
   ```

5. Save **`refresh_token`** from the JSON response. Use it with `get-obf.sh` for that user.

**Example authorize URL** (OAuth app Client ID `60dwGbk7QdKPoQaSPg3sxg`, scope `user:read:token` only):

```
https://zoom.us/oauth/authorize?response_type=code&client_id=60dwGbk7QdKPoQaSPg3sxg&redirect_uri=http%3A%2F%2Flocalhost%3A8080%2Fcallback&scope=user:read:token
```

## 3. Get an OBF token (per meeting)

OBF is **per meeting**. You need the **meeting ID** (numeric, e.g. from the join URL: `https://zoom.us/j/82699598461` → meeting ID `82699598461`).

From the project root:

```bash
chmod +x scripts/get-obf.sh

MEETING_ID=82699598461 \
ZOOM_CLIENT_ID="your_oauth_client_id" \
ZOOM_CLIENT_SECRET="your_oauth_client_secret" \
ZOOM_REFRESH_TOKEN="refresh_token_of_participant_e.g_dmitry_vexa_ai" \
./scripts/get-obf.sh
```

The script prints the **OBF token** to stdout. It is valid for **about 2 hours** for that meeting only.

## 4. Launch the app with OBF

**Option A – Pass OBF on the command line**

```bash
MEETING_ID=82699598461
OBF=$(ZOOM_CLIENT_ID="..." ZOOM_CLIENT_SECRET="..." ZOOM_REFRESH_TOKEN="..." MEETING_ID=$MEETING_ID ./scripts/get-obf.sh)
docker compose run --rm app ./bin/entry.sh --on-behalf "$OBF"
```

Or with a local build:

```bash
OBF=$(MEETING_ID=82699598461 ./scripts/get-obf.sh)   # after exporting OAuth env vars
./bin/entry.sh --on-behalf "$OBF"
```

**Option B – Put OBF in config.toml**

Add to `config.toml` (get a fresh OBF for the meeting first):

```toml
on-behalf="eyJ..."
```

Then run as usual: `docker compose up` or `./bin/entry.sh`.

## Checklist

- [ ] Meeting SDK app credentials in `config.toml` (`client-id`, `client-secret`).
- [ ] Zoom OAuth app with scope **user:read:token**.
- [ ] Refresh token obtained for the Zoom **participant** who will be in the meeting (e.g. dmitry@vexa.ai).
- [ ] **Participant joins the meeting first** (or joins before/with the bot).
- [ ] OBF obtained for the **same meeting_id** you are joining; pass via `--on-behalf` or `on-behalf=` in config.

For more on OBF, ZAK, and join options, see [ZOOM_JOIN_OPTIONS_RESEARCH.md](ZOOM_JOIN_OPTIONS_RESEARCH.md).
