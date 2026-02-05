# Zoom Meeting SDK: Joining Options and Limitations — Research Document

This document summarizes how to join Zoom meetings with a bot (Meeting SDK), the limitations of SDK-only credentials, and the options to access **any** meeting when allowed by the host: OBF, ZAK, Join Token for Local Recording, and RTMS. It also covers how companies like Recall.ai and Fireflies integrate with Zoom, and how to create and use a Zoom OAuth app.

---

## Table of contents

1. [The limitation](#1-the-limitation)
2. [Solutions (1–7)](#2-solutions-17)
3. [Products (1–7)](#3-products-17)
4. [Product P uses Solution S (mapping matrix)](#4-product-p-uses-solution-s-mapping-matrix)
5. [Options and limitations (reference table)](#5-options-and-limitations-reference-table)
6. [Which options work for “any meeting (if allowed by host)”](#6-which-options-work-for-any-meeting-if-allowed-by-host)
7. [OBF (On Behalf Of) token — detailed](#7-obf-on-behalf-of-token--detailed)
8. [ZAK (Zoom Access Key) token](#8-zak-zoom-access-key-token)
9. [Join token for local recording](#9-join-token-for-local-recording)
10. [RTMS (Realtime Media Streams)](#10-rtms-realtime-media-streams)
11. [Which option to use when](#11-which-option-to-use-when)
12. [How companies integrate with Zoom](#12-how-companies-integrate-with-zoom)
13. [Options ↔ products (mapping)](#13-options-products-mapping)
14. [Creating a Zoom OAuth app (one app per product)](#14-creating-a-zoom-oauth-app-one-app-per-product)
15. [Zoom authorization: app review and user consent](#15-zoom-authorization-app-review-and-user-consent)
16. [Support in this sample](#16-support-in-this-sample)
17. [References](#17-references)

---

## 1. The limitation

With **only** Meeting SDK **Client ID + Client Secret** (JWT auth), the bot can join **only meetings hosted by the same Zoom account that owns the app** (i.e. meetings organized/hosted by the app owner). Joining a meeting hosted by any other Zoom account fails (e.g. MeetingFailCode 8 or 63).

**Zoom policy (effective February 23, 2026):** Apps that join meetings **outside their account** must use an explicit authorization mechanism: **OBF**, **ZAK**, or **RTMS**. The date is given as **February 23, 2026** in Zoom’s transition materials and in [Recall.ai’s OBF overview](https://www.recall.ai/blog/zoom-obf); not March 2.

**Focus of this document: from February 23, 2026 onward.** From that date, joining **external** meetings (host ≠ app owner) requires **OBF**, **ZAK**, or **RTMS**; an approved Meeting SDK app (solution 2) alone is no longer sufficient for external joins. For **same-account** meetings (host = app owner), SDK-only (solution 1) and join token / ZAK / manual (3, 4, 7) remain valid.

**Non-approved Meeting SDK app + OBF:** Zoom’s messaging implies that the **token** carries the authorization (the participant or host consented via OAuth), so a Meeting SDK app that has **not** been approved for external joins may be able to join **external** meetings from **February 23, 2026** when using an **OBF token** (or ZAK). **Validation (as of Feb 2025):** Before the enforcement date, Zoom still returns **MeetingFailCode 63** (“cannot join external meeting with dev credentials”) even when a valid OBF token is supplied. After February 23, 2026, dev app + OBF may be accepted; Zoom’s OBF FAQ does not explicitly state that dev/unpublished apps can join external meetings with OBF only, so this remains an interpretation until confirmed in practice or by Zoom.

**Bottom line — testing ZAK/OBF with an unpublished app:** With a **development** (unpublished) Meeting SDK app, you **cannot** test the real use cases for OBF or ZAK (joining **external** meetings). Both tokens fail with MeetingFailCode 63 for any meeting not hosted by the Zoom account that owns the app. The only scenario you can test before publishing is: **same-account** meetings (host = app owner), which work with SDK credentials alone (no token required). So: **publish the app first** if you need to validate "join external meeting as bot (OBF)" or "join external meeting as host (ZAK)" in practice.

- [Zoom OBF FAQ](https://developers.zoom.us/docs/meeting-sdk/obf-faq/)
- [Transitioning to OBF tokens (Zoom blog)](https://developers.zoom.us/blog/transition-to-obf-token-meetingsdk-apps/)
- [Understanding the Zoom OBF token (Recall.ai)](https://www.recall.ai/blog/zoom-obf) — “Enforcement begins February 23, 2026.”

---

## 2. Solutions (1–7)

Numbered **solutions** (Zoom join/recording approaches) used in this document:

| # | Solution | Description |
|---|----------|-------------|
| **1** | **SDK credentials only** | Meeting SDK Client ID + Secret (JWT). Bot joins only meetings hosted by the app owner's account. |
| **2** | **Approved SDK app** | Same as 1, but the Meeting SDK app is approved by Zoom so the bot can join external meetings (until February 23, 2026). |
| **3** | **Join token for local recording** | Host OAuth → backend gets a per-meeting token; bot gets recording permission + bypass waiting room. |
| **4** | **ZAK token** | Host (or user) OAuth → backend gets ZAK; bot joins or starts the meeting as that user. |
| **5** | **OBF token** | Participant in meeting OAuth → backend gets OBF for that meeting; bot joins on behalf of that participant. |
| **6** | **RTMS** | No bot in meeting; user enables Zoom App; media/transcript stream to your backend (different stack). |
| **7** | **Manual host consent** | No token; host admits bot from waiting room and clicks "Allow recording" each time. **In dev mode:** join with SDK-only works only when the **meeting host is the app owner** (same Zoom account that registered the app). If host ≠ app owner, join fails (e.g. error 8) before the host can admit. |

---

## 3. Products (1–7)

Numbered **products** (examples and this sample) referred to in the mapping:

| # | Product | Description |
|---|---------|-------------|
| **1** | **Recall.ai** | Meeting bot API; customers bring their own Zoom SDK app + OAuth; Recall provides infra and token handling. |
| **2** | **Fireflies.ai** | Notetaker bot; users connect Zoom (OAuth); bot joins from calendar and records/transcribes. |
| **3** | **Otter.ai** | Notetaker (Otter Notetaker); host connects Zoom; bot joins and records when host allows. |
| **4** | **Botpress** | Transcript integration via Zoom cloud recording and webhooks (no live bot in meeting). |
| **5** | **This sample** (meetingsdk-headless-linux-sample) | Headless Linux Meeting SDK app; supports solutions 1, 3, 4, 5 via config; backend must supply tokens. |
| **6** | *(Reserved)* | — |
| **7** | *(Reserved)* | — |

---

## 4. Product P uses Solution S (mapping matrix)

**Product P uses Solution S** — each cell indicates whether product P uses solution S (✓ = yes, primary or standard; *when* = when required by scenario).

| Product (P) | Sol. 1 (SDK only) | Sol. 2 (Approved app) | Sol. 3 (Join token) | Sol. 4 (ZAK) | Sol. 5 (OBF) | Sol. 6 (RTMS) | Sol. 7 (Manual) |
|-------------|-------------------|------------------------|----------------------|--------------|--------------|---------------|------------------|
| **1 Recall.ai** | ✓ (base) | ✓ (external until 2026) | ✓ (primary: recording + bypass) | ✓ when (sign-in required; start as host) | ✓ when (from Feb 23, 2026 external) | No | Fallback |
| **2 Fireflies.ai** | ✓ (base) | ✓ | ✓ (join without host approval) | when required | when required | No | Fallback |
| **3 Otter.ai** | ✓ (base) | ✓ | ✓ (host connects → seamless) | when required | when required | No | Optional (host can allow each time) |
| **4 Botpress** | — | — | — | — | — | No | — (uses cloud recording, not bot) |
| **5 This sample** | ✓ | — | ✓ (`--join-token`) | ✓ (`--zak`) | ✓ (`--on-behalf`) | No | ✓ (no token) |

So: **Recall (1)** uses solutions **1, 2, 3, 4, 5**; **Fireflies (2)** uses **1, 2, 3** and **4, 5** when required; **Otter (3)** uses **1, 2, 3** and **4, 5** when required; **Botpress (4)** does not use Meeting SDK bot solutions (cloud only); **This sample (5)** implements **1, 3, 4, 5** and can use **7** (manual) if no token is passed. **Solution 7 (manual):** In dev mode, Sol. 7 only works when the **meeting host is the app owner**; otherwise join fails (e.g. error 8) before the host can admit.

---

## 5. Options and limitations (reference table)

| Option | What it does | Limitations | In this sample |
|--------|--------------|-------------|----------------|
| **SDK credentials only** (Client ID + Secret) | Bot joins using JWT; no user OAuth. | Can join **only meetings hosted/organized by the app owner's account**. Fails (e.g. code 8/63) for other accounts. From February 23, 2026, not sufficient for external meetings. | Default: `client-id` + `client-secret` in config. |
| **OBF token** (On Behalf Of) | Bot joins **on behalf of** a user who is in the meeting. | That user must **be in the meeting** (join first or retry); when they **leave**, the bot is **disconnected**. Token is **per meeting**, ~2 h lifetime. Requires OAuth + `user:read:token` and Get User Token API. | Supported: `--on-behalf` / `on-behalf` in config. Backend must obtain token. |
| **ZAK token** (Zoom Access Key) | Bot joins or **starts** the meeting **as the host** (or authenticated user). | ZAK is **short-lived** (~5 min). You need the **host's** OAuth and Get ZAK API. Best for "start as host" or "join as host" flows. | Supported: `--zak` / `zak` in config. Backend must obtain ZAK. |
| **Join token for local recording** | Grants **recording permission + bypass waiting room** for a specific meeting. Obtained via **host's** OAuth. | Does **not** by itself authorize **join** to external meetings (that's OBF/ZAK from 2026). Host must have local recording allowed in Zoom settings. Token is short-lived (~2 min). | Supported: `--join-token` / `join-token` in config. Use **together with** SDK creds (and OBF/ZAK when required). |
| **RTMS** (Realtime Media Streams) | User in meeting enables a Zoom App; media/transcript stream to your backend. **No bot** in the participant list. | User must be in the meeting and **opt in**. Different stack (Zoom Apps, RTMS SDK Node/Python). Not a "join as bot" flow. | Not in this repo; separate product. |

**Combinations:** For "join any meeting and record without host click": use **approved SDK app** + **OAuth** to get (a) **Join token for local recording** (host OAuth) for recording + waiting room, and (b) **OBF or ZAK** when Zoom requires it for **join** on external meetings (Feb 23, 2026+).

**Mapping to products:** Each option above corresponds to a **solution** (1–7) and is mapped to **products** (1–7) in [Section 4 (Product P uses Solution S)](#4-product-p-uses-solution-s-mapping-matrix).

There is **no** way with current Zoom policy to have a Meeting SDK app join **any** arbitrary meeting without either (a) a user in that meeting authorizing and being present (OBF), (b) the host authorizing and you joining as host (ZAK), or (c) using RTMS with user consent in-meeting.

---

## 6. Which options work for “any meeting (if allowed by host)”

| Option | Works for “any meeting (if allowed by host)”? | How “allowed by host” works |
|--------|-----------------------------------------------|-----------------------------|
| **SDK credentials only** | **No** | Only meetings hosted by the app owner. Other hosts' meetings fail. |
| **OBF token** | **Yes** | Any meeting where (1) a **participant** has authorized your app and is in the call, and (2) the host **allows** the bot (e.g. admits from waiting room, allows recording). |
| **ZAK token** | **Yes** (per host) | Any meeting **that host** organizes. "Allowed by host" = they authorized your app (you use their ZAK). Different host = need that host's OAuth/ZAK. |
| **Join token for local recording** | **Yes** (per host) | Any meeting where the **host** has authorized your app. You use their OAuth to get the join token for that meeting. |
| **RTMS** | **Yes** | Any meeting where a **user** is in the call and **enables** your Zoom App. "Allowed by host" = meeting allows Zoom Apps. |

---

## 7. OBF (On Behalf Of) token — detailed

OBF is the recommended way to have a bot join **any** meeting when a **participant** (who has authorized your app) is in the call.

**From February 23, 2026:** For **external** meetings, a **non-approved** Meeting SDK app (still in dev, not submitted for Zoom app review) **plus a valid OBF token** may be sufficient (see validation note in §1). The token carries the authorization; Zoom’s materials suggest the app itself may not need separate "approval for external joins" when OBF is used—until that date, error 63 is still observed with dev credentials + OBF.

### Roles

- **Authorizing participant (the "chaperone")** — A Zoom user who (1) has authorized your app via Zoom OAuth once, and (2) will be **in the meeting**. Your bot joins **on behalf of** this user. Can be the host or any attendee; they must actually be in the call.
- **Host** — The Zoom user who scheduled/owns the meeting. They do **not** need to OAuth your app. They only need to **allow** the bot (admit from waiting room, allow recording when prompted).
- **Your app** — Meeting SDK app (Client ID + Secret) + a backend that has the **participant's** OAuth tokens and calls Zoom to get the OBF token.

### End-to-end flow

1. **One-time:** Authorizing participant goes through your Zoom OAuth flow (redirect to Zoom, consent). You store their **access token** and **refresh token**.
2. **Before the meeting:** You know the **meeting ID** and which **user** (participant) will be in that meeting and has already authorized your app.
3. **When the participant has joined (or is about to join):** Your backend uses that participant's **access token** to call Zoom:
   ```http
   GET https://api.zoom.us/v2/users/me/token?type=onbehalf&meeting_id={meeting_id}
   Authorization: Bearer {access_token}
   ```
   Zoom returns an **OBF token** valid for that meeting only (~2 hours).
4. **Bot join:** Your backend passes the OBF token to the bot (e.g. `on-behalf="..."` in config or CLI). The bot joins with **SDK credentials + OBF token** (meeting ID, password, display name as usual).
5. **Zoom checks:** The bot is allowed to join only if the **authorizing participant is already in the meeting**. If not yet in, the join fails (retry after a few seconds).
6. **In meeting:** Host may still see a **waiting room** prompt (if enabled) and must **admit** the bot. Host may also get a **recording permission** prompt; host must **allow** for the bot to record — or you use a **join token for local recording** from the host to pre-authorize recording and bypass this.
7. **When the authorizing participant leaves:** Zoom **disconnects the bot** immediately. The bot cannot stay in the meeting without that user.

### What “host allows” means in practice

| Host setting / moment | Effect on bot |
|-----------------------|---------------|
| **Waiting room on** | Bot enters waiting room; **host must admit** the bot. Without host admit, bot never reaches the main room. |
| **Recording permission** | Bot requests permission to record; **host must click "Allow recording"** — or your app uses a **join token for local recording** from the host's OAuth to pre-authorize. |
| **Only signed-in users** | Bot is joining "on behalf of" a signed-in user (the participant whose OBF you used), so this is usually satisfied. |
| **Host not in meeting** | Bot can still join if the **authorizing participant** is in the meeting. Host does not need to be present for OBF join. |

### Token and API details

- **Scope required:** `user:read:token` (add to your Zoom OAuth app; may require app resubmission).
- **OBF token lifetime:** ~2 hours; generate **just before** the bot joins.
- **Per meeting:** Each OBF token is for **one meeting_id**. You cannot reuse it for another meeting.
- **Who can generate:** Only users who have **authorized your app** (you have their OAuth access token). You need a **mapping**: for a given meeting, which authorized user will be in it?

### Join failures and retries

- If the **authorizing participant is not in the meeting yet**, Zoom returns a join failure. From SDK 6.6.10+ there is a specific code: `MEETING_FAIL_AUTHORIZED_USER_NOT_INMEETING`. **Retry** after 1–5 seconds until the participant has joined.
- Other failures: invalid/expired OBF, wrong meeting_id, or network/SDK errors — handle as usual.

### Mapping “meeting → which participant's OAuth”

You need to know **which Zoom user** (who has authorized your app) will be in **which meeting**. Options:

- **User tells you:** e.g. "send the bot to this meeting" from your UI; the logged-in user is the authorizing participant.
- **Calendar / Zoom list:** e.g. fetch the user's meetings via Zoom API (`meeting:read:list_meetings`) and assume the user will be in their own meetings.
- **Meeting ID from link:** When someone shares a join link, you have meeting_id; you still need to pick an authorized user who will be in that meeting (often the person who requested the bot).

### Summary: “any meeting (if allowed by host)” with OBF

- **Any meeting** = any meeting where at least one **authorized participant** is in the call.
- **Allowed by host** = host **admits** the bot from the waiting room (if any) and **allows recording** when prompted (or you pre-authorize via host's **join token for local recording**).
- **Limitation:** Bot **cannot** stay if the authorizing participant leaves; bot is tied to that user's presence.

---

## 8. ZAK (Zoom Access Key) token

- **Idea:** The **host** of the meeting authorizes your app. You get that user's **ZAK** and join (or start) the meeting **as that user**.
- **Rules:** ZAK is **short-lived** (~5 minutes); fetch it close to join/start. Typically used when the bot is **starting** the meeting or joining **as the host**.
- **What you need:** OAuth with scope that allows **Get user's ZAK** (e.g. `user:read:zak` or equivalent). Call Zoom API to get the user's ZAK, then pass it into the SDK.
- **Use case:** "Our app starts or joins the meeting as the host (e.g. automated standup)."

---

## 9. Join token for local recording

- **Idea:** The **host** authorizes your app via OAuth. For a specific meeting, you call Zoom's API to get a **join token for local recording** and pass it to the bot. The token grants **recording permission + bypass waiting room** for that meeting.
- **API:** `GET https://api.zoom.us/v2/meetings/{meetingId}/jointoken/local_recording?bypass_waiting_room=true` with `Authorization: Bearer {host_access_token}`.
- **Scopes:** e.g. `meeting:read:local_recording_token`, `meeting:read:list_meetings`, `user:read:user` (and admin variants for account-level).
- **Limitation:** Does **not** by itself authorize **join** to external meetings (that's OBF/ZAK from 2026). Use **together with** SDK credentials and, when required, OBF or ZAK.
- **Use case:** Record without the host clicking "Allow" every time; bot can skip the waiting room when the host has authorized your app.

---

## 10. RTMS (Realtime Media Streams)

- **Idea:** No "bot" participant. A **user in the meeting** enables a Zoom App that uses **RTMS** to stream audio/video/transcript to your backend.
- **Rules:** User must be in the meeting and **opt in**. You use the **Zoom RTMS SDK** (Node.js/Python), not the Meeting SDK for Linux.
- **Use case:** Media/transcript from any meeting where the user turns on your app, without a bot in the participant list.

**This sample does not use RTMS.** RTMS is a different product (Zoom Apps + RTMS pipeline).

---

## 11. Which option to use when

| Goal | Recommended option |
|------|--------------------|
| **From February 23, 2026: external meeting** (host ≠ app owner) | **OBF** or **ZAK** (or RTMS). Non-approved Meeting SDK app + OBF is sufficient; the token carries the authorization. |
| Only **your own** Zoom account's meetings (you are the host) | **SDK credentials only** (Client ID + Secret). No OAuth. |
| **Any** meeting where "a user is in the call and we join with them" (e.g. notetaker) | **OBF**. User authorizes once; backend gets OBF token for that meeting; pass to sample with `--on-behalf`. |
| **Any** meeting where "we are the host" (bot starts or joins as host) | **ZAK**. Host authorizes; get their ZAK; pass to sample with `--zak`. |
| Same as above + **record without host clicking Allow** every time | **OBF (or ZAK) + Join token for local recording**. Use OBF/ZAK for joining; use **join token for local recording** (host OAuth) for recording + bypass waiting room. |
| No bot in the roster; get media when user enables your app in the meeting | **RTMS** (separate product; not this sample). |

**Practical recommendation for "access any meeting (if allowed by host)" from February 23, 2026:** Use **OBF** as the main mechanism for external meetings. Add **join token for local recording** (host OAuth) if you want recording and waiting-room bypass without the host clicking Allow each time.

---

## 12. How companies integrate with Zoom

This section describes how each **product (1–7)** uses **solutions (1–7)**. The canonical mapping is [Section 4 (Product P uses Solution S)](#4-product-p-uses-solution-s-mapping-matrix).

### Product 1: Recall.ai

- **Product 1 uses solutions:** **1** (SDK credentials), **2** (approved SDK app for external meetings), **3** (join token for local recording — primary for recording + bypass waiting room), **4** (ZAK when sign-in required or start as host), **5** (OBF documented and planned for February 23, 2026). Not **6** (RTMS). **7** (manual) as fallback.
- **Two apps:** (1) Meeting SDK app (Client ID + Secret) for the bot to join. (2) Zoom OAuth app (same or separate) to get tokens on behalf of users/hosts.
- **Joining external meetings:** They rely on **solution 2** (Zoom SDK app review). Once the customer's Meeting SDK app is approved by Zoom, the same SDK credentials can join meetings hosted by other Zoom accounts. Until approval, bots only join meetings in the app owner's workspace.
- **Recording without host click:** They use **solution 3** (join token for local recording). Host (or workspace) authorizes once. Recall maintains a mapping: meeting ID → which OAuth credentials can create a join token (via Zoom webhooks). When a bot is sent to a meeting, Recall uses the host's OAuth token to get the join token and passes it to the bot.
- **OBF (solution 5):** They have published detailed content on OBF and will need it for join authorization on external meetings when Zoom enforces the February 23, 2026 rule.

### Product 2: Fireflies.ai

- **Product 2 uses solutions:** **1** (SDK credentials), **2** (approved app), **3** (join token for local recording — join without host approval, bypass waiting room). **4** (ZAK) and **5** (OBF) when required (e.g. sign-in-required meetings or post–Feb 23, 2026). Not **6** (RTMS). **7** (manual) as fallback.
- Users **connect Zoom** via OAuth (Integrations → Zoom → Connect). Fireflies stores **per-user tokens** (see [Section 14](#14-creating-a-zoom-oauth-app-one-app-per-product) for one app per product and the "Connect Zoom" OAuth flow).
- With Zoom connected, the bot can join without host approval and bypass waiting room. The flow is the **common pattern** below: OAuth once per user → when sending a bot to a meeting, the backend uses that user's (or the host's) stored tokens to get a **join token (solution 3)** and/or **ZAK (4)** or **OBF (5)** when required → the bot joins with the Meeting SDK.
- **One Zoom OAuth app** for the whole product; each user gets their own **tokens** after authorizing.

### Product 3: Otter.ai

- **Product 3 uses solutions:** **1** (SDK credentials), **2** (approved app), **3** (join token for local recording — host connects Zoom; seamless join + record when host has "Record to computer files" and "Auto approve"). **4** (ZAK) and **5** (OBF) when required. Not **6** (RTMS). **7** (manual) optional (host can allow each time).

### Product 4: Botpress

- **Product 4** does not use a live bot in the meeting. It uses Zoom **cloud recording** and **recording/transcript webhooks** (e.g. `recording.transcript_completed`). So it does not use solutions 1–5 or 7 in the "bot in meeting" sense; it is a different integration type.

### Product 5: This sample

- **Product 5 (this repo)** supports **solutions 1, 3, 4, 5** via config (`client-id`/`client-secret`, `--join-token`, `--zak`, `--on-behalf`). It can also run with **solution 7** (no token; host admits and allows recording manually). Approval (**solution 2**) is a Zoom Marketplace step, not code in this repo. See [Section 16 (Support in this sample)](#16-support-in-this-sample).

### Common pattern

1. **Meeting SDK app** (get it **approved** by Zoom for production).
2. **Zoom OAuth** (user or account level) to obtain:
   - **Join token for local recording** (host OAuth) — for recording + bypass waiting room.
   - **OBF or ZAK** (when required) — for **join** authorization on external meetings (Feb 23, 2026+).
3. **Meeting → host (or participant) mapping** (webhooks + list meetings) so the backend knows which OAuth token to use for each meeting.
4. Before each join: backend fetches the right token and passes it to the Meeting SDK client.

---

## 13. Options ↔ products (mapping)

This table maps each **option** from [Section 5](#5-options-and-limitations-reference-table) to **which products use it** in practice. All options in the doc are covered; products may use one or several options depending on scenario.

| Option (from Section 2) | Recall.ai | Fireflies.ai | Otter.ai | Notes |
|-------------------------|-----------|--------------|----------|--------|
| **SDK credentials only** | Yes (base; + approved app for external) | Yes (base) | Yes (base) | Every bot uses Meeting SDK Client ID + Secret. "Approved" app extends to external meetings until February 23, 2026. |
| **Join token for local recording** | Yes (primary for recording + bypass waiting room) | Yes (join without host approval, bypass waiting room) | Yes (host connects → seamless join + record) | Host (or connecting user) OAuth; backend gets token per meeting. |
| **ZAK token** | Yes (sign-in-required meetings; start as host) | When required (e.g. authenticated-only meetings) | When required | Short-lived; used when bot joins as authenticated user or starts meeting. |
| **OBF token** | Yes (documented; required for external joins from February 23, 2026) | When required (e.g. post–2026 external joins) | When required | Participant in meeting authorizes; bot joins on their behalf. |
| **RTMS** | No (bot in meeting) | No | No | RTMS = no bot; different product category (Zoom Apps + RTMS SDK). |

So: **SDK credentials** are used by all; **join token for local recording** is the main addition for "join + record without host click" in Recall, Fireflies, and Otter; **ZAK** and **OBF** are used when the scenario requires them (sign-in required, start as host, or external-join compliance from 2026).

---

## 14. Creating a Zoom OAuth app (one app per product)

You use **one Zoom OAuth app per product** (e.g. one for Fireflies). All users who click "Connect Zoom" use the **same** app; each user gets their own **tokens** stored in your backend.

### Steps

1. Go to **[marketplace.zoom.us](https://marketplace.zoom.us/)** and sign in with the Zoom account that will **own** the app.
2. **Develop** → **Build App** → choose **OAuth** (User-managed for "users connect Zoom").
3. Fill in **App name**, **Redirect URL(s)** (e.g. `https://yourapp.com/integrations/zoom/callback`), company/contact, logo if required.
4. Add **scopes** (e.g. for OBF: `user:read:token`; for join token for local recording: `meeting:read:local_recording_token`, `meeting:read:list_meetings`, `user:read:user`; for ZAK: `user:read:zak`).
5. Copy **Client ID** and **Client Secret**; use them in your backend. Same Client ID for every user; store **per-user** access and refresh tokens after each user authorizes.
6. **Development** = only app owner and test users can OAuth. For **any** Zoom user to connect, **submit the app for review** and get Zoom's approval.

### OAuth flow (how "Connect Zoom" works)

1. User clicks "Connect Zoom" → your backend redirects to Zoom's authorize URL with your `client_id` and `redirect_uri`.
2. User signs in to Zoom (if needed) and consents. Zoom redirects to your `redirect_uri` with a one-time **authorization code**.
3. Your **backend** exchanges the code for **access_token** and **refresh_token** (POST to `https://zoom.us/oauth/token` with code, redirect_uri, and Basic auth with client_id:client_secret).
4. Store both tokens for that user. Use **access_token** for Zoom API calls; use **refresh_token** to get new access tokens when they expire (Zoom access tokens often expire in ~1 hour).

---

## 15. Zoom authorization: app review and user consent

- **Zoom's approval of your app (app review):**
  - **Development:** No review needed. Only the app owner's Zoom account (and test users you add) can complete "Connect Zoom".
  - **Production (any user can connect):** Yes. You must **submit the app for review** in the Marketplace. After Zoom approves, any Zoom user can authorize your app.
- **Each user authorizing your app (OAuth consent):** Yes. Every user must complete the OAuth flow once (click "Connect Zoom" → sign in to Zoom → accept the consent screen). You cannot access a user's Zoom account without this step.

---

## 16. Support in this sample

This headless Linux sample already supports:

| Option | Config / CLI | Notes |
|--------|--------------|--------|
| SDK credentials | `client-id`, `client-secret` (in config or CLI) | Default. |
| OBF token | `--on-behalf` or `on-behalf` in config.toml | Backend must obtain token and pass it. |
| ZAK token | `--zak` or `zak` in config.toml | Backend must obtain ZAK. |
| Join token for local recording | `--join-token` or `join-token` in config.toml | Use together with SDK creds (and OBF/ZAK when required). |

Implementation: see `src/Zoom.cpp` (e.g. `param.onBehalfToken`, `param.userZAK`, `param.app_privilege_token`) and `src/Config.cpp` / `src/Config.h` for the options. The **missing piece** is the **backend** that performs OAuth and fetches the appropriate token before each run.

---

## 17. References

- [Zoom OBF FAQ](https://developers.zoom.us/docs/meeting-sdk/obf-faq/)
- [Transitioning to OBF tokens (Zoom blog)](https://developers.zoom.us/blog/transition-to-obf-token-meetingsdk-apps/)
- [Understanding Zoom OBF (Recall.ai)](https://www.recall.ai/blog/zoom-obf)
- [How to manage ZAK tokens for Zoom bots (Recall.ai)](https://www.recall.ai/blog/how-to-manage-zak-tokens-for-zoom-bots)
- [Zoom join tokens for local recording (Recall.ai)](https://www.recall.ai/blog/zoom-join-tokens-for-local-recording)
- [Recall Zoom OAuth overview](https://docs.recall.ai/docs/zoom-oauth-overview), [Zoom compliance](https://docs.recall.ai/docs/zoom-compliance-requirements)
- [Meeting SDK Auth](https://developers.zoom.us/docs/meeting-sdk/auth/) (Zoom)
- Zoom User API: [Get a user's token](https://developers.zoom.us/docs/api/rest/reference/user/methods/#operation/userToken) (for OBF: `type=onbehalf&meeting_id=...`)
- Zoom API: [Meeting local recording join token](https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/meetingLocalRecordingJoinToken)
- [Zoom RTMS](https://developers.zoom.us/docs/rtms/) / [Meeting Bots & Media Streams](https://developers.zoom.us/docs/zoom-apps/guides/meeting-bots-sdk-media-streams/)
- [Create an OAuth app](https://developers.zoom.us/docs/integrations/oauth/) (Zoom)
