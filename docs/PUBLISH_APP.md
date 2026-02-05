# Publishing your Zoom Meeting SDK app

To join **external** meetings (host ≠ app owner) with dev credentials you currently get **MeetingFailCode 63**. Publishing (submitting for review and getting approved) your Meeting SDK app can allow the bot to join external meetings.

## Two app types in Zoom

1. **Classic Meeting SDK app** — Used by this headless sample. Has **Client ID + Client Secret** (e.g. in `config.toml`). Created via **Develop → Build App → Meeting SDK** (or legacy flow). Used for bots that join meetings (Linux SDK, etc.).
2. **Zoom App (Build flow)** — Newer “Build your app” flow with Features (Access, Surface, **Embed**/Meeting SDK, Connect), App Listing, etc. Also has Development/Production credentials.

Your **config.toml** uses `client-id="6gMe9aY8R8OG1pqsmTFBBg"`. That app is **General app 446** in the Zoom Marketplace (Build flow). Its Production Client ID (after publish) will be different; you’ll switch to production credentials in `config.toml` after approval.

**App Submission (General app 446):**  
https://marketplace.zoom.us/develop/applications/hUTy6lMDRN-E9uR8P7XSBQ/publish?mode=prod

## Where to find your app and publish

### If your app is in “Created apps” (Build flow)

1. Go to [marketplace.zoom.us](https://marketplace.zoom.us) → **Develop** (top) → **Build app** → you’ll see **Created apps**.
2. Open the app that has the **same Client ID** as in your `config.toml` (or the one you use for the headless bot).
3. Switch to the **Production** tab.
4. In the left sidebar, open **“Publish your app”** → **App Submission**.
5. Complete all **required** items listed there:
   - **Basic Information** (e.g. developer contact)
   - **Scopes**
   - **App Listing** (App Information, Links & Support, EU & Discoverability)
   - **Technical Design**
6. When all checks pass, use the **Submit** (or equivalent) action on the App Submission page. Zoom will run a [functional and security review](https://developers.zoom.us/docs/build-flow/submitting-apps-for-review/).

### If your app is a legacy Meeting SDK app

Legacy Meeting SDK apps may appear under a different list or URL (e.g. **Develop → Your apps** or an older “Applications” view). Look for the app whose **App credentials** match your `config.toml` Client ID. Once you open that app, look for:

- **Publish**, **Submit for review**, or **App distribution**
- A **Production** credentials / publish section

Zoom’s [submitting apps for review](https://developers.zoom.us/docs/build-flow/submitting-apps-for-review/) and [Meeting SDK feature review requirements](https://developers.zoom.us/docs/distribute/sdk-feature-review-requirements/) describe what’s needed for review.

## App we opened in the browser

We opened the **“SDK”** app (Build flow) at:

- **App Submission:**  
  https://marketplace.zoom.us/develop/applications/0ptL9pXXRM2e52iI-3e9VA/publish?mode=prod

That app has **different** credentials (e.g. Client ID `h7iS1GaSnSIPoylk60uA` in Development) than your `config.toml` (`6gMe9aY8R8OG1pqsmTFBBg`). So:

- To publish **that** Zoom App: complete the required sections on the App Submission page above and submit.
- To publish the **app used by this sample**: find the app with Client ID `6gMe9aY8R8OG1pqsmTFBBg` in the Marketplace and use its publish/App Submission flow.

## After approval

Once Zoom approves your app, you’ll get **production** credentials. Update `config.toml` with the production **Client ID** and **Client Secret** from the app’s Production credentials in the Marketplace. Then the bot should be able to join external meetings (subject to Zoom’s current policies; OBF/ZAK may still be required in some cases).

## Progress (General app 446)

- **Basic Information:** Developer contact (Dmitry Grankin, dmitry@vexa.ai) and Production OAuth Redirect URL (`https://vexa.ai/oauth/zoom/callback`) filled. Change the redirect URL if your production callback lives elsewhere.
- **Scopes:** Scope description added for ZAK/OBF use. `user:read:zak` and `zoomapp:inmeeting` are present.
- **Still required for submit:** App Listing (App Information, Links & Support, EU & Discoverability) and Technical Design. Open each link on the [App Submission page](https://marketplace.zoom.us/develop/applications/hUTy6lMDRN-E9uR8P7XSBQ/publish?mode=prod) and complete the fields (app name, description, privacy policy URL, support URL, etc.).

## How long does review take?

Zoom does not publish a fixed SLA. In practice, review often completes in **about 5–10 business days** (sometimes less); first-time or complex apps can take up to ~2 weeks. You’ll get email updates. You can specify a **preferred publish date** in the review notes when submitting.

- [How long does the App Review Process take?](https://developers.zoom.us/blog/how-long-does-app-review-take/)
- [App Review Process](https://developers.zoom.us/docs/distribute/app-review-process/)

## References

- [Submitting apps for review](https://developers.zoom.us/docs/build-flow/submitting-apps-for-review/)
- [Meeting SDK feature review & requirements](https://developers.zoom.us/docs/distribute/sdk-feature-review-requirements/)
- [App distribution](https://developers.zoom.us/docs/distribute/)
