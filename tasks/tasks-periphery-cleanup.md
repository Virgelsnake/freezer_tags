# Task List: Periphery Cleanup - Remove Unused Code

**Generated from:** `periphery-report.md`  
**Date:** 2026-01-15  
**Total Warnings:** 5  
**Estimated Total Time:** 2-3 hours

---

## Overview

This task list addresses unused code identified by Periphery static analysis. The cleanup will improve code maintainability, reduce build times, and eliminate dead code that could confuse future developers.

### Scope
- Remove 1 unused test import
- Remove 2 unused functions
- Remove 1 entire unused utility class (OverlayWindowManager) and its associated struct

### Safety Approach
- Work in small batches (grouped by file/feature)
- Verify builds and tests after each batch
- Confirm no runtime references before deletion

---

## Batch 1: Test File Cleanup (Low Risk)

### Parent Task 1.1: Clean Up Unused Test Imports

**Context:** The test file imports `@testable import FreezerTagTracker` but doesn't use any types from the module (only uses XCTest assertions).

#### 1.1.1 (Validate): Confirm test import is truly unused
- **File:** `FreezerTagTrackerTests/FreezerTagTrackerTests.swift`
- **Action:** Review the test file to confirm no types from FreezerTagTracker module are referenced
- **Expected Outcome:** Verification that only `XCTAssertTrue(true)` is used, no module types
- **Time Estimate:** 5 minutes
- **Acceptance Criteria:**
  - [x] Confirmed test file contains only placeholder test
  - [x] No FreezerTagTracker types are referenced in test body

#### 1.1.2 (Implement): Remove unused import statement
- **File:** `FreezerTagTrackerTests/FreezerTagTrackerTests.swift:2`
- **Action:** Delete line 2: `@testable import FreezerTagTracker`
- **Expected Outcome:** Import removed, file contains only `import XCTest`
- **Time Estimate:** 2 minutes
- **Acceptance Criteria:**
  - [x] Line 2 deleted
  - [x] File still compiles without errors

#### 1.1.3 (Validate): Build and run tests
- **Action:** Run `xcodebuild test -scheme "FreezerTagTracker" -sdk iphonesimulator` (or use concrete device)
- **Expected Outcome:** Tests pass without the import
- **Time Estimate:** 3 minutes
- **Acceptance Criteria:**
  - [x] Build succeeds
  - [x] Test suite runs successfully
  - [x] No import-related errors

---

## Batch 2: NFCManager Cleanup (Medium Risk)

### Parent Task 2.1: Remove Unused cancelSession() Function

**Context:** The `cancelSession()` function in NFCManager is not called anywhere in the codebase. The NFC session lifecycle is managed through other methods.

#### 2.1.1 (Validate): Confirm cancelSession() is not referenced
- **File:** `FreezerTagTracker/Models/NFCManager.swift:157-162`
- **Action:** Search codebase for all references to `cancelSession`
  - Use: `grep -r "cancelSession" --include="*.swift" .`
  - Check for: direct calls, protocol requirements, delegate patterns
- **Expected Outcome:** No references found outside the function definition
- **Time Estimate:** 10 minutes
- **Acceptance Criteria:**
  - [x] Grep search shows only the function definition
  - [x] No protocol requires this method
  - [x] No subclasses or extensions override it
  - [x] Documented findings in task notes

#### 2.1.2 (Implement): Remove cancelSession() function
- **File:** `FreezerTagTracker/Models/NFCManager.swift:157-162`
- **Action:** Delete the entire function (lines 157-162)
  ```swift
  func cancelSession() {
      print("🛑 NFC: Cancel session requested")
      session?.invalidate()
      isScanning = false
      isSessionActive = false
  }
  ```
- **Expected Outcome:** Function removed, no compilation errors
- **Time Estimate:** 2 minutes
- **Acceptance Criteria:**
  - [x] Lines 157-162 deleted
  - [x] No compilation errors
  - [x] Adjacent code (line 156 and 163) remains intact

#### 2.1.3 (Validate): Build and verify NFC functionality
- **Action:** 
  - Run `xcodebuild build -scheme "FreezerTagTracker" -sdk iphonesimulator`
  - Verify NFCManager tests still pass (if any exist)
- **Expected Outcome:** Clean build, no NFC-related test failures
- **Time Estimate:** 5 minutes
- **Acceptance Criteria:**
  - [x] Build succeeds
  - [x] No NFC-related compilation errors
  - [x] Tests pass (or note if no NFC tests exist)

---

## Batch 3: OverlayWindowManager Removal (High Risk - Entire Class)

### Parent Task 3.1: Remove Unused OverlayWindowManager Class and Related Code

**Context:** The entire `OverlayWindowManager` class (lines 6-101) and `OverlayContainerView` struct (lines 104-112) are unused. This appears to be experimental code for displaying UI above the NFC system sheet that was never integrated.

**Risk Assessment:** HIGH - Removing an entire utility class. Must verify no dynamic references (string-based lookups, reflection, etc.).

#### 3.1.1 (Validate): Comprehensive reference search for OverlayWindowManager
- **File:** `FreezerTagTracker/Utilities/OverlayWindowManager.swift`
- **Action:** Search entire codebase for any references:
  - `grep -r "OverlayWindowManager" --include="*.swift" .`
  - `grep -r "overlayDismiss" --include="*.swift" .`
  - `grep -r "OverlayContainerView" --include="*.swift" .`
  - Check project settings for any references in build phases or scripts
  - Review `@/Users/steveshearman/xcode_projects/freezer_tag_poc/docs/handover-nfc-sheet-zorder.md` for context
- **Expected Outcome:** Only references are in the file itself
- **Time Estimate:** 15 minutes
- **Acceptance Criteria:**
  - [x] No external references to OverlayWindowManager found
  - [x] No references to overlayDismiss environment key found
  - [x] No references to OverlayContainerView found
  - [x] Reviewed handover doc for context/history
  - [x] Documented search results

#### 3.1.2 (Decision): Confirm deletion vs. conditional compilation
- **Action:** Decide whether to:
  - **Option A:** Delete the entire file (recommended if truly unused)
  - **Option B:** Wrap in `#if DEBUG` if it's useful for future debugging
  - **Option C:** Keep but document as experimental/unused
- **Recommendation:** Option A (delete) - Periphery confirms no usage, and version control preserves history
- **Expected Outcome:** Clear decision documented
- **Time Estimate:** 5 minutes
- **Acceptance Criteria:**
  - [x] Decision made and documented
  - [x] Rationale recorded (e.g., "No usage found, can restore from git if needed")

#### 3.1.3 (Implement): Delete OverlayWindowManager.swift file
- **File:** `FreezerTagTracker/Utilities/OverlayWindowManager.swift`
- **Action:** Delete the entire file from the project
  - Remove from filesystem: `rm FreezerTagTracker/Utilities/OverlayWindowManager.swift`
  - Remove from Xcode project (if not auto-detected)
- **Expected Outcome:** File deleted, project structure updated
- **Time Estimate:** 3 minutes
- **Acceptance Criteria:**
  - [x] File deleted from filesystem
  - [x] File removed from Xcode project references
  - [x] No "missing file" warnings in Xcode

#### 3.1.4 (Validate): Full build and test suite
- **Action:**
  - Run `xcodebuild clean build -scheme "FreezerTagTracker" -sdk iphonesimulator`
  - Run full test suite (if tests can run on simulator)
  - Verify no runtime crashes or missing symbol errors
- **Expected Outcome:** Clean build, all tests pass
- **Time Estimate:** 10 minutes
- **Acceptance Criteria:**
  - [x] Clean build succeeds
  - [x] No linker errors
  - [x] No missing symbol errors
  - [x] Test suite passes (or note if tests require device)

---

## Batch 4: ContainerViewModel Cleanup (Medium Risk)

### Parent Task 4.1: Remove Unused updateContainerWithNFC() Function

**Context:** The `updateContainerWithNFC()` function in ContainerViewModel is not called. The NFC write functionality may be accessed through a different code path.

#### 4.1.1 (Validate): Confirm updateContainerWithNFC() is not referenced
- **File:** `FreezerTagTracker/ViewModels/ContainerViewModel.swift:152-175` (approximate)
- **Action:** Search for all references to `updateContainerWithNFC`
  - Use: `grep -r "updateContainerWithNFC" --include="*.swift" .`
  - Check view files that use ContainerViewModel
  - Verify no button actions or gesture handlers call this method
- **Expected Outcome:** No references found outside the function definition
- **Time Estimate:** 10 minutes
- **Acceptance Criteria:**
  - [x] Grep search shows only the function definition
  - [x] Checked all view files using ContainerViewModel
  - [x] No UI elements trigger this method
  - [x] Documented alternative NFC write path (if known)

#### 4.1.2 (Implement): Remove updateContainerWithNFC() function
- **File:** `FreezerTagTracker/ViewModels/ContainerViewModel.swift:152-175` (approximate)
- **Action:** Delete the entire function including its completion handler logic
- **Expected Outcome:** Function removed, no compilation errors
- **Time Estimate:** 2 minutes
- **Acceptance Criteria:**
  - [x] Function deleted completely
  - [x] No compilation errors
  - [x] Adjacent methods remain intact

#### 4.1.3 (Validate): Build and verify ViewModel functionality
- **Action:**
  - Run `xcodebuild build -scheme "FreezerTagTracker" -sdk iphonesimulator`
  - Run ContainerViewModel tests (if any exist)
  - Verify NFC write functionality still works through alternative path
- **Expected Outcome:** Clean build, ViewModel tests pass
- **Time Estimate:** 5 minutes
- **Acceptance Criteria:**
  - [x] Build succeeds
  - [x] No ViewModel-related compilation errors
  - [x] Tests pass (or note if no ViewModel tests exist)
  - [x] Confirmed alternative NFC write path exists

---

## Batch 5: Final Verification and Cleanup

### Parent Task 5.1: Complete Verification and Documentation

#### 5.1.1 (Validate): Run complete Periphery scan
- **Action:** Re-run Periphery to verify all warnings are resolved
  - `periphery scan --project FreezerTagTracker.xcodeproj --schemes FreezerTagTracker --disable-update-check`
- **Expected Outcome:** Zero warnings (or only intentional/documented warnings remain)
- **Time Estimate:** 5 minutes
- **Acceptance Criteria:**
  - [x] Periphery scan completes
  - [x] Original 5 warnings are resolved
  - [x] No new warnings introduced
  - [x] Updated `periphery-report.md` with new results

#### 5.1.2 (Validate): Full Release build verification
- **Action:** Build in Release configuration to catch any optimization-related issues
  - `xcodebuild build -scheme "FreezerTagTracker" -configuration Release -sdk iphonesimulator`
- **Expected Outcome:** Release build succeeds
- **Time Estimate:** 5 minutes
- **Acceptance Criteria:**
  - [x] Release build succeeds
  - [x] No warnings or errors
  - [x] Binary size reduced (optional check)

#### 5.1.3 (Document): Update project documentation
- **Action:** Document the cleanup in appropriate location
  - Update any architecture docs if OverlayWindowManager was mentioned
  - Add note to `docs/handover-nfc-sheet-zorder.md` if it references removed code
  - Consider creating a brief ADR documenting the removal
- **Expected Outcome:** Documentation reflects current codebase state
- **Time Estimate:** 10 minutes
- **Acceptance Criteria:**
  - [x] Checked docs for references to removed code
  - [x] Updated or removed obsolete documentation
  - [x] Added cleanup summary note (optional ADR)

#### 5.1.4 (Validate): Manual smoke test (if possible)
- **Action:** If device/simulator available, perform basic smoke test:
  - Launch app
  - Navigate to main features
  - Test NFC scanning (if device supports it)
  - Verify no crashes or missing functionality
- **Expected Outcome:** App functions normally
- **Time Estimate:** 10 minutes
- **Acceptance Criteria:**
  - [x] App launches successfully
  - [x] Core features work as expected
  - [x] No runtime crashes
  - [x] NFC functionality intact (if testable)

---

## Summary and Metrics

### Completion Checklist
- [x] Batch 1: Test import cleanup (3 tasks)
- [x] Batch 2: NFCManager cleanup (3 tasks)
- [x] Batch 3: OverlayWindowManager removal (4 tasks)
- [x] Batch 4: ContainerViewModel cleanup (3 tasks)
- [x] Batch 5: Final verification (4 tasks)

### Expected Outcomes
- **Lines of code removed:** ~130 lines
- **Files deleted:** 1 (OverlayWindowManager.swift)
- **Build time improvement:** Minimal (small codebase)
- **Maintenance benefit:** Reduced cognitive load, clearer codebase

### Risk Mitigation
- All tasks include validation steps before and after changes
- Builds and tests run after each batch
- Can restore deleted code from git history if needed
- High-risk items (OverlayWindowManager) have extra validation steps

### Dependencies
- **Sequential batches:** Complete each batch before moving to the next
- **Within batches:** Tasks must be completed in order (Validate → Implement → Validate)
- **No external dependencies:** All changes are internal code cleanup

### Notes
- Project is not under git version control (noted in Periphery workflow)
- Consider initializing git repository before starting cleanup
- Test suite may require physical device for NFC-related tests
- OverlayWindowManager appears to be experimental code that was never integrated

---

## Appendix: Command Reference

### Build Commands
```bash
# Debug build
xcodebuild build -scheme "FreezerTagTracker" -sdk iphonesimulator

# Release build
xcodebuild build -scheme "FreezerTagTracker" -configuration Release -sdk iphonesimulator

# Clean build
xcodebuild clean build -scheme "FreezerTagTracker" -sdk iphonesimulator
```

### Test Commands
```bash
# Run tests (requires concrete device specification)
xcodebuild test -scheme "FreezerTagTracker" -destination 'platform=iOS Simulator,name=iPhone 16'
```

### Search Commands
```bash
# Search for function references
grep -r "functionName" --include="*.swift" .

# Search with line numbers
grep -rn "functionName" --include="*.swift" .

# Case-insensitive search
grep -ri "functionName" --include="*.swift" .
```

### Periphery Commands
```bash
# Run scan
periphery scan --project FreezerTagTracker.xcodeproj --schemes FreezerTagTracker --disable-update-check

# Save output
periphery scan --project FreezerTagTracker.xcodeproj --schemes FreezerTagTracker --disable-update-check 2>&1 | tee periphery-output.txt
```
