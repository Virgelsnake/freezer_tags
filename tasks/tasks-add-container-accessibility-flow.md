# Task List: Add Container Accessibility-First Flow

**Source docs:**
- [add-container-ux-spec.md](/Users/steveshearman/xcode_projects/freezer_tag_poc/docs/add-container-ux-spec.md)
- [add-container-wireframes.md](/Users/steveshearman/xcode_projects/freezer_tag_poc/docs/add-container-wireframes.md)
- [add-container-swiftui-implementation-plan.md](/Users/steveshearman/xcode_projects/freezer_tag_poc/docs/add-container-swiftui-implementation-plan.md)

**Project type:** Existing SwiftUI app enhancement  
**Goal:** Replace the current one-step add form with a two-step accessibility-first add flow with USDA presets, review-before-write, spoken guidance, haptics, and editable app settings  
**Generated:** April 9, 2026

---

## Overview

This backlog breaks the add-container redesign into small, buildable tickets that can be shipped in sequence. Each ticket is intended to be a realistic unit of work for one commit or one focused PR chunk.

**Build principles:**
- Keep existing scan/detail behavior stable while refactoring the add flow
- Prefer small vertical slices over large framework-only work
- Treat accessibility support as part of the feature, not a follow-up
- Preserve the current NFC manager unless a ticket explicitly changes it

---

## Phase 1: Data and Settings Foundation

### Ticket 1.1: Add `FoodCategory` model

**Files:**
- `FreezerTagTracker/Models/FoodCategory.swift`

**Work:**
- Create `FoodCategory` enum
- Conform to `String`, `Codable`, `CaseIterable`, `Hashable`
- Add user-facing display names

**Acceptance:**
- Enum compiles
- Categories match the UX spec: Beef, Poultry, Fish, Prepared meal, Pastries, Vegetables, Other

**Estimate:** 15 minutes

### Ticket 1.2: Extend `ContainerRecord` with category

**Files:**
- [ContainerRecord.swift](/Users/steveshearman/xcode_projects/freezer_tag_poc/FreezerTagTracker/Models/ContainerRecord.swift)
- [ContainerRecordTests.swift](/Users/steveshearman/xcode_projects/freezer_tag_poc/FreezerTagTrackerTests/ContainerRecordTests.swift)

**Work:**
- Add `foodCategory: FoodCategory?`
- Update initializers, codable support, and tests

**Acceptance:**
- Existing model tests pass
- Records can still be encoded and decoded

**Estimate:** 30 minutes

### Ticket 1.3: Add Core Data support for category

**Files:**
- Core Data model file
- [ContainerEntity+CoreDataProperties.swift](/Users/steveshearman/xcode_projects/freezer_tag_poc/FreezerTagTracker/Persistence/ContainerEntity+CoreDataProperties.swift)
- [DataStore.swift](/Users/steveshearman/xcode_projects/freezer_tag_poc/FreezerTagTracker/Persistence/DataStore.swift)
- [DataStoreTests.swift](/Users/steveshearman/xcode_projects/freezer_tag_poc/FreezerTagTrackerTests/DataStoreTests.swift)

**Work:**
- Add optional `foodCategory` field to the entity
- Map it in save, update, fetch, and conversion paths
- Update tests

**Acceptance:**
- Existing records still load
- New records persist and fetch category correctly

**Estimate:** 45 minutes

### Ticket 1.4: Create app settings model

**Files:**
- `FreezerTagTracker/Models/AccessibilityPreferences.swift`

**Work:**
- Add struct for app-owned settings:
  - spoken guidance
  - spoken confirmations
  - haptics
  - show microphone shortcut

**Acceptance:**
- Defaults match product decision: all `On`

**Estimate:** 20 minutes

### Ticket 1.5: Create preset model

**Files:**
- `FreezerTagTracker/Models/FoodPreset.swift`

**Work:**
- Add preset model keyed by `FoodCategory`
- Support month-based defaults and user overrides

**Acceptance:**
- Preset model can represent both fixed defaults and edited values

**Estimate:** 20 minutes

### Ticket 1.6: Add lightweight settings store

**Files:**
- `FreezerTagTracker/Utilities/AppSettingsStore.swift`
- new unit test file if added

**Work:**
- Persist accessibility toggles and preset overrides with `UserDefaults` or `AppStorage`
- Expose getters/setters for app settings and preset months

**Acceptance:**
- Settings persist across relaunch
- Preset overrides can be read and updated independently

**Estimate:** 45 minutes

---

## Phase 2: Preset Date Logic

### Ticket 2.1: Create USDA best-quality calculator

**Files:**
- `FreezerTagTracker/Utilities/BestQualityDateCalculator.swift`
- new unit test file

**Work:**
- Implement default month suggestions for each category
- Read overrides from settings store
- Return suggested date from `dateFrozen`

**Acceptance:**
- Categories return expected default dates
- `Other` returns no automatic date

**Estimate:** 45 minutes

### Ticket 2.2: Add preset copy helpers

**Files:**
- `FreezerTagTracker/Utilities/BestQualityDateCalculator.swift`
- optionally `FoodPreset.swift`

**Work:**
- Add helper text for UI:
  - `Suggested date based on USDA guidance`
  - preset display labels

**Acceptance:**
- The UI can render preset labels and source copy without local string duplication

**Estimate:** 20 minutes

---

## Phase 3: Add Flow State and Routing

### Ticket 3.1: Create add-flow draft model

**Files:**
- `FreezerTagTracker/Models/AddContainerDraft.swift`

**Work:**
- Add editable draft state:
  - food name
  - selected category
  - date frozen
  - best-quality date
  - notes
  - state for manual best-date override

**Acceptance:**
- Draft can fully represent both step 1 and step 2 data

**Estimate:** 30 minutes

### Ticket 3.2: Create step/result enums

**Files:**
- `FreezerTagTracker/Models/AddContainerStep.swift`
- `FreezerTagTracker/Models/TagWriteResult.swift`

**Work:**
- Model screens and result states:
  - details
  - review
  - writing
  - success
  - failure

**Acceptance:**
- Add flow can be driven from enum state rather than boolean flags

**Estimate:** 20 minutes

### Ticket 3.3: Create `AddContainerFlowViewModel`

**Files:**
- `FreezerTagTracker/ViewModels/AddContainerFlowViewModel.swift`
- new unit test file

**Work:**
- Add published draft/step/validation state
- Add methods for:
  - selecting preset
  - editing fields
  - validating food name
  - moving to review
  - going back

**Acceptance:**
- View model supports step 1 and step 2 without NFC yet
- Validation message appears when name is empty

**Estimate:** 60 minutes

---

## Phase 4: Step 1 UI

### Ticket 4.1: Build preset button component

**Files:**
- `FreezerTagTracker/Views/Components/FoodPresetButton.swift`

**Work:**
- Create reusable preset button with default and selected states
- Support Dynamic Type and accessibility labels

**Acceptance:**
- Presets are clearly selectable and readable at larger text sizes

**Estimate:** 30 minutes

### Ticket 4.2: Build date row component

**Files:**
- `FreezerTagTracker/Views/Components/LabeledDateRow.swift`

**Work:**
- Create reusable row for `Date frozen` and `Best quality by`
- Support empty and filled states

**Acceptance:**
- Rows are tappable, readable, and not dependent on tiny inline date pickers

**Estimate:** 25 minutes

### Ticket 4.3: Build notes component with counter

**Files:**
- `FreezerTagTracker/Views/Components/CharacterCountTextEditor.swift`

**Work:**
- Create notes editor with placeholder and 200-character counter
- Add accessibility value/hint support

**Acceptance:**
- Notes counter updates correctly and remains readable with long text sizes

**Estimate:** 30 minutes

### Ticket 4.4: Build `AddContainerDetailsView`

**Files:**
- `FreezerTagTracker/Views/AddContainer/AddContainerDetailsView.swift`

**Work:**
- Replace the current form style with the new custom step-1 layout
- Hook it to `AddContainerFlowViewModel`
- Add disabled `Review and write to tag` behavior

**Acceptance:**
- User can fill the draft and move to review
- Screen copy matches the UX spec

**Estimate:** 75 minutes

### Ticket 4.5: Add large-text layout pass for step 1

**Files:**
- `FreezerTagTracker/Views/AddContainer/AddContainerDetailsView.swift`
- related components

**Work:**
- Make mic button stack below the field when space is tight
- Let presets wrap or stack full-width

**Acceptance:**
- Screen remains usable at Accessibility XXL

**Estimate:** 30 minutes

---

## Phase 5: Step 2 Review UI

### Ticket 5.1: Build summary card component

**Files:**
- `FreezerTagTracker/Views/Components/ContainerSummaryCard.swift`

**Work:**
- Create reusable summary card for review and success screens
- Hide empty notes row automatically

**Acceptance:**
- Card presents key values in a glanceable layout

**Estimate:** 30 minutes

### Ticket 5.2: Build `AddContainerReviewView`

**Files:**
- `FreezerTagTracker/Views/AddContainer/AddContainerReviewView.swift`

**Work:**
- Render step 2 summary
- Wire `Write to tag` and `Go back and change`

**Acceptance:**
- User can review entered data and navigate back safely

**Estimate:** 45 minutes

---

## Phase 6: Flow Container and Navigation

### Ticket 6.1: Build `AddContainerFlowView`

**Files:**
- `FreezerTagTracker/Views/AddContainer/AddContainerFlowView.swift`

**Work:**
- Host the multi-step flow
- Render details/review/result screens based on flow state

**Acceptance:**
- Flow no longer relies on the old one-screen `AddContainerView` structure

**Estimate:** 45 minutes

### Ticket 6.2: Replace current add-screen entry point

**Files:**
- [AddContainerView.swift](/Users/steveshearman/xcode_projects/freezer_tag_poc/FreezerTagTracker/Views/AddContainerView.swift)
- [HomeView.swift](/Users/steveshearman/xcode_projects/freezer_tag_poc/FreezerTagTracker/Views/HomeView.swift)

**Work:**
- Either wrap the new flow in `AddContainerView` or point `HomeView` to the new flow directly

**Acceptance:**
- Tapping `Add Container` opens the new flow

**Estimate:** 20 minutes

---

## Phase 7: NFC Write Integration

### Ticket 7.1: Move add-flow write orchestration out of the old form

**Files:**
- `FreezerTagTracker/ViewModels/AddContainerFlowViewModel.swift`
- [NFCManager.swift](/Users/steveshearman/xcode_projects/freezer_tag_poc/FreezerTagTracker/Models/NFCManager.swift)
- [DataStore.swift](/Users/steveshearman/xcode_projects/freezer_tag_poc/FreezerTagTracker/Persistence/DataStore.swift)

**Work:**
- Construct `ContainerRecord` from the draft
- Start tag writing from the flow model
- Persist to Core Data only after a successful write

**Acceptance:**
- Failed writes do not create saved records
- Successful writes do save records

**Estimate:** 60 minutes

### Ticket 7.2: Build `TagWritingView`

**Files:**
- `FreezerTagTracker/Views/AddContainer/TagWritingView.swift`

**Work:**
- Add quiet companion screen for the active write state
- Match the wireframe copy and layout

**Acceptance:**
- User sees clear pre/post-NFC guidance while the system sheet is active

**Estimate:** 30 minutes

### Ticket 7.3: Add write result screen

**Files:**
- `FreezerTagTracker/Views/AddContainer/TagWriteResultView.swift`

**Work:**
- Render success and failure states from `TagWriteResult`
- Add buttons for retry, back, done, and replay

**Acceptance:**
- Success and failure states are distinct and fully navigable

**Estimate:** 45 minutes

### Ticket 7.4: Add retry path for failed writes

**Files:**
- `FreezerTagTracker/ViewModels/AddContainerFlowViewModel.swift`
- `FreezerTagTracker/Views/AddContainer/TagWriteResultView.swift`

**Work:**
- Wire `Try again` back into the writing path
- Preserve the draft across failure

**Acceptance:**
- User can fail a write and retry without re-entering the form

**Estimate:** 30 minutes

---

## Phase 8: Spoken Guidance and Replay

### Ticket 8.1: Create speech service

**Files:**
- `FreezerTagTracker/Utilities/SpokenFeedbackService.swift`

**Work:**
- Wrap `AVSpeechSynthesizer`
- Add methods for short prompts and full detail replay

**Acceptance:**
- Service can speak short and long messages on demand

**Estimate:** 45 minutes

### Ticket 8.2: Create VoiceOver announcement service

**Files:**
- `FreezerTagTracker/Utilities/AccessibilityAnnouncementService.swift`

**Work:**
- Centralize `UIAccessibility.post` calls
- Add helpers for screen arrival and validation announcements

**Acceptance:**
- Views no longer need raw accessibility post calls scattered through the UI

**Estimate:** 30 minutes

### Ticket 8.3: Add spoken step guidance

**Files:**
- `FreezerTagTracker/ViewModels/AddContainerFlowViewModel.swift`
- add-flow views

**Work:**
- Speak or announce:
  - add-screen arrival
  - preset selection
  - review-screen arrival
  - write start
  - validation errors

**Acceptance:**
- Spoken guidance is on by default
- VoiceOver users do not hear duplicate overlapping speech

**Estimate:** 60 minutes

### Ticket 8.4: Add replayable success summary

**Files:**
- `FreezerTagTracker/Views/Components/SpokenReplayButton.swift`
- `FreezerTagTracker/ViewModels/AddContainerFlowViewModel.swift`
- result view

**Work:**
- Add `Read details again`
- Generate full spoken summary from the saved draft/result

**Acceptance:**
- Success screen can replay the full saved details on demand

**Estimate:** 30 minutes

---

## Phase 9: Haptics

### Ticket 9.1: Create haptics service

**Files:**
- `FreezerTagTracker/Utilities/HapticsService.swift`

**Work:**
- Map app events to system haptics

**Acceptance:**
- Service can trigger preset tap, action tap, success, and failure haptics

**Estimate:** 30 minutes

### Ticket 9.2: Wire haptics into the add flow

**Files:**
- `FreezerTagTracker/ViewModels/AddContainerFlowViewModel.swift`
- add-flow views
- optionally `NFCManager.swift`

**Work:**
- Trigger haptics on:
  - preset selection
  - write start
  - tag detection if feasible
  - success
  - failure

**Acceptance:**
- Haptic feedback aligns with the UX spec and respects the app toggle

**Estimate:** 45 minutes

---

## Phase 10: Settings UI

### Ticket 10.1: Add `SettingsViewModel`

**Files:**
- `FreezerTagTracker/ViewModels/SettingsViewModel.swift`

**Work:**
- Bind `AppSettingsStore` to SwiftUI-friendly state

**Acceptance:**
- Settings screen can load and save preferences cleanly

**Estimate:** 25 minutes

### Ticket 10.2: Build `SettingsView`

**Files:**
- `FreezerTagTracker/Views/Settings/SettingsView.swift`
- [HomeView.swift](/Users/steveshearman/xcode_projects/freezer_tag_poc/FreezerTagTracker/Views/HomeView.swift)

**Work:**
- Add toggles for spoken guidance, spoken confirmations, haptics, and mic shortcut
- Add navigation to food preset editor
- Add a Home screen entry point

**Acceptance:**
- User can open Settings and change toggles

**Estimate:** 45 minutes

### Ticket 10.3: Build `FoodPresetEditorView`

**Files:**
- `FreezerTagTracker/Views/Settings/FoodPresetEditorView.swift`

**Work:**
- Let user edit month values by category
- Add `Reset to app default`

**Acceptance:**
- Preset overrides are editable and persist after relaunch

**Estimate:** 45 minutes

---

## Phase 11: Accessibility Hardening

### Ticket 11.1: Add explicit VoiceOver labels and hints

**Files:**
- all new add-flow views and components

**Work:**
- Add labels, values, hints, and traits per UX spec

**Acceptance:**
- VoiceOver can navigate the full add flow without ambiguous controls

**Estimate:** 60 minutes

### Ticket 11.2: Add accessibility grouping and focus-order cleanup

**Files:**
- all new add-flow views

**Work:**
- Group sections intentionally
- Ensure top-to-bottom focus order

**Acceptance:**
- Focus order matches the wireframes and does not trap the user

**Estimate:** 45 minutes

### Ticket 11.3: Add Reduce Motion and color-independent states

**Files:**
- `TagWritingView`
- `TagWriteResultView`
- preset and summary components

**Work:**
- Respect `Reduce Motion`
- Ensure status is never color-only

**Acceptance:**
- Flow remains understandable with motion reduced and without relying on color

**Estimate:** 30 minutes

---

## Phase 12: Testing and Verification

### Ticket 12.1: Add unit tests for preset calculator

**Files:**
- new calculator test file

**Work:**
- Test default categories and user overrides

**Acceptance:**
- USDA preset dates are covered by tests

**Estimate:** 30 minutes

### Ticket 12.2: Add unit tests for add-flow view model

**Files:**
- new `AddContainerFlowViewModelTests.swift`

**Work:**
- Test validation, preset selection, navigation, write success, write failure, retry

**Acceptance:**
- Core add-flow behavior is test-covered

**Estimate:** 60 minutes

### Ticket 12.3: Add UI smoke tests for the new flow

**Files:**
- UI test target if present

**Work:**
- Cover:
  - details to review
  - back navigation
  - success state
  - failure state
  - settings toggle change

**Acceptance:**
- New flow has at least basic end-to-end UI coverage

**Estimate:** 60 minutes

### Ticket 12.4: Manual accessibility verification pass

**Files:**
- test notes or checklist if recorded

**Work:**
- Verify with:
  - VoiceOver
  - Dynamic Type Accessibility XXL
  - Reduce Motion
  - spoken guidance off
  - haptics off

**Acceptance:**
- Known issues are captured and triaged before shipping

**Estimate:** 45 minutes

---

## Suggested PR Sequence

### PR 1: Foundation

- Tickets 1.1 to 2.2
- Tickets 3.1 to 3.3

### PR 2: New add flow UI

- Tickets 4.1 to 6.2

### PR 3: NFC results and retry

- Tickets 7.1 to 7.4

### PR 4: Speech, haptics, and settings

- Tickets 8.1 to 10.3

### PR 5: Accessibility hardening and tests

- Tickets 11.1 to 12.4

---

## Definition of Done

The task list is complete when:

- the add flow is two-step
- USDA presets auto-fill editable best-quality dates
- records persist category data
- writes occur only after review
- success and failure states are explicit
- spoken guidance and haptics are app-controlled in Settings
- VoiceOver and large text are fully supported
- the flow is covered by tests and a manual accessibility pass
