# Handover Note: NFC Sheet Z-Order Issue

## Problem
After a successful NFC tag scan, Apple's native NFC system sheet ("Ready to Scan" popup with checkmark) remains visible for ~1.5 seconds, obscuring the Container Details screen that should appear immediately.

## What We Tried

### Approach 1: Remove success alert message
- Removed `session.alertMessage = "Container tag read successfully!"` before `session.invalidate()`
- **Result:** No effect - Apple's sheet has its own dismissal animation

### Approach 2: Present fullScreenCover immediately on success
- Show ContainerDetailView in a fullScreenCover as soon as scan succeeds
- **Result:** fullScreenCover appears BEHIND Apple's NFC sheet

### Approach 3: Move fullScreenCover to app root level
- Moved `.fullScreenCover` modifier outside NavigationView to present at root level
- **Result:** Still appears BEHIND Apple's NFC sheet

## Root Cause
Apple's `NFCNDEFReaderSession` presents its UI in a **system-level window** with a very high window level (likely `UIWindow.Level.alert` or higher). Standard SwiftUI presentations (sheets, fullScreenCover) cannot appear above it.

## Timing Analysis (from logs)
- Our code executes in ~0.001s after scan success
- `session.invalidate()` returns immediately (0.000s)
- But Apple's NFC sheet takes ~1-1.5s to animate away
- This is iOS system behavior we cannot directly control

## Untried Approaches

### 1. UIWindow with Higher Window Level (Most Promising)
Create a custom UIWindow with `windowLevel = .alert + 1` or higher and present the ContainerDetailView there.

```swift
// Pseudocode
let window = UIWindow(windowScene: scene)
window.windowLevel = .alert + 1
window.rootViewController = UIHostingController(rootView: ContainerDetailView(...))
window.makeKeyAndVisible()
```

### 2. Delay Navigation Until NFC Sheet Dismisses
Accept the delay and wait for `didInvalidateWithError` before showing UI. Not ideal UX but guaranteed to work.

### 3. Custom NFC Reading Without System Sheet
Use lower-level Core NFC APIs that don't show the system sheet. Requires significant refactoring and may have App Store review implications.

## Key Files
- `/FreezerTagTracker/Models/NFCManager.swift` - NFC session management
- `/FreezerTagTracker/Views/HomeView.swift` - Scan flow and presentation logic
- `/FreezerTagTracker/Views/ScanView.swift` - Scan initiation

## Timing Logs Available
The codebase has detailed timing logs (`⏱️` prefix) throughout the NFC flow. Run a scan and check Xcode console to trace execution.

## Recommendation
Try the **UIWindow approach** - it's the only way to present UI above a system-level window. Will require UIKit/SwiftUI bridging.
