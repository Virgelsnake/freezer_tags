---
title: Freezer Tag POC code briefing
type: code-briefing
status: active
owner: Hudson
development_state: PoC
software_category: product candidate
updated: 2026-05-27
---

# Freezer Tag POC — code briefing

## Summary

Freezer Tag POC is a native iOS proof of concept for using NFC tags on reusable freezer containers. The user can add container contents, write or read NFC tag data, review/edit container details, and manage local records without a backend.

DTP has it as a feasibility/product-candidate build. The source PRD states that the purpose is to validate NFC read/write reliability for this domestic container use case before deciding whether it could become a commercial product.

## Current state

- **DTP software category:** product candidate
- **Development state:** PoC
- **Commercial status:** domestic PoC has physical NFC feasibility confirmed by Steve; GS1 Evidence Mode is now a simulator-verifiable market-application slice, but still needs physical GS1 NFC validation, packaging/food-contact decisions and compliance review before it can be called an MVP or product.
- **Last verified:** 2026-05-28 08:00 BST
- **Works locally:** yes, in the iOS simulator for build, unit tests and UI tests. Steve has physically confirmed the existing NFC cards work and work through the container for the domestic PoC. The new GS1 Evidence Mode NFC path remains simulator/demo only.
- **Tests:** `xcodebuild test -project FreezerTagTracker.xcodeproj -scheme FreezerTagTracker -destination 'platform=iOS Simulator,name=iPhone 17'` succeeded on 2026-05-28. The unit suite reported 108 tests, 0 failures. The test run produced `/Users/hudsonrebel/Library/Developer/Xcode/DerivedData/FreezerTagTracker-czhswumcurowsxciuemgmamnfzgx/Logs/Test/Test-FreezerTagTracker-2026.05.28_07-57-09-+0100.xcresult`.
- **Main risks:**
  - GS1 Evidence Mode currently uses a simulator/demo tag-link path; physical GS1-style NFC write/read still needs implementation and device validation.
  - The app must not claim GS1 certification, legal compliance, food-safety compliance or tamper-proof chain of custody.
  - The current generic Amazon PVC NFC cards are PoC/dev tags only unless food-contact documentation is obtained; customer-facing demos should prefer external tag placement.
  - The current project includes Xcode user-state files in Git history, including `FreezerTagTracker.xcodeproj/project.xcworkspace/xcuserdata/steveshearman.xcuserdatad/UserInterfaceState.xcuserstate`.

## How to run

Verified development environment:

```bash
cd "/Users/hudsonrebel/DTP Coding Projects/freezer-tag-poc"
open FreezerTagTracker.xcodeproj
```

Build from terminal:

```bash
cd "/Users/hudsonrebel/DTP Coding Projects/freezer-tag-poc"
xcodebuild build -project FreezerTagTracker.xcodeproj -scheme FreezerTagTracker -destination 'platform=iOS Simulator,name=iPhone 17'
```

Run on a physical iPhone from Xcode to validate NFC. The simulator can exercise UI and local persistence paths, but cannot validate NFC hardware behaviour.

## How to test

Verified simulator test command:

```bash
cd "/Users/hudsonrebel/DTP Coding Projects/freezer-tag-poc"
xcodebuild test -project FreezerTagTracker.xcodeproj -scheme FreezerTagTracker -destination 'platform=iOS Simulator,name=iPhone 17'
```

Latest known result, 2026-05-27 19:21 BST:

- Test succeeded.
- `AddContainerFlowUITests`: 11 tests, 0 failures.
- The full Xcode run completed with `** TEST SUCCEEDED **`.

Manual NFC testing still required:

- Read an empty or prepared NDEF tag.
- Write a container record to an NFC tag.
- Read the same tag back and confirm the app opens the expected container record.
- Edit and clear/reuse flows with the same physical tag.
- Retry/error cases, including moving the phone away too early and using an unsupported or full tag.

## Architecture map

- `FreezerTagTracker/FreezerTagTrackerApp.swift` is the SwiftUI app entry point.
- `FreezerTagTracker/AppLaunchConfiguration.swift` switches dependencies for normal app launches and UI test launches.
- `FreezerTagTracker/Views/HomeView.swift` provides the two core entry points: add a container and scan a container.
- `FreezerTagTracker/Views/AddContainer/` contains the add-container flow, including details, review, writing and result screens.
- `FreezerTagTracker/Views/ScanView.swift`, `ContainerDetailView.swift` and `EditContainerView.swift` cover scan, view, edit and reuse paths.
- `FreezerTagTracker/Models/NFCManager.swift` wraps `CoreNFC`, including read/write session management, NDEF payload encoding, session cooldown handling and retry logic.
- `FreezerTagTracker/Models/ContainerRecord.swift` is the container data model.
- `FreezerTagTracker/Persistence/DataStore.swift` and Core Data model files handle local persistence.
- `FreezerTagTracker/Persistence/AddContainerSettingsStore.swift` stores add-flow settings through `UserDefaults`.
- `FreezerTagTracker/Utilities/FoodNameSpeechRecognizer.swift`, `SpokenFeedbackService.swift`, `HapticsService.swift` and `AccessibilityAnnouncementService.swift` support accessibility-first add-flow interactions.
- `FreezerTagTrackerTests/` covers models, date calculation, settings, data store and view-model logic.
- `FreezerTagTrackerUITests/AddContainerFlowUITests.swift` exercises the add-container user flow in the simulator.

## Dependencies and services

- **Platform:** iOS app, native Swift/SwiftUI.
- **Project format:** Xcode project plus `project.yml` for XcodeGen-style project definition.
- **Minimum target in current project:** iOS 15.0.
- **Language:** Swift 5.9.
- **Apple frameworks:** SwiftUI, Combine, CoreNFC, Core Data, Speech/AVFoundation-related system permissions.
- **Persistence:** local Core Data store plus `UserDefaults` for add-flow settings.
- **Backend:** none found.
- **Secrets/environment variables:** none found in the repo. The Info.plist contains usage descriptions for NFC, microphone and speech recognition permissions.

## Repository hygiene

Current repository state after verification:

- Git repo at `/Users/hudsonrebel/DTP Coding Projects/freezer-tag-poc`.
- Branch: `develop`.
- Current GitHub repo viewed by `gh`: `Digital-Technology-Partner-ai/freezer_tags`.
- Local `origin` prints as `https://github.com/Virgelsnake/freezer_tags.git`; this may be URL rewriting or a stale remote display and should be normalised to the DTP org URL if safe.
- Source snapshot/provenance path: `/Users/hudsonrebel/My Drive/DTP Inbox/freezer_tag_poc`.
- The inbox snapshot matched the coding-project copy except for Xcode workspace user-state data.
- Added `.gitignore` on 2026-05-27 to prevent future macOS, Xcode user state, build output, SwiftPM build folders, editor state and local secret files from entering the repo.
- Existing tracked Xcode user-state files have not been removed, because untracking/removing already tracked files is repo hygiene work that should be done as a normal scoped commit after Steve approves or a dedicated card is created.

## Related DTP records

- **Wiki product page:** `[[freezer-tag-poc]]`
- **Wiki project page:** None yet
- **Working Files folder:** None known
- **Kanban board:** `coding-projects`
- **Related client/project:** DTP-owned product candidate, no external client found in the source material
- **GitHub:** `https://github.com/Digital-Technology-Partner-ai/freezer_tags`

## Open questions

1. Which physical NFC tag type should Steve use for validation, for example NTAG213 or NTAG215?
2. Should the product store the full record on the tag, or only a tag ID with full data in local storage? The source PRD recommends the hybrid approach, but the implementation should be checked against real tag capacity.
3. Should cleared containers retain history locally, or should records be fully deleted?
4. What is the intended tag attachment method for freezer-safe, food-safe use: adhesive sticker, lid insert, reusable clip, or another approach?
5. Should DTP pursue this as a commercial product candidate after physical NFC validation, or treat it as a learning PoC only?
6. Should the local `origin` be repointed explicitly to `https://github.com/Digital-Technology-Partner-ai/freezer_tags.git`?

## Next recommended actions

Hudson-owned:

- Create a focused `coding-projects` card for physical GS1 NFC validation with exact manual checklist and proof-limit gates.
- Review Codex's GS1 Evidence Mode implementation and decide whether to promote the simulator/demo slice into a physical NFC pass.
- Add CSV/JSON import and native share-sheet export if Steve wants the GS1 market application to move beyond demo evidence.
- Normalise the local Git remote to the DTP organisation URL if verification shows this is a stale local display rather than an intentional rewrite.
- Create a scoped hygiene card to stop tracking Xcode user-state files without touching source code.

Steve-decision:

- Decide whether this remains a home-use experiment, becomes a DTP product candidate, or is parked after NFC feasibility testing.
- Provide or choose physical NFC tags and one NFC-capable iPhone for validation.
- Decide the desired tag attachment/reuse behaviour before any packaging work.

## Steve's notes

No repo-local Steve notes found during intake.
