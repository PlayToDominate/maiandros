# Maiandros Widget Scaffold

This folder starts the countdown widget implementation.

## What is included
- `MaiandrosCountdownWidget.swift`: WidgetKit countdown widget that reads a shared snapshot from App Group `UserDefaults`.

## How to finish wiring in Xcode
1. In Xcode: `File -> New -> Target -> Widget Extension`.
2. Name it `MaiandrosWidgetExtension`.
3. Move/copy `MaiandrosCountdownWidget.swift` into that target.
4. Add an App Group capability to both app target and widget target.
5. Add the same App Group ID to both targets: `group.com.playtodominate.maiandros` (or replace everywhere with your final ID).
6. Keep key alignment:
   - App writes key: `maiandros.widget.nextTrip`
   - Widget reads key: `maiandros.widget.nextTrip`
7. `TripStore` already calls `WidgetCenter.shared.reloadAllTimelines()` when trips change.

## Shared snapshot payload
```json
{
  "tripName": "Kauai",
  "destination": "Kauai",
  "startDate": "2026-07-02T00:00:00Z",
  "daysUntil": 43
}
```
