# Maiandros (iOS SwiftUI)

Maiandros is a calm, cozy trip-readiness companion app with local-only storage and no account system.

## What V1 Includes

- Home screen with current trips, past trips placeholder, and trip cards
- Trip creation flow (name, destination, start/end dates, flying/driving)
- Trip creation flow (name, destination, reason, start/end dates, flying/driving)
- Trip detail with:
  - Countdown section
  - Checklist with statuses (`Needs Action`, `Upcoming`, `In Progress`, `Complete`, `Optional/Skipped`)
  - Editable packing list with progress
  - Cabinet notes with flexible tags
- Local persistence using JSON in app Documents
- Warm/cozy copy tone with subtle Meander mascot references

## Project Structure

- `Maiandros/App` app entry and shell
- `Maiandros/Design` colors and shared card styling
- `Maiandros/Models` trip/checklist/packing/cabinet models
- `Maiandros/State` local store and seed logic
- `Maiandros/Features` Home, Trip Creation, Trip Detail
- `Maiandros/Resources` asset catalog

## Notes

- No backend, no login, no APIs
- Passport validity helper computes `trip end date + 6 months` guidance
- U.S. destination inference skips passport stress for likely domestic trips (for example NYC)
- Flight checklist state starts as `Upcoming` when trip is far out

## Open In Xcode

1. Open `Maiandros.xcodeproj`
2. Set your own Team + Bundle Identifier (`com.example.Maiandros` is placeholder)
3. Run on an iPhone simulator or device

## Next V1.1 Ideas

- Domestic/international inference for checklist nuance
- Weather preview module
- Better Meander visual system + mascot art assets
- Cabinet attachment types (images, files)
- Widget extension
