# PRD: NFC Sheet Z-Order Fix

## Overview
After a successful NFC tag scan, Apple's native NFC system sheet ("Ready to Scan" popup) remains visible for ~1.5 seconds, obscuring the Container Details screen. This creates a clunky UX where the user sees the NFC popup lingering after the scan has already succeeded.

## Platforms & Release Targets
- **iOS 15+** (NFC NDEF reading requires iOS 13+, but app targets iOS 15+)
- iPhone only (NFC not available on iPad)

## Goal
Eliminate the visual delay between NFC scan success and Container Detail view appearing. The user should see the container card immediately with no NFC popup visible.

## User Story
As a user scanning a freezer container tag, I want to see the container details immediately after a successful scan, so that I don't have to wait for Apple's NFC popup to dismiss.

## Functional Requirements

### FR-1: Present Container Detail above NFC system sheet
The Container Detail view must appear above Apple's NFC system sheet immediately upon scan success, using a custom UIWindow with elevated window level.

### FR-2: Seamless transition
When the NFC system sheet eventually dismisses (in background), there should be no visual glitch or re-layout of the Container Detail view.

### FR-3: Proper cleanup
The custom UIWindow must be properly removed when the user dismisses the Container Detail view, returning control to the main app window.

## Acceptance Criteria

| ID | Criterion | Test Approach |
|----|-----------|---------------|
| AC-1 | Container Detail view is visible within 100ms of scan success callback | Manual timing via console logs |
| AC-2 | No NFC popup visible once Container Detail appears | Manual device test |
| AC-3 | Dismissing Container Detail returns to Home screen correctly | Manual device test |
| AC-4 | No memory leaks from UIWindow lifecycle | Instruments / Memory Graph |

## Definition of Done
- [ ] AC-1 through AC-4 pass on physical device
- [ ] Code compiles without warnings
- [ ] Existing unit tests pass

## Non-Goals (Out of Scope)
- Suppressing the NFC system sheet entirely (not possible with public APIs)
- Custom NFC reading UI (would require private APIs)
- Supporting iPad (no NFC hardware)

## Technical Approach

### Solution: Elevated UIWindow Presentation
Create a `OverlayWindowManager` that:
1. Creates a new `UIWindow` with `windowLevel = .alert + 1`
2. Sets a `UIHostingController` with the SwiftUI `ContainerDetailView` as root
3. Makes the window key and visible immediately on scan success
4. Removes the window when the user dismisses the detail view

### Key Files to Modify
- **New**: `FreezerTagTracker/Utilities/OverlayWindowManager.swift`
- **Modify**: `FreezerTagTracker/Views/HomeView.swift` — use OverlayWindowManager instead of `.fullScreenCover`
- **Modify**: `FreezerTagTracker/Views/ScanView.swift` — ensure callback timing is immediate

### Risk: Window Level May Not Be High Enough
Apple's NFC sheet may use a private window level higher than `.alert`. If `.alert + 1` doesn't work, we'll try progressively higher values (up to `.alert + 100`). If none work, we'll document the limitation.

## Open Questions
None — proceeding with implementation.
