# iOS StrawlyIsland Widget Extension Setup

The Swift sources live in `ios/StrawlyIsland/`. Xcode must embed the extension before Live Activities work on iPhone.

## Checklist (run on macOS with Xcode)

1. Open `ios/Runner.xcworkspace`.
2. **File → New → Target → Widget Extension**
   - Product name: `StrawlyIsland`
   - Include Live Activity: enabled
   - Embed in Application: **Runner**
3. Replace the generated Swift file with `ios/StrawlyIsland/StrawlyIslandLiveActivity.swift`.
4. Set extension **Info.plist** to `ios/StrawlyIsland/Info.plist` (or copy keys):
   - `NSSupportsLiveActivities` = `YES`
5. **Signing & Capabilities** for **Runner** and **StrawlyIsland**:
   - Add App Group: `group.com.example.strawly`
   - Runner entitlements file: `ios/Runner/Runner.entitlements`
   - Extension entitlements: `ios/StrawlyIsland/StrawlyIsland.entitlements`
6. Confirm `ios/Runner/Info.plist` contains:
   - `NSSupportsLiveActivities` = `YES`
   - URL scheme `strawly`
7. Build & run on a Dynamic Island device (iPhone 14 Pro or newer).
8. Open Strawly → press Home → compact island should show 🍓 + digit.
9. Force-quit Strawly → island should disappear (`removeWhenAppIsKilled: true`).

## Notes

- `LiveActivitiesAppAttributes` name must stay exactly as in the Swift file (plugin requirement).
- Remote push updates are disabled (`iOSEnableRemoteUpdates: false`).
- Linux CI cannot compile the extension; verify on a Mac or physical iPhone.
