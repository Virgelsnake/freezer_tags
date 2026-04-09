# Freezer Tag Tracker - SwiftUI Implementation Plan for Add Container Flow

**Date:** 9 April 2026
**Related docs:**
- [add-container-ux-spec.md](/Users/steveshearman/xcode_projects/freezer_tag_poc/docs/add-container-ux-spec.md)
- [add-container-wireframes.md](/Users/steveshearman/xcode_projects/freezer_tag_poc/docs/add-container-wireframes.md)
- [design-brief-mobile-ui.md](/Users/steveshearman/xcode_projects/freezer_tag_poc/docs/design-brief-mobile-ui.md)

## 1. Current Codebase Snapshot

The current implementation already has the core ingredients for the feature, but the add flow is still too flat for the UX we want.

Current files involved:

- [AddContainerView.swift](/Users/steveshearman/xcode_projects/freezer_tag_poc/FreezerTagTracker/Views/AddContainerView.swift)
- [HomeView.swift](/Users/steveshearman/xcode_projects/freezer_tag_poc/FreezerTagTracker/Views/HomeView.swift)
- [ContainerViewModel.swift](/Users/steveshearman/xcode_projects/freezer_tag_poc/FreezerTagTracker/ViewModels/ContainerViewModel.swift)
- [NFCManager.swift](/Users/steveshearman/xcode_projects/freezer_tag_poc/FreezerTagTracker/Models/NFCManager.swift)
- [ContainerRecord.swift](/Users/steveshearman/xcode_projects/freezer_tag_poc/FreezerTagTracker/Models/ContainerRecord.swift)
- [DataStore.swift](/Users/steveshearman/xcode_projects/freezer_tag_poc/FreezerTagTracker/Persistence/DataStore.swift)

Current behavior:

- `AddContainerView` is a single `Form`.
- The `Save & Scan Tag` button immediately starts the NFC write.
- There is no review step.
- There are no food presets or app-owned accessibility settings.
- Spoken feedback, haptic coordination, and replayable confirmation are not modeled yet.
- `ContainerRecord` does not store a food category.

That means this is best handled as a focused add-flow refactor, not a small patch to the existing form.

## 2. Target Architecture

### 2.1 High-level split

Keep `ContainerViewModel` responsible for container persistence and scan/read actions already used elsewhere.

Introduce a dedicated add-flow coordinator for the new UX:

- `AddContainerFlowViewModel`
- `AddContainerDraft`
- `FoodPreset`
- `AccessibilityPreferences`
- `AddContainerFeedbackCoordinator`

This keeps the multi-step write flow, speech, haptics, and step transitions out of the general-purpose container list model.

### 2.2 Recommended folder structure

Add the following files under the existing project structure:

**Views**
- `Views/AddContainer/AddContainerFlowView.swift`
- `Views/AddContainer/AddContainerDetailsView.swift`
- `Views/AddContainer/AddContainerReviewView.swift`
- `Views/AddContainer/TagWritingView.swift`
- `Views/AddContainer/TagWriteResultView.swift`
- `Views/Settings/SettingsView.swift`
- `Views/Settings/FoodPresetEditorView.swift`

**Components**
- `Views/Components/FoodPresetButton.swift`
- `Views/Components/LabeledDateRow.swift`
- `Views/Components/CharacterCountTextEditor.swift`
- `Views/Components/ContainerSummaryCard.swift`
- `Views/Components/SpokenReplayButton.swift`
- `Views/Components/InlineValidationMessage.swift`

**ViewModels**
- `ViewModels/AddContainerFlowViewModel.swift`
- `ViewModels/SettingsViewModel.swift`

**Models**
- `Models/AddContainerDraft.swift`
- `Models/AddContainerStep.swift`
- `Models/FoodCategory.swift`
- `Models/FoodPreset.swift`
- `Models/AccessibilityPreferences.swift`
- `Models/TagWriteResult.swift`

**Services**
- `Utilities/BestQualityDateCalculator.swift`
- `Utilities/AccessibilityAnnouncementService.swift`
- `Utilities/SpokenFeedbackService.swift`
- `Utilities/HapticsService.swift`
- `Utilities/AppSettingsStore.swift`

This structure keeps the feature cohesive without forcing a full app-wide architecture rewrite.

## 3. Data Model Changes

### 3.1 Extend `ContainerRecord`

Add fields to support the new UX:

- `foodCategory: FoodCategory?`
- optional `bestQualitySource: String?` if you want traceability for USDA-derived dates

Recommended enum:

```swift
enum FoodCategory: String, Codable, CaseIterable {
    case beef
    case poultry
    case fish
    case preparedMeal
    case pastries
    case vegetables
    case other
}
```

Why this matters:

- The review screen should show the category.
- Future inventory and analytics features may need it.
- Success confirmation is clearer when category-driven defaults are stored, not inferred.

### 3.2 Persistence migration

The Core Data entity currently mirrors only the original fields. Update:

- [ContainerEntity+CoreDataProperties.swift](/Users/steveshearman/xcode_projects/freezer_tag_poc/FreezerTagTracker/Persistence/ContainerEntity+CoreDataProperties.swift)
- the underlying `.xcdatamodeld` model
- [DataStore.swift](/Users/steveshearman/xcode_projects/freezer_tag_poc/FreezerTagTracker/Persistence/DataStore.swift)

Add:

- `foodCategory: String?`
- optional `bestQualitySource: String?`

Implementation note:

- This is a lightweight migration candidate because the new fields can be optional.
- `DataStore.convertToRecord` and `save/update` paths should map these fields both ways.

### 3.3 App settings persistence

Do not store app preferences in Core Data. Use a lightweight settings store backed by `UserDefaults` or `AppStorage`.

Store:

- `spokenGuidanceEnabled`
- `spokenConfirmationsEnabled`
- `hapticsEnabled`
- `showMicrophoneShortcut`
- preset month values keyed by `FoodCategory`

## 4. View Model Plan

## 4.1 `AddContainerFlowViewModel`

This should become the single source of truth for the multi-step add flow.

Core responsibilities:

- manage the draft being edited
- validate required fields
- derive `best quality by` from the selected preset
- track current step
- trigger navigation between details, review, writing, success, and failure
- start the NFC write
- coordinate spoken guidance and haptics
- provide success summary content for replay

Suggested published state:

```swift
@Published var draft: AddContainerDraft
@Published var step: AddContainerStep
@Published var validationMessage: String?
@Published var isWriting: Bool
@Published var writeResult: TagWriteResult?
@Published var isListeningForFoodName: Bool
```

Suggested methods:

- `selectPreset(_ category: FoodCategory)`
- `updateFoodName(_ text: String)`
- `updateDateFrozen(_ date: Date)`
- `updateBestQualityDate(_ date: Date?)`
- `updateNotes(_ text: String)`
- `goToReview()`
- `goBackToEdit()`
- `writeToTag()`
- `retryWrite()`
- `readDetailsAgain()`
- `cancelFlow()`

### 4.2 `SettingsViewModel`

Responsibilities:

- load and save app-owned accessibility preferences
- expose preset values for editing
- reset presets to defaults

## 5. View Plan

## 5.1 Replace `AddContainerView`

Current file:

- [AddContainerView.swift](/Users/steveshearman/xcode_projects/freezer_tag_poc/FreezerTagTracker/Views/AddContainerView.swift)

Recommended change:

- convert this into a small wrapper that hosts the new flow, or replace it with `AddContainerFlowView`

The wrapper approach is lower risk because `HomeView` can keep its navigation target while the internals evolve.

## 5.2 `AddContainerFlowView`

Purpose:

- root container for the whole add flow
- owns `@StateObject var viewModel: AddContainerFlowViewModel`
- switches between details, review, writing, and result screens

Implementation style:

- use a `NavigationStack` or conditional screen rendering inside one feature root
- keep transitions simple and Reduce Motion aware

## 5.3 `AddContainerDetailsView`

Purpose:

- step 1 editing screen

Responsibilities:

- render the food name input
- render preset selection
- show date rows
- show notes field and counter
- host the primary CTA

Technical notes:

- avoid `Form` if it becomes too rigid for the desired large-target layout
- prefer `ScrollView` + `VStack` + reusable components for more control over spacing, focus, and accessibility grouping

## 5.4 `AddContainerReviewView`

Purpose:

- step 2 review screen

Responsibilities:

- display a summary card
- offer `Write to tag`
- offer `Go back and change`

## 5.5 `TagWritingView`

Purpose:

- quiet companion screen shown around the NFC sheet lifecycle

Responsibilities:

- show `Hold your phone near the tag`
- show a calm progress state
- optionally show cancel if implementation supports it

Technical note:

- continue respecting the current `NFCManager` sheet behavior rather than fighting it

## 5.6 `TagWriteResultView`

Purpose:

- render either success or failure

States:

- success with summary and `Read details again`
- failure with `Try again`, `Go back`, and support text

This should be a single reusable screen configured by `TagWriteResult`.

## 5.7 Settings views

Add:

- `SettingsView`
- `FoodPresetEditorView`

These can start simple and be accessible from `HomeView` via a toolbar button.

## 6. Service Plan

## 6.1 `BestQualityDateCalculator`

Responsibilities:

- map `FoodCategory` to default month offsets
- calculate a suggested date from `dateFrozen`
- read user-edited preset overrides from settings

Suggested API:

```swift
func suggestedDate(for category: FoodCategory, frozenOn: Date) -> Date?
func presetDescription(for category: FoodCategory) -> String
```

## 6.2 `AppSettingsStore`

Responsibilities:

- persist feature toggles and preset values
- offer defaults for first launch

Keep this small and synchronous.

## 6.3 `SpokenFeedbackService`

Responsibilities:

- speak short guidance when VoiceOver is not active
- stop or avoid speech overlap
- replay full saved details

Likely implementation:

- `AVSpeechSynthesizer`

Rules:

- if VoiceOver is running, prefer announcements rather than simultaneous speech
- if spoken guidance is disabled, no custom speech

## 6.4 `AccessibilityAnnouncementService`

Responsibilities:

- centralize VoiceOver announcements with `UIAccessibility.post`
- keep announcement timing out of the views

Events to cover:

- screen arrival
- validation errors
- write success
- write failure

## 6.5 `HapticsService`

Responsibilities:

- map app events to haptic patterns
- respect in-app `Haptics` toggle

Likely implementation:

- `UINotificationFeedbackGenerator`
- `UIImpactFeedbackGenerator`
- keep Core Haptics optional unless custom patterns become necessary later

## 7. NFC Integration Plan

Current NFC writing already lives in:

- [NFCManager.swift](/Users/steveshearman/xcode_projects/freezer_tag_poc/FreezerTagTracker/Models/NFCManager.swift)

Recommended approach:

- keep `NFCManager` as the low-level Core NFC wrapper
- move orchestration into `AddContainerFlowViewModel`

### 7.1 Do not overload `ContainerViewModel`

Right now `saveContainerWithNFC` creates a record and immediately writes it. For the new flow, that method is too coarse.

Refactor options:

1. Move write orchestration out of `ContainerViewModel` and into `AddContainerFlowViewModel`, using:
   - `NFCManager.writeTag(record:)`
   - `DataStore.save(record:)`
2. Or split `ContainerViewModel.saveContainerWithNFC` into smaller methods that the add-flow model can call.

Recommended path:

- Keep `ContainerViewModel` focused on list/detail use cases.
- Let `AddContainerFlowViewModel` construct the `ContainerRecord`, call `NFCManager`, then persist through `DataStore` on success.

That gives the add flow more control over review, retries, speech, and success messaging.

### 7.2 NFC events to expose

If needed, add lightweight callbacks or published state in `NFCManager` for:

- write started
- tag detected
- write completed
- write failed

This will make haptic and spoken timing cleaner than inferring everything from one completion callback.

## 8. Accessibility Task Breakdown

## 8.1 VoiceOver

Tasks:

- add explicit labels, values, hints, and traits to custom controls
- group form sections with accessibility elements where helpful
- define predictable focus order for each screen
- announce validation failures immediately
- announce screen transitions and result states

Files most affected:

- all new add-flow views
- reusable components

## 8.2 Dynamic Type

Tasks:

- design layouts that can stack vertically at Accessibility XXL
- move the mic button below the field in large sizes
- allow preset buttons to wrap or become full-width
- test summary cards with multiline values

Implementation note:

- prefer flexible stacks over fixed-width form rows

## 8.3 Spoken feedback

Tasks:

- default on
- short messages by default
- replay full details on demand
- avoid speaking over VoiceOver

## 8.4 Haptics

Tasks:

- add event mapping for preset tap, write start, tag detected, success, failure
- ensure haptics remain optional in Settings

## 8.5 Reduce Motion and color independence

Tasks:

- keep animations subtle
- provide static equivalents for pulse/loading effects
- pair every status color with text and icon changes

## 9. Home Screen and Navigation Changes

Update [HomeView.swift](/Users/steveshearman/xcode_projects/freezer_tag_poc/FreezerTagTracker/Views/HomeView.swift):

- replace the destination from `AddContainerView` to the new add-flow wrapper
- add a Settings entry point, likely a toolbar button

Optional enhancement during the same pass:

- add a `last saved container` summary on the home screen later, but this is not required for the first add-flow implementation

## 10. Delivery Phases

## Phase 1 - Foundation

- add new models: `FoodCategory`, `FoodPreset`, `AddContainerDraft`, `TagWriteResult`
- add settings store
- extend `ContainerRecord`
- update Core Data model and `DataStore`

Exit criteria:

- app compiles
- records can still save and fetch
- tests updated for new optional fields

## Phase 2 - New details and review screens

- implement `AddContainerFlowView`
- implement `AddContainerDetailsView`
- implement `AddContainerReviewView`
- wire validation and preset date calculation

Exit criteria:

- user can move between step 1 and step 2
- presets auto-fill dates
- VoiceOver labels exist on primary controls

## Phase 3 - Writing and results

- implement `TagWritingView`
- implement `TagWriteResultView`
- move write orchestration into add-flow view model
- persist record only after successful tag write

Exit criteria:

- happy path works end to end
- failure path offers retry and back navigation

## Phase 4 - Accessibility support services

- add spoken guidance service
- add VoiceOver announcements
- add haptics service
- add `Read details again`

Exit criteria:

- spoken guidance defaults on
- result replay works
- haptics respect settings

## Phase 5 - Settings

- implement `SettingsView`
- implement preset editor
- wire toggles and preset persistence

Exit criteria:

- users can change toggles
- users can edit preset month values and reset them

## Phase 6 - Polish and verification

- Dynamic Type pass
- Reduce Motion pass
- copy cleanup
- UI tests and regression checks

## 11. Testing Plan

## 11.1 Unit tests

Add or update tests in:

- [ContainerRecordTests.swift](/Users/steveshearman/xcode_projects/freezer_tag_poc/FreezerTagTrackerTests/ContainerRecordTests.swift)
- [DataStoreTests.swift](/Users/steveshearman/xcode_projects/freezer_tag_poc/FreezerTagTrackerTests/DataStoreTests.swift)
- [ContainerViewModelTests.swift](/Users/steveshearman/xcode_projects/freezer_tag_poc/FreezerTagTrackerTests/ContainerViewModelTests.swift)

New test targets to add:

- `BestQualityDateCalculatorTests`
- `AddContainerFlowViewModelTests`
- `AppSettingsStoreTests`

Test cases:

- preset selection sets expected suggested date
- manual date edit does not break the draft
- validation blocks empty food name
- write success persists the record
- write failure does not persist the record
- replay text matches the saved summary
- settings overrides change preset calculations

## 11.2 UI tests

Suggested UI flows:

- add a container with typed text
- add a container with a preset
- reach review screen and go back
- successful write path with mocked NFC manager
- failed write then retry
- settings toggle changes behavior

## 11.3 Manual accessibility verification

Manual passes should include:

- VoiceOver on
- Larger Text at Accessibility XXL
- Reduce Motion on
- Increase Contrast on
- Spoken guidance off
- Haptics off

## 12. Suggested First PR Scope

To keep risk manageable, the first implementation PR should include:

- new models and settings store
- `AddContainerFlowViewModel`
- `AddContainerDetailsView`
- `AddContainerReviewView`
- preset date logic
- basic navigation from `HomeView`

Hold these for a second PR if needed:

- full spoken guidance service
- full haptics mapping
- Settings editor screens
- custom NFC event publishing beyond what is required for the happy path

That split keeps the first delivery focused on the structural UX win: the 2-step add flow with presets and review.

## 13. Definition of Done

This feature is ready when:

- the add flow is two-step and matches the wireframes
- users can choose presets and get suggested best-quality dates
- the app writes only after the review step
- success and failure states are explicit and recoverable
- spoken guidance and haptics can be controlled in Settings
- the flow works at large Dynamic Type sizes
- VoiceOver can complete the flow without hidden controls or dead ends
