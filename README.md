# Strive

Personal iOS app that surfaces all-time running records from Strava's manual
account archive — no OAuth, no API subscription, no live sync.

Requires iOS 17+ / Xcode 15+ / Swift 5.10.

## Getting started

The `.xcodeproj` is generated from `project.yml` via
[XcodeGen](https://github.com/yonaskolb/XcodeGen), so it's not checked in.

```bash
brew install xcodegen
xcodegen generate
open Strive.xcodeproj
```

Then pick your development team in the Signing tab and hit Run.

## Importing your Strava archive

1. In Strava: **Settings → My Account → Download or Delete Your Account → Request Your Archive**.
2. Strava emails a ZIP within a few hours.
3. Unzip it with the Files app on iOS (long-press → Uncompress).
4. Open Strive → **Import** tab → pick the folder (or `activities.csv` directly).
5. Re-importing later is safe — activities are upserted by Strava ID.

## What v1 does

- Parses `activities.csv`, filters to `Activity Type == "Run"` (Trail Runs are excluded).
- Dashboard shows longest run, most elevation, longest duration.
- Activity list is sortable by date / distance / pace, with a detail view per run.

## What's stubbed (next commit)

- **FIT / GPX / TCX parsing.** The parser registry and interfaces are in
  `Strive/Import/ActivityFileParser.swift`. All three formats will ship
  together — GPX and TCX via `XMLParser`, FIT via a small Swift decoder.
- **Best-split algorithm.** Sliding-window in `Strive/Splits/BestSplitCalculator.swift`
  — depends on the parsers above.
- **ZIP extraction** — for now the app expects an already-uncompressed folder.

## Deferred (v1.1)

- WidgetKit widget for lock-screen PRs.
- Optional map on activity detail.

## Layout

```
Strive/
  StriveApp.swift          # @main entry, SwiftData container
  Models/                  # RunActivity, BestSplit
  Design/                  # Theme, Icons, Formatters
  Import/                  # CSV + activity file parsers, ImportService
  Splits/                  # BestSplitCalculator
  Views/                   # SwiftUI screens + components
StriveTests/               # Unit tests
```
