# GitHub Issue Drafts: Add Container Accessibility-First Flow

**Source task list:** [tasks-add-container-accessibility-flow.md](/Users/steveshearman/xcode_projects/freezer_tag_poc/tasks/tasks-add-container-accessibility-flow.md)  
**Related docs:**
- [add-container-ux-spec.md](/Users/steveshearman/xcode_projects/freezer_tag_poc/docs/add-container-ux-spec.md)
- [add-container-wireframes.md](/Users/steveshearman/xcode_projects/freezer_tag_poc/docs/add-container-wireframes.md)
- [add-container-swiftui-implementation-plan.md](/Users/steveshearman/xcode_projects/freezer_tag_poc/docs/add-container-swiftui-implementation-plan.md)

This document converts the add-container backlog into GitHub-ready issue text. The issues are grouped into practical delivery slices rather than one issue per tiny ticket, but each issue preserves the underlying checklist from the task list.

---

## Issue 0

### Title

Epic: Accessibility-first add container flow with USDA presets and NFC confirmation

### Suggested labels

- `epic`
- `ios`
- `swiftui`
- `accessibility`
- `nfc`

### Body

## Summary

Replace the current one-step add form with a two-step, accessibility-first add flow that supports:

- USDA-based food presets
- review before writing to tag
- spoken guidance and spoken confirmations
- haptics for key interactions
- replayable success details
- editable app-owned settings for accessibility support and preset overrides

This epic is the umbrella for the add-container redesign described in:

- [add-container-ux-spec.md](/Users/steveshearman/xcode_projects/freezer_tag_poc/docs/add-container-ux-spec.md)
- [add-container-wireframes.md](/Users/steveshearman/xcode_projects/freezer_tag_poc/docs/add-container-wireframes.md)
- [add-container-swiftui-implementation-plan.md](/Users/steveshearman/xcode_projects/freezer_tag_poc/docs/add-container-swiftui-implementation-plan.md)

## Goals

- Make the add flow easier for blind and low-vision users
- Reduce typing with USDA preset shortcuts
- Add a review step before NFC writing
- Give clear visual, spoken, and haptic confirmation after a successful write
- Add lightweight in-app settings for app-owned accessibility support

## Success criteria

- The add flow is two-step instead of one-step
- USDA presets auto-fill editable best-quality dates
- Records persist category data
- Writes only happen after the review step
- Success and failure states are explicit and recoverable
- VoiceOver and large Dynamic Type can complete the full flow
- Spoken guidance and haptics can be controlled in Settings

## Child issues

- [ ] Foundation: add category, presets, settings store, and draft models
- [ ] Build the new step-1 and step-2 add flow UI
- [ ] Integrate NFC write state, success/failure results, and retry
- [ ] Add spoken guidance, spoken replay, haptics, and settings UI
- [ ] Hardening: VoiceOver polish, large text, Reduce Motion, and tests

---

## Issue 1

### Title

Foundation: add food category, preset date logic, draft state, and settings store

### Suggested labels

- `feature`
- `ios`
- `swiftui`
- `data-model`

### Body

## Summary

Lay the data and state-management foundation for the new add-container flow. This includes storing food category on container records, introducing USDA preset models and best-quality date calculation, and adding a lightweight app settings store for accessibility toggles and preset overrides.

## Why

The current add flow has no concept of category, preset logic, or app-owned accessibility settings. We need that foundation before the new UI can be built cleanly.

## Scope

- Add `FoodCategory`
- Extend `ContainerRecord` with category data
- Update Core Data persistence for category
- Add `AccessibilityPreferences`
- Add `FoodPreset`
- Add `AppSettingsStore`
- Add `BestQualityDateCalculator`
- Add `AddContainerDraft`
- Add `AddContainerStep` and `TagWriteResult`
- Add `AddContainerFlowViewModel` state and step navigation without NFC integration yet

## Checklist

- [ ] Create `FoodCategory` enum with display names
- [ ] Extend `ContainerRecord` with `foodCategory`
- [ ] Update Core Data model and persistence mapping for category
- [ ] Add app settings model for:
  - [ ] spoken guidance
  - [ ] spoken confirmations
  - [ ] haptics
  - [ ] microphone shortcut visibility
- [ ] Create preset model keyed by category
- [ ] Create lightweight settings store backed by `UserDefaults` or equivalent
- [ ] Create USDA best-quality date calculator
- [ ] Add preset copy helpers for UI
- [ ] Create `AddContainerDraft`
- [ ] Create `AddContainerStep`
- [ ] Create `TagWriteResult`
- [ ] Create `AddContainerFlowViewModel` with:
  - [ ] draft state
  - [ ] preset selection
  - [ ] field editing
  - [ ] validation
  - [ ] details/review step navigation

## Acceptance criteria

- New and existing records can still save and load
- Category is persisted correctly
- Preset date calculator returns expected defaults
- Settings persist across relaunch
- Add flow view model can move between details and review without NFC yet

## Out of scope

- New add-flow UI screens
- Spoken feedback
- NFC write orchestration
- Settings UI screens

---

## Issue 2

### Title

Build the new two-step add container UI with presets and review

### Suggested labels

- `feature`
- `ios`
- `swiftui`
- `ui`
- `accessibility`

### Body

## Summary

Replace the current one-step `AddContainerView` form with a new two-step add flow:

1. `Add details`
2. `Review and write`

The UI should follow the low-fidelity wireframes and use reusable components for presets, date rows, notes, and summary cards.

## Why

The current `Form` is too flat and too immediate for the target users. We need a calmer, clearer flow with reduced typing, a review step, and better control over layout/accessibility.

## Scope

- Build the new reusable UI components
- Build the step-1 details screen
- Build the step-2 review screen
- Build the flow container view
- Replace the existing add-screen entry point

## Checklist

- [ ] Build `FoodPresetButton`
- [ ] Build `LabeledDateRow`
- [ ] Build `CharacterCountTextEditor`
- [ ] Build `ContainerSummaryCard`
- [ ] Build `AddContainerDetailsView`
- [ ] Build `AddContainerReviewView`
- [ ] Build `AddContainerFlowView`
- [ ] Replace or wrap the current `AddContainerView`
- [ ] Update `HomeView` so `Add Container` opens the new flow
- [ ] Add large-text layout behavior for:
  - [ ] stacked preset buttons
  - [ ] mic button fallback below the field
  - [ ] readable summary card content

## Acceptance criteria

- User can enter details and move to review
- Preset selection auto-fills a suggested best-quality date
- Food name validation blocks forward progress when empty
- User can return from review to edit details
- Step 1 and step 2 copy match the approved UX spec
- Layout remains usable at Accessibility XXL

## Out of scope

- Actual NFC write behavior
- Spoken guidance and haptics
- Success/failure result screens

---

## Issue 3

### Title

Integrate NFC writing into the new add flow with writing, success, failure, and retry states

### Suggested labels

- `feature`
- `ios`
- `nfc`
- `swiftui`

### Body

## Summary

Connect the new two-step add flow to NFC writing. The add flow should move into a dedicated writing state, then show an explicit success or failure result screen, with retry support on failure.

## Why

The current add flow immediately starts NFC writing from the form button and dismisses on success. The new UX needs review-before-write, explicit result states, and safer retry behavior.

## Scope

- Move write orchestration into the add-flow view model
- Build the writing companion screen
- Build the success/failure result screen
- Add retry behavior
- Persist records only after successful tag write

## Checklist

- [ ] Update `AddContainerFlowViewModel` to create `ContainerRecord` from the draft
- [ ] Start tag writing from the add-flow model
- [ ] Persist to Core Data only after successful tag write
- [ ] Build `TagWritingView`
- [ ] Build `TagWriteResultView`
- [ ] Render explicit success state
- [ ] Render explicit failure state
- [ ] Add `Try again`
- [ ] Add `Go back`
- [ ] Preserve the draft across a failed write

## Acceptance criteria

- User can review details, then start tag writing
- Successful writes save the record and show a success screen
- Failed writes do not save the record
- Failure state offers retry without re-entering data
- The writing state works with the existing Apple NFC system sheet behavior

## Out of scope

- Spoken guidance
- Haptics
- Settings UI

---

## Issue 4

### Title

Add spoken guidance, replayable confirmations, haptics, and settings UI for the add flow

### Suggested labels

- `feature`
- `ios`
- `accessibility`
- `settings`
- `audio`

### Body

## Summary

Add the app-owned accessibility support for the add flow: spoken guidance, spoken confirmations, replayable success details, haptics, and a Settings UI where users can control these features and edit preset defaults.

## Why

This is a core part of the product value for blind users, users with memory challenges, and users who prefer a more guided experience. These behaviors also need to be optional and easy to manage.

## Scope

- Spoken feedback service
- VoiceOver announcement service
- Haptics service
- Spoken replay button on success
- Settings screen
- Food preset editor

## Checklist

- [ ] Create `SpokenFeedbackService`
- [ ] Create `AccessibilityAnnouncementService`
- [ ] Create `HapticsService`
- [ ] Add spoken guidance for:
  - [ ] add-screen arrival
  - [ ] preset selection
  - [ ] review-screen arrival
  - [ ] write start
  - [ ] validation errors
- [ ] Add short spoken success confirmation
- [ ] Add `Read details again` replay behavior
- [ ] Add haptic mapping for:
  - [ ] preset tap
  - [ ] primary actions
  - [ ] write start
  - [ ] success
  - [ ] failure
- [ ] Create `SettingsViewModel`
- [ ] Build `SettingsView`
- [ ] Add Settings entry point from `HomeView`
- [ ] Build `FoodPresetEditorView`
- [ ] Persist edited preset month values

## Acceptance criteria

- Spoken guidance is on by default
- VoiceOver users do not hear overlapping duplicate custom speech
- Haptics can be turned off in Settings
- `Read details again` replays the full saved summary
- Users can edit preset month values and reset them to defaults
- Settings changes persist across relaunch

## Out of scope

- Accessibility hardening pass across every edge case
- UI tests and full regression verification

---

## Issue 5

### Title

Accessibility hardening and test coverage for the new add container flow

### Suggested labels

- `accessibility`
- `testing`
- `ios`
- `quality`

### Body

## Summary

Complete the add-flow feature with accessibility hardening and test coverage. This issue focuses on VoiceOver polish, Dynamic Type behavior, Reduce Motion support, unit coverage, UI smoke tests, and manual accessibility verification.

## Why

The add flow is explicitly accessibility-first. It should not ship with accessibility treated as a best-effort follow-up.

## Scope

- VoiceOver labels, hints, values, and grouping
- Focus order cleanup
- Reduce Motion support
- Color-independent status communication
- Unit tests
- UI smoke tests
- Manual accessibility verification

## Checklist

- [ ] Add explicit VoiceOver labels and hints across the new add flow
- [ ] Add accessibility grouping where needed
- [ ] Verify predictable top-to-bottom focus order
- [ ] Add Reduce Motion behavior for the writing state
- [ ] Ensure status is never color-only
- [ ] Add unit tests for `BestQualityDateCalculator`
- [ ] Add unit tests for `AddContainerFlowViewModel`
- [ ] Add UI smoke tests for:
  - [ ] details to review
  - [ ] back navigation
  - [ ] successful write
  - [ ] failed write
  - [ ] settings changes
- [ ] Run manual verification with:
  - [ ] VoiceOver
  - [ ] Dynamic Type Accessibility XXL
  - [ ] Reduce Motion
  - [ ] spoken guidance off
  - [ ] haptics off

## Acceptance criteria

- VoiceOver can complete the full flow without dead ends or ambiguous controls
- Step 1 and step 2 remain usable at Accessibility XXL
- The flow remains understandable with motion reduced
- Core add-flow behavior is covered by unit tests
- The main happy path and failure path are covered by UI smoke tests
- Manual accessibility issues are documented and triaged

## Out of scope

- Broader app-wide accessibility work outside the add flow

