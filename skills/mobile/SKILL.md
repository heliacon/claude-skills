---
name: mobile
description: Use when building, reviewing or releasing a phone or tablet app, such as React Native or Expo screens, mobile performance, offline sync, push notifications, permissions, deep links, device testing or App Store and Google Play submission. Not for Swift language and SwiftUI detail (use `swift`). Not for browser UI (use `frontend`).
license: MIT
---

# Mobile

Mobile work fails in ways web work does not: weak networks, low-end Android hardware, a store review
between you and every fix, and binaries that stay installed for years. Default stack where nothing is
chosen yet: React Native through Expo, which the React Native docs recommend as the starting framework.
Native Swift work uses the `swift` skill alongside this one.

## Pick the task

- **Implement a screen or feature:** read the existing navigation, state and styling conventions first and
  follow them. Then the rules below.
- **Review:** walk the checklist under Verification and report per file: rule broken, why it matters on a
  device, the fix. Worst first.
- **Improve performance:** profile a release build on a low-end device before changing code. See
  Performance.
- **Ship a release:** read `references/release.md` before any store submission, and before a first
  release on either store.

## Rules that matter most

1. **Measure on a release build on a real low-end Android device.** Development builds run far slower
   (dev checks, no ahead-of-time optimisation) and a recent iPhone hides almost everything. A
   performance claim from a dev build or a simulator is not evidence.
2. **Every network call handles loading, success, error and offline.** Assume the network drops mid-request
   and that the app is killed and relaunched mid-flow.
3. **Ask for a permission at the point of use, after explaining why.** Never on launch. A denied system
   prompt is hard to undo: on iOS the app cannot ask again, and the user must go to Settings. Handle
   "denied" and "limited" as real states with a path forward.
4. **Secrets go in the Keychain or Android Keystore** (through a secure-storage library). Never in
   AsyncStorage, plain preferences or the JavaScript bundle. Anything in the bundle is public.
5. **Native changes need a store build.** Over-the-air updates may only ship JavaScript and assets that are
   compatible with the native code already installed. Tie each update to a runtime version and never push
   one that calls native code the installed binary lacks.
6. **Old versions live for years.** Keep the API backward compatible with every build still in use, or
   ship a forced-update gate before you need it.

## When not to use

- Swift language, SwiftUI, Swift concurrency: the `swift` skill.
- Mobile web or responsive sites: the `frontend` skill.
- Backend endpoints the app calls: `api-design` and `backend-patterns`.
- Visual design and design systems: `designer` and `visual-design`.

## React Native defaults

- **Lists:** a virtualised list (`FlatList`, or `FlashList` for long or complex lists), never
  `ScrollView` plus `map` beyond a screenful. Stable `keyExtractor` ids, not array indices. Supply
  `getItemLayout` (or the list's size estimate) when rows have a known size.
- **Pressables:** `Pressable` for touch handling, with `android_ripple` for the Android ripple. The older
  `Touchable*` components are legacy.
- **Animation:** run it off the JavaScript thread (`useNativeDriver: true` with `Animated`, or Reanimated
  worklets). JavaScript-thread animation stutters whenever the app does other work.
- **Memoisation:** memoise list item components and the callbacks passed to them, and anything a profile
  shows re-rendering at cost. Blanket `useCallback` on every function adds noise for no gain. If the
  project uses the React Compiler, let it memoise and do not add manual memos by reflex.
- **Navigation:** React Navigation with the native stack, or Expo Router (built on it) in Expo projects.
  Every screen reachable by a deep link must load its own data from the route params, not from state left
  by the previous screen.
- **Platform differences:** `Platform.select` or `.ios.tsx` / `.android.tsx` files for real differences.
  Scattered `Platform.OS` checks inside components rot.
- **Native modules:** a maintained community or Expo module before custom native code. Check it supports
  the New Architecture (the default since React Native 0.76).

## Platform conventions

iOS:
- Respect safe areas with `useSafeAreaInsets()` (react-native-safe-area-context), not hard-coded padding.
- The back-swipe gesture works on every pushed screen. Do not disable it without a reason, such as a form
  with unsaved changes, and then confirm instead.
- System font and Dynamic Type: text scales with the user's setting. Test at the largest size.

Android:
- The hardware and gesture back action does something sensible on every screen, including modals and
  nested navigators (`BackHandler` where navigation does not cover it).
- Edge-to-edge drawing is enforced for apps targeting Android 15 (API 35) and later: handle insets for the
  status and navigation bars.
- Notifications need the runtime permission on Android 13 (API 33) and later.

Both:
- Minimum touch target 44pt (iOS) or 48dp (Android), including the spacing around small icons.
- Font scaling and screen readers (VoiceOver, TalkBack) tested on at least the main flow. Every
  interactive element has an accessibility label and role.

## Offline and data

- Cache server data for offline reading (a server-cache library with persistence, or a local database).
- Writes made offline go to a durable queue, replay in order when connected and are idempotent on the
  server (a client-generated id per write), because a replay after a timeout will repeat some of them.
- Optimistic updates for user actions, with a visible rollback when the server rejects.
- A visible offline indicator. Never a spinner that waits forever.
- Decide the conflict rule (last write wins, server wins or merge) before building sync, and write it down.

## Push notifications

- Ask after the user has seen the value, behind an explanation screen that says what you will send.
- Every notification deep-links to the screen it is about, and that screen loads cold from the link.
- Register the device token on every launch; tokens change. Remove it from the server on sign-out.

## Performance

1. Reproduce on a release build on a low-end Android device. Note the frame rate and the screen.
2. Profile: the React Native performance monitor and React DevTools profiler for JavaScript; Xcode
   Instruments and the Android Studio profiler for native work, memory and start-up.
3. Fix the measured cause. Common ones: list not virtualised or rows re-rendering, heavy work on the JS
   thread during a transition, oversized images decoded on the main thread, synchronous storage reads at
   start-up.
4. Measure again on the same device and build. Report before and after numbers.

## Gotchas

- **A screen that works when navigated to can fail from a deep link or a notification,** because it
  relied on state from the previous screen. Test cold starts from each link.
- **Universal Links and App Links need files on your web domain** (`apple-app-site-association`,
  `assetlinks.json`) served correctly. Without them, links open the browser.
- **Background work is not guaranteed on either platform.** Schedule it with the platform's background
  task APIs and design for it never running.
- **Store rules change yearly** (target API level, privacy declarations, required account deletion).
  Check the current store policy pages before a submission; do not rely on memory.
- **A simulator has no real push, camera, biometric or performance behaviour.** Those need a device.
- **Time zones and locales:** format dates and numbers with the device locale; store and send UTC.

## Verification

- [ ] Tests, lint and type check pass; new tests seen to fail with the change reverted.
- [ ] Main flow run on a real iOS device and a real low-end Android device, release build.
- [ ] Flight mode mid-flow: offline state shown, queued writes replay once, no duplicates on the server.
- [ ] Each permission: granted, denied and (iOS) limited paths each tried.
- [ ] Deep links and notifications opened from a killed app land on the right screen with data.
- [ ] Largest font size and a screen reader on the main flow.
- [ ] Performance claims backed by profiler numbers from a release build, before and after.
- [ ] For a release: the checklist in `references/release.md`.
