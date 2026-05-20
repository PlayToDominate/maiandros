# Maiandros Widget Scaffold

This folder starts the countdown widget implementation.

## What is included
- `MaiandrosCountdownWidget.swift`: starter WidgetKit view/provider with warm Maiandros styling.

## How to finish wiring in Xcode
1. In Xcode: `File -> New -> Target -> Widget Extension`.
2. Name it `MaiandrosWidgetExtension`.
3. Move/copy `MaiandrosCountdownWidget.swift` into that target.
4. Add an App Group capability to both app target and widget target.
5. Use a shared store key (e.g. `group.com.playtodominate.maiandros`) for next-trip snapshot data.
6. Update `MaiandrosCountdownProvider.getTimeline` to read real next-trip values.
7. Call `WidgetCenter.shared.reloadAllTimelines()` whenever trips change.

## Suggested shared snapshot payload
```json
{
  "tripName": "Kauai",
  "destination": "Kauai",
  "startDate": "2026-07-02T00:00:00Z",
  "daysUntil": 43
}
```
