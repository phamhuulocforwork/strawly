# StrawlyIsland — iOS setup (Dynamic Island + home widgets)

The Swift sources and assets live in this folder, but the **WidgetKit extension
target is not wired into `Runner.xcodeproj` yet**. These steps are one-time and
must be done on a Mac in Xcode.

Both the Live Activity (Dynamic Island) and the home screen widgets
(`2×2` → `systemSmall`, wide `→ systemMedium`) share this single extension.

## 1. Add the extension target

1. Open `ios/Runner.xcworkspace` in Xcode.
2. **File → New → Target… → Widget Extension**.
   - Product Name: `StrawlyIsland`
   - Uncheck **Include Live Activity** and **Include Configuration App Intent**
     (the sources already exist in this folder).
   - Finish. When asked to activate the scheme, choose **Activate**.
3. Delete the template files Xcode just generated (in the `StrawlyIsland`
   group: the generated `*.swift`, and the generated `Info.plist` if any),
   then **Add Files…** to the target:
   - `StrawlyIslandLiveActivity.swift`
   - `StrawlyHomeWidget.swift`
   - `Assets.xcassets`

## 2. Extension target settings

Select the `StrawlyIsland` target → **Build Settings**:

| Setting | Value |
| --- | --- |
| iOS Deployment Target | `16.1` |
| Product Bundle Identifier | `com.example.strawly.StrawlyIsland` |
| Info.plist File | `StrawlyIsland/Info.plist` |
| Generate Info.plist File | `No` |
| Code Signing Entitlements | `StrawlyIsland/StrawlyIsland.entitlements` |
| Signing & Capabilities → Team | same team as Runner |

## 3. App Groups on both targets

- Select the **Runner** target → **Signing & Capabilities** → add **App Groups**
  → `group.com.example.strawly` (this sets Runner's Code Signing Entitlements
  to `Runner/Runner.entitlements`, which already contains the group).
- Do the same on the **StrawlyIsland** target. Both must use the **same** group,
  otherwise the widget cannot read the cycle data.

## 4. Verify

1. Run the app once (to populate widget data) with the Dynamic Island toggle
   enabled in Settings if you want the island preview.
2. Long-press the home screen → Widgets → **Strawly** → pick `2×2` (small) or
   any wide size (medium).

The Flutter side writes a day-by-day timeline to `widget_timeline` in the app
group; the widget picks the current day entry itself, so the day count rolls
over at midnight without opening the app. On Android the same data is read by
`CycleWidgetProvider`.
