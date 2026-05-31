# Freezer Tag POC

Native iOS proof of concept for using NFC tags with reusable freezer containers. The app lets a user record container contents, write/read NFC tag payloads, and manage local container records without a backend.

DTP is treating this as a product-candidate PoC, not a finished product. The current evidence proves simulator build/test paths and Steve's physical NFC feasibility check for the domestic container scenario. It does **not** prove food-contact suitability, GS1 certification, tamper-proof chain of custody, or production packaging compliance.

## Requirements

- macOS with Xcode installed.
- iOS Simulator runtime compatible with the project.
- A physical iPhone is required for real NFC validation; the simulator cannot prove NFC hardware behaviour.

## Open in Xcode

```bash
cd "/Users/hudsonrebel/DTP Coding Projects/freezer-tag-poc"
open FreezerTagTracker.xcodeproj
```

## Build

```bash
cd "/Users/hudsonrebel/DTP Coding Projects/freezer-tag-poc"
xcodebuild build \
  -project FreezerTagTracker.xcodeproj \
  -scheme FreezerTagTracker \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

## Simulator tests

```bash
cd "/Users/hudsonrebel/DTP Coding Projects/freezer-tag-poc"
xcodebuild test \
  -project FreezerTagTracker.xcodeproj \
  -scheme FreezerTagTracker \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

## Physical NFC caveat

Simulator tests exercise UI, local persistence, and non-hardware logic only. Before any demo or pilot claim, validate on a real iPhone with real NFC tags:

- read an empty/prepared NDEF tag;
- write a container record;
- read the same tag back and confirm the expected record opens;
- test edit, clear, reuse, cancellation, and retry flows;
- record tag type, placement, container material, and observed reliability.

The generic NFC cards used during PoC work are development materials only unless food-contact/freezer-use documentation is obtained. Customer-facing demos should prefer external tag placement until packaging and compliance questions are settled.

## Repository hygiene

The repo should not track Xcode user state, DerivedData, build outputs, local secrets, certificates, or environment files. Existing tracked Xcode user-state files were removed from version control in the hygiene pass; local developer state can remain on each machine but should stay ignored.

See `_briefing.md` for the fuller DTP code briefing, product-state classification, risks, and related records.
