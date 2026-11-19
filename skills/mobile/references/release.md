# Mobile release and store submission

Read this before any App Store or Google Play submission, and before a first release on either store.
Store policies change every year. Treat the items here as a checklist of things to confirm against the
current policy pages, not as the policy itself.

## Contents
1. Before the first release
2. Apple App Store
3. Google Play
4. Device matrix
5. Release process
6. Over-the-air updates

## 1. Before the first release

- Bundle id / application id chosen for good. It cannot change after release.
- Signing keys stored safely with a recovery plan. On Google Play use Play App Signing, so a lost upload
  key can be reset. Losing a signing key you manage yourself can mean you can never update the app.
- Crash reporting with symbol upload (dSYMs for iOS, mapping and native symbols for Android) in place
  before the first user. A crash without symbols is not actionable.
- A forced-update or minimum-version check in the app, so a later breaking API change has a way out.
- Privacy policy URL live. Data collection list written down: what, why, shared with whom.
- If the app lets users create an account, it lets them delete it from inside the app (required by Apple,
  and Google Play requires a deletion route too).

## 2. Apple App Store

- **Privacy details** ("nutrition label") in App Store Connect match what the app and every SDK in it
  actually collect.
- **Privacy manifest** (`PrivacyInfo.xcprivacy`) declares the reasons for any "required reason" APIs
  (for example file timestamps, user defaults, disk space). Third-party SDKs on Apple's list must ship
  their own signed manifests. Enforced since May 2024.
- **Sign-in:** if the app offers third-party social sign-in, check the current rule on offering an
  equivalent privacy-focused option such as Sign in with Apple.
- **Payments:** digital goods and features consumed in the app use In-App Purchase unless a current
  regional exception applies. Do not mention other platforms' prices or purchase routes unless the
  current rules for your region allow it.
- **Review notes:** a demo account that works, and steps to reach any feature behind hardware or location.
- **TestFlight** build to internal testers first, then external testers, before submission.

## 3. Google Play

- **Data safety form** matches the app and its SDKs.
- **Target API level** meets the current requirement (new apps and updates must target a recent Android
  version, roughly within a year of the newest release). Check the current deadline.
- **64-bit:** any native code includes `arm64-v8a`.
- **Testing tracks:** internal, then closed, then production. New personal developer accounts may need a
  closed test with a minimum number of testers for a set period before production access.
- **Permissions declarations** for sensitive permissions (SMS, call log, all-files access, background
  location, exact alarms) need a justification form and often get refused. Avoid them if you can.

## 4. Device matrix

Cover at least:
- Oldest supported OS version on each platform, and the newest.
- One low-end Android device (low RAM, slow storage). This is where performance and memory bugs live.
- One small screen and one large screen or tablet, if tablets are supported.
- Largest accessibility font size, dark mode, a right-to-left language if localised.
- A device with a notch or Dynamic Island, and Android gesture navigation and three-button navigation.

## 5. Release process

1. Freeze: version and build number bumped, changelog written, release branch cut.
2. Release build tested on the device matrix (section 4), main flows and upgrade from the previous version
   with existing local data.
3. Submit. Use phased release (App Store) or staged rollout (Play), starting small.
4. Watch crash-free users and sessions, ANR rate (Android) and error rates on the API for the new
   version. Set a halt threshold before the rollout starts, not after.
5. Expand the rollout only while the metrics hold. Halt and fix forward if they do not. A store build cannot
   be rolled back on users' devices.

## 6. Over-the-air updates

- Only JavaScript and assets. Any change to native code, native dependencies, permissions or the app's
  configuration needs a store build.
- Each update targets a runtime or native version, so it can never reach a binary that lacks what it calls.
- Store rules allow interpreted-code updates that fix bugs and improve features, not ones that change the
  app's main purpose or bypass review. Keep updates within that.
- Roll out updates in stages too, with the same halt threshold, and keep the ability to roll back to the
  previous update.
