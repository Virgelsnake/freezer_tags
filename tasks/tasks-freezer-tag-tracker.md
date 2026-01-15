# Task List: Freezer Tag Tracker iOS App

**Source PRD:** `prd-freezer-tag-tracker.md`  
**Project Type:** New iOS app (Swift + SwiftUI)  
**Estimated Total Time:** 12-15 hours (prototype)  
**Generated:** January 15, 2026

---

## Task Overview

This task list breaks down the Freezer Tag Tracker prototype into granular, actionable tasks following a test-first approach. Each atomic task is designed to take 15-30 minutes and produces a specific, verifiable outcome.

**Key Principles:**
- Test-first development: Write tests before implementation
- Atomic tasks: Small, independently completable units
- Manual NFC testing: Physical device required (no simulator support)
- Incremental validation: Run tests after each implementation phase

---

## Phase 0: Project Setup & Infrastructure

### Task 0.1: Create Xcode Project and Configure NFC Capabilities

**Atomic Tasks:**

**0.1.1 (Setup): Create new Xcode iOS project**
- Create new iOS App project in Xcode
- Name: "FreezerTagTracker"
- Interface: SwiftUI
- Language: Swift
- Minimum deployment target: iOS 15.0
- **Acceptance:** Project builds successfully in simulator
- **Time:** 5 minutes

**0.1.2 (Setup): Configure NFC capabilities and permissions**
- Enable "Near Field Communication Tag Reading" capability in project settings
- Add `NFCReaderUsageDescription` to Info.plist with message: "This app needs NFC access to read and write container information to NFC tags"
- Add NFC tag types to Info.plist under `com.apple.developer.nfc.readersession.formats`: `["NDEF"]`
- **Acceptance:** Capability shows as enabled in Signing & Capabilities tab
- **Time:** 10 minutes

**0.1.3 (Setup): Create project folder structure**
- Create folder structure matching PRD recommendation:
  - `Models/` (data models and NFC manager)
  - `Views/` (SwiftUI views)
  - `ViewModels/` (view models for business logic)
  - `Persistence/` (data storage layer)
  - `Tests/` (unit tests)
- **Acceptance:** All folders visible in Xcode project navigator
- **Time:** 5 minutes

**0.1.4 (Setup): Configure test target**
- Verify test target exists (FreezerTagTrackerTests)
- Add test plan if needed
- Configure test target to include all source files
- **Acceptance:** Test target builds successfully
- **Time:** 5 minutes

**Dependencies:** None  
**Total Phase Time:** ~25 minutes

---

## Phase 1: Data Layer (Models & Persistence)

### Task 1.1: Implement Container Record Data Model

**Atomic Tasks:**

**1.1.1 (Tests): Write unit tests for ContainerRecord model**
- Create `ContainerRecordTests.swift` in Tests folder
- Write tests for:
  - Model initialization with valid data
  - Required field validation (food name, date frozen)
  - Optional notes field (max 200 characters)
  - Date formatting and display
  - Unique ID generation
- **Acceptance:** Tests compile (will fail until implementation)
- **Time:** 20 minutes

**1.1.2 (Implement): Create ContainerRecord model**
- Create `ContainerRecord.swift` in Models folder
- Implement struct/class with properties:
  - `id: UUID` (unique identifier)
  - `tagID: String` (NFC tag unique ID)
  - `foodName: String` (required)
  - `dateFrozen: Date` (required)
  - `notes: String?` (optional, max 200 chars)
  - `isCleared: Bool` (default false)
  - `createdAt: Date`
  - `updatedAt: Date`
- Make Codable, Identifiable, Hashable
- Add computed property for formatted date display
- **Acceptance:** Model compiles without errors
- **Time:** 20 minutes

**1.1.3 (Validate): Run ContainerRecord tests and fix failures**
- Run unit tests from 1.1.1
- Fix any test failures
- Verify all validation logic works correctly
- **Acceptance:** All ContainerRecord tests pass (100% pass rate)
- **Time:** 15 minutes

**Dependencies:** 0.1.4 complete  
**Total Task Time:** ~55 minutes

---

### Task 1.2: Implement Local Data Persistence Layer

**Atomic Tasks:**

**1.2.1 (Decision): Choose persistence approach (SwiftData vs Core Data)**
- Evaluate options:
  - **SwiftData:** Modern, simpler API, requires iOS 17+
  - **Core Data:** Mature, supports iOS 13+, more boilerplate
- **Decision:** Use Core Data for iOS 15+ compatibility (broader device support for prototype testing)
- Document decision in `/docs/adr-001-persistence.md` (create docs folder if needed)
- **Acceptance:** Decision documented with rationale
- **Time:** 15 minutes

**1.2.2 (Tests): Write unit tests for DataStore operations**
- Create `DataStoreTests.swift` in Tests folder
- Write tests for:
  - Save new container record
  - Fetch container by tag ID
  - Fetch all containers
  - Update existing container
  - Delete/clear container
  - Handle duplicate tag IDs
  - Handle non-existent records
- Use in-memory Core Data store for testing
- **Acceptance:** Tests compile (will fail until implementation)
- **Time:** 25 minutes

**1.2.3 (Implement): Create Core Data model and DataStore wrapper**
- Create `FreezerTagTracker.xcdatamodeld` file
- Define `ContainerEntity` with attributes matching ContainerRecord
- Create `DataStore.swift` in Persistence folder
- Implement singleton pattern with in-memory and persistent store options
- Implement CRUD methods:
  - `save(record: ContainerRecord) throws`
  - `fetch(byTagID: String) -> ContainerRecord?`
  - `fetchAll() -> [ContainerRecord]`
  - `update(record: ContainerRecord) throws`
  - `delete(record: ContainerRecord) throws`
  - `clearContainer(tagID: String) throws`
- Add error handling with custom error types
- **Acceptance:** DataStore compiles, Core Data model validates
- **Time:** 30 minutes

**1.2.4 (Validate): Run DataStore tests and fix failures**
- Run unit tests from 1.2.2
- Fix any test failures
- Verify all CRUD operations work correctly
- Test edge cases (duplicates, missing records)
- **Acceptance:** All DataStore tests pass (100% pass rate)
- **Time:** 20 minutes

**Dependencies:** 1.1.3 complete  
**Total Task Time:** ~90 minutes

---

## Phase 2: NFC Layer (Read/Write Operations)

### Task 2.1: Implement NFC Manager for Tag Operations

**Atomic Tasks:**

**2.1.1 (Implement): Create NFCManager class structure**
- Create `NFCManager.swift` in Models folder
- Import Core NFC framework
- Create class conforming to `NFCNDEFReaderSessionDelegate`
- Add properties:
  - `session: NFCNDEFReaderSession?`
  - Completion handlers for read/write operations
  - Error handling callbacks
- Add enum for NFC operation types (read, write)
- Add custom error types for NFC operations
- **Acceptance:** NFCManager compiles, delegate stubs implemented
- **Time:** 20 minutes

**2.1.2 (Implement): Implement NFC read functionality**
- Add method: `readTag(completion: @escaping (Result<ContainerRecord, Error>) -> Void)`
- Start NFC reader session with appropriate alert message
- Implement `readerSession(_:didDetectNDEFs:)` delegate method
- Parse NDEF message to extract container data or tag ID
- Handle multiple tags detected (show error)
- Handle session errors and invalidation
- **Acceptance:** Read method compiles, handles all delegate callbacks
- **Time:** 30 minutes

**2.1.3 (Implement): Implement NFC write functionality**
- Add method: `writeTag(record: ContainerRecord, completion: @escaping (Result<Void, Error>) -> Void)`
- Start NFC reader session with write capability
- Implement `readerSession(_:didDetect:)` delegate method for tag writing
- Create NDEF payload from ContainerRecord (hybrid approach: store tag ID + minimal data)
- Write NDEF message to tag
- Handle write errors (tag removed, read-only tag, capacity issues)
- Handle session completion and invalidation
- **Acceptance:** Write method compiles, handles all error cases
- **Time:** 30 minutes

**2.1.4 (Implement): Add user-friendly error messages**
- Create `NFCError` enum with cases:
  - `tagNotFound`
  - `readFailed`
  - `writeFailed`
  - `tagRemoved`
  - `multipleTagsDetected`
  - `unsupportedTag`
  - `sessionTimeout`
- Add computed property for user-friendly error descriptions
- Update NFCManager to use custom error types
- **Acceptance:** All error cases have clear user messages
- **Time:** 15 minutes

**Dependencies:** 1.1.3 complete  
**Total Task Time:** ~95 minutes

---

### Task 2.2: Manual NFC Testing Preparation

**Atomic Tasks:**

**2.2.1 (Documentation): Create manual NFC test checklist**
- Create `docs/nfc-test-checklist.md`
- Document test scenarios:
  - Write to blank NDEF tag
  - Read from written tag
  - Write to tag already containing data
  - Handle tag removed during read
  - Handle tag removed during write
  - Handle multiple tags in range
  - Handle non-NDEF tag
  - Handle read-only tag
- Add columns for: Test Case, Expected Result, Actual Result, Pass/Fail, Notes
- **Acceptance:** Checklist covers all error scenarios from 2.1.4
- **Time:** 20 minutes

**2.2.2 (Documentation): Document NFC tag procurement and setup**
- Create `docs/nfc-tag-setup.md`
- Document recommended tag types (NTAG213, NTAG215)
- Add procurement links (Amazon, AliExpress)
- Document how to verify tags are NDEF-formatted
- Add notes on tag capacity and data limits
- **Acceptance:** Documentation provides clear procurement guidance
- **Time:** 15 minutes

**Dependencies:** 2.1.4 complete  
**Total Task Time:** ~35 minutes

---

## Phase 3: UI Layer (SwiftUI Views)

### Task 3.1: Implement Home Screen View

**Atomic Tasks:**

**3.1.1 (Implement): Create HomeView with navigation**
- Create `HomeView.swift` in Views folder
- Implement SwiftUI view with NavigationStack
- Add app title/header
- Add two primary action buttons:
  - "Add Container" (NavigationLink to AddContainerView)
  - "Scan Container" (NavigationLink to ScanView)
- Use SF Symbols for icons (plus.circle, viewfinder.circle)
- Apply standard iOS styling
- Support light/dark mode
- **Acceptance:** View compiles and displays in preview
- **Time:** 20 minutes

**3.1.2 (Implement): Update App entry point to use HomeView**
- Open `FreezerTagTrackerApp.swift`
- Set HomeView as root view in WindowGroup
- Test navigation in simulator
- **Acceptance:** App launches and shows HomeView
- **Time:** 5 minutes

**3.1.3 (Validate): Test HomeView in simulator**
- Build and run in simulator
- Verify both buttons are visible and tappable
- Verify navigation structure works (even though destination views don't exist yet)
- Test light/dark mode appearance
- **Acceptance:** HomeView displays correctly, navigation structure valid
- **Time:** 10 minutes

**Dependencies:** 0.1.3 complete  
**Total Task Time:** ~35 minutes

---

### Task 3.2: Implement Add Container Form View

**Atomic Tasks:**

**3.2.1 (Implement): Create AddContainerView form**
- Create `AddContainerView.swift` in Views folder
- Implement Form with sections:
  - TextField for food name (required)
  - DatePicker for date frozen (default to today)
  - TextField for optional notes (character limit: 200)
- Add character counter for notes field
- Add "Save & Scan Tag" button (disabled if food name empty)
- Add Cancel button in navigation bar
- Use @State for form fields
- **Acceptance:** View compiles and displays in preview with mock data
- **Time:** 25 minutes

**3.2.2 (Implement): Add form validation logic**
- Add validation for required food name field
- Add validation for notes character limit (max 200)
- Show validation errors inline
- Disable save button when validation fails
- Add haptic feedback for validation errors
- **Acceptance:** Validation prevents invalid submissions
- **Time:** 15 minutes

**3.2.3 (Validate): Test AddContainerView in simulator**
- Build and run in simulator
- Navigate from HomeView to AddContainerView
- Test form input and validation
- Verify character counter updates
- Test cancel navigation
- **Acceptance:** Form works correctly, validation prevents bad input
- **Time:** 10 minutes

**Dependencies:** 3.1.3 complete  
**Total Task Time:** ~50 minutes

---

### Task 3.3: Implement Scan View for NFC Operations

**Atomic Tasks:**

**3.3.1 (Implement): Create ScanView with scanning state**
- Create `ScanView.swift` in Views folder
- Add @State for scanning status (idle, scanning, success, error)
- Display scanning animation/indicator (use ProgressView)
- Show instructional text: "Hold iPhone near NFC tag"
- Add cancel button
- Handle different states with appropriate UI
- **Acceptance:** View compiles and shows scanning UI in preview
- **Time:** 20 minutes

**3.3.2 (Implement): Add error and success states to ScanView**
- Add success state UI (checkmark icon, success message)
- Add error state UI (error icon, error message, retry button)
- Add animations for state transitions
- Add haptic feedback for success/error
- **Acceptance:** All states display correctly in preview
- **Time:** 20 minutes

**3.3.3 (Validate): Test ScanView states in simulator**
- Build and run in simulator
- Navigate to ScanView
- Manually trigger different states (will need mock data)
- Verify animations and transitions
- **Acceptance:** All UI states render correctly
- **Time:** 10 minutes

**Dependencies:** 3.1.3 complete  
**Total Task Time:** ~50 minutes

---

### Task 3.4: Implement Container Detail View

**Atomic Tasks:**

**3.4.1 (Implement): Create ContainerDetailView**
- Create `ContainerDetailView.swift` in Views folder
- Accept ContainerRecord as parameter
- Display all fields in readable format:
  - Food name (large, prominent)
  - Date frozen (formatted: "Frozen on Jan 15, 2026")
  - Days frozen (computed: "3 days ago")
  - Notes (if present)
- Use List or VStack with proper spacing
- Add SF Symbols icons for visual hierarchy
- **Acceptance:** View compiles and displays mock data in preview
- **Time:** 25 minutes

**3.4.2 (Implement): Add Edit and Clear actions to detail view**
- Add toolbar with two buttons:
  - "Edit" button (NavigationLink to EditContainerView)
  - "Clear & Reuse" button (shows confirmation alert)
- Implement confirmation alert for clear action
- Add appropriate SF Symbols icons
- **Acceptance:** Buttons display and trigger correct actions
- **Time:** 15 minutes

**3.4.3 (Validate): Test ContainerDetailView in simulator**
- Build and run in simulator
- Create mock ContainerRecord for testing
- Verify all fields display correctly
- Test Edit and Clear buttons
- Verify confirmation alert appears
- **Acceptance:** Detail view displays all data correctly
- **Time:** 10 minutes

**Dependencies:** 3.1.3 complete  
**Total Task Time:** ~50 minutes

---

### Task 3.5: Implement Edit Container View

**Atomic Tasks:**

**3.5.1 (Implement): Create EditContainerView**
- Create `EditContainerView.swift` in Views folder
- Accept ContainerRecord as binding parameter
- Implement Form pre-populated with existing data:
  - TextField for food name (editable)
  - DatePicker for date frozen (editable)
  - TextField for notes (editable, 200 char limit)
- Add character counter for notes
- Add Save and Cancel buttons in toolbar
- **Acceptance:** View compiles and displays pre-filled form in preview
- **Time:** 25 minutes

**3.5.2 (Implement): Add edit validation and save logic**
- Add same validation as AddContainerView
- Disable save if validation fails
- Add @Environment(\.dismiss) for navigation
- Handle save action (will connect to ViewModel later)
- Add haptic feedback on save
- **Acceptance:** Validation works, save button state correct
- **Time:** 15 minutes

**3.5.3 (Validate): Test EditContainerView in simulator**
- Build and run in simulator
- Navigate to EditContainerView with mock data
- Test editing all fields
- Verify validation works
- Test save and cancel actions
- **Acceptance:** Edit form works correctly with validation
- **Time:** 10 minutes

**Dependencies:** 3.4.3 complete  
**Total Task Time:** ~50 minutes

---

## Phase 4: Business Logic Layer (ViewModels)

### Task 4.1: Implement Container ViewModel

**Atomic Tasks:**

**4.1.1 (Tests): Write unit tests for ContainerViewModel**
- Create `ContainerViewModelTests.swift` in Tests folder
- Write tests for:
  - Save new container (with NFC write)
  - Scan and read container (with NFC read)
  - Update existing container
  - Clear container
  - Handle NFC errors
  - Handle data persistence errors
- Use mock DataStore and mock NFCManager
- **Acceptance:** Tests compile (will fail until implementation)
- **Time:** 30 minutes

**4.1.2 (Implement): Create ContainerViewModel class**
- Create `ContainerViewModel.swift` in ViewModels folder
- Make ObservableObject conforming class
- Add @Published properties:
  - `containers: [ContainerRecord]`
  - `isLoading: Bool`
  - `errorMessage: String?`
  - `currentContainer: ContainerRecord?`
- Inject DataStore and NFCManager dependencies
- Add init with dependency injection support
- **Acceptance:** ViewModel compiles, properties defined
- **Time:** 20 minutes

**4.1.3 (Implement): Implement save container workflow**
- Add method: `saveContainer(foodName: String, dateFrozen: Date, notes: String?)`
- Create ContainerRecord from input
- Call NFCManager to write tag
- On success, save to DataStore
- Update @Published properties
- Handle errors and update errorMessage
- Add proper async/await handling
- **Acceptance:** Method compiles, handles success and error paths
- **Time:** 25 minutes

**4.1.4 (Implement): Implement scan container workflow**
- Add method: `scanContainer()`
- Call NFCManager to read tag
- Fetch full record from DataStore using tag ID
- Update currentContainer property
- Handle errors (tag not found, read failed)
- Add proper async/await handling
- **Acceptance:** Method compiles, handles all scenarios
- **Time:** 25 minutes

**4.1.5 (Implement): Implement update and clear workflows**
- Add method: `updateContainer(record: ContainerRecord)`
- Update DataStore
- Optionally rewrite to NFC tag
- Add method: `clearContainer(tagID: String)`
- Mark container as cleared in DataStore
- Optionally clear NFC tag
- Handle errors for both operations
- **Acceptance:** Both methods compile and handle errors
- **Time:** 20 minutes

**4.1.6 (Validate): Run ContainerViewModel tests and fix failures**
- Run unit tests from 4.1.1
- Fix any test failures
- Verify all workflows work with mocked dependencies
- **Acceptance:** All ViewModel tests pass (100% pass rate)
- **Time:** 25 minutes

**Dependencies:** 1.2.4, 2.1.4 complete  
**Total Task Time:** ~145 minutes

---

## Phase 5: Integration (Connect UI to Business Logic)

### Task 5.1: Integrate ViewModel with Views

**Atomic Tasks:**

**5.1.1 (Implement): Connect HomeView to ViewModel**
- Add @StateObject for ContainerViewModel in HomeView
- Pass ViewModel to child views via environment or parameter
- Update navigation to pass ViewModel
- **Acceptance:** ViewModel accessible from HomeView and children
- **Time:** 15 minutes

**5.1.2 (Implement): Connect AddContainerView to ViewModel**
- Add @ObservedObject or @EnvironmentObject for ViewModel
- Connect "Save & Scan Tag" button to `saveContainer()` method
- Show loading state during NFC write
- Handle success (navigate to detail view)
- Handle errors (show alert with error message)
- Add proper async/await handling with Task
- **Acceptance:** Add flow triggers NFC write and saves data
- **Time:** 25 minutes

**5.1.3 (Implement): Connect ScanView to ViewModel**
- Add @ObservedObject or @EnvironmentObject for ViewModel
- Call `scanContainer()` on view appear
- Update UI based on ViewModel state (loading, success, error)
- Navigate to ContainerDetailView on success
- Show error message and retry button on failure
- **Acceptance:** Scan flow triggers NFC read and displays result
- **Time:** 25 minutes

**5.1.4 (Implement): Connect ContainerDetailView to ViewModel**
- Add @ObservedObject or @EnvironmentObject for ViewModel
- Connect "Clear & Reuse" button to `clearContainer()` method
- Show confirmation alert before clearing
- Handle success (navigate back or show success message)
- Handle errors (show alert)
- **Acceptance:** Clear action works and updates data
- **Time:** 20 minutes

**5.1.5 (Implement): Connect EditContainerView to ViewModel**
- Add @ObservedObject or @EnvironmentObject for ViewModel
- Connect Save button to `updateContainer()` method
- Show loading state during update
- Handle success (dismiss view)
- Handle errors (show alert)
- **Acceptance:** Edit flow updates container and optionally rewrites tag
- **Time:** 20 minutes

**Dependencies:** 4.1.6, 3.5.3 complete  
**Total Task Time:** ~105 minutes

---

### Task 5.2: Integration Testing in Simulator

**Atomic Tasks:**

**5.2.1 (Validate): Test complete UI flow in simulator (without NFC)**
- Build and run app in simulator
- Test navigation between all views
- Test form validation in Add and Edit views
- Verify error states display correctly
- Test with mock data (NFC will fail in simulator, which is expected)
- **Acceptance:** All UI flows work, NFC errors handled gracefully
- **Time:** 20 minutes

**5.2.2 (Validate): Test data persistence in simulator**
- Create mock containers using in-memory DataStore
- Verify data persists between view navigations
- Test update and delete operations
- Verify UI updates when data changes
- **Acceptance:** Data layer works correctly with UI
- **Time:** 15 minutes

**Dependencies:** 5.1.5 complete  
**Total Task Time:** ~35 minutes

---

## Phase 6: Physical Device Testing (NFC Operations)

### Task 6.1: Physical Device Setup and Initial NFC Testing

**Atomic Tasks:**

**6.1.1 (Setup): Deploy app to physical iPhone**
- Connect iPhone to Mac
- Select physical device as build target
- Configure signing & provisioning profile
- Build and deploy to device
- Verify app launches on physical device
- **Acceptance:** App runs on physical iPhone without crashes
- **Time:** 15 minutes

**6.1.2 (Manual Test): Test NFC write operation with blank tag**
- Open app on physical device
- Navigate to Add Container
- Fill in form with test data (e.g., "Chicken Soup", today's date)
- Tap "Save & Scan Tag"
- Hold iPhone near blank NDEF tag
- Verify success message appears
- **Acceptance:** Data successfully written to NFC tag
- **Time:** 10 minutes
- **Record results in:** `docs/nfc-test-checklist.md`

**6.1.3 (Manual Test): Test NFC read operation**
- Open app on physical device
- Navigate to Scan Container
- Hold iPhone near previously written tag
- Verify container details display correctly
- Verify all fields match written data
- **Acceptance:** Data successfully read from NFC tag and displayed
- **Time:** 10 minutes
- **Record results in:** `docs/nfc-test-checklist.md`

**6.1.4 (Manual Test): Test edit and rewrite operation**
- From container detail view, tap Edit
- Modify food name or notes
- Save changes
- Verify success message
- Scan tag again to verify updated data
- **Acceptance:** Updated data written to tag and readable
- **Time:** 10 minutes
- **Record results in:** `docs/nfc-test-checklist.md`

**6.1.5 (Manual Test): Test clear container operation**
- From container detail view, tap "Clear & Reuse"
- Confirm action in alert
- Verify success message
- Scan tag again to verify cleared state
- **Acceptance:** Container marked as cleared, tag state updated
- **Time:** 10 minutes
- **Record results in:** `docs/nfc-test-checklist.md`

**Dependencies:** 5.2.2 complete, physical iPhone available, NFC tags procured  
**Total Task Time:** ~55 minutes

---

### Task 6.2: NFC Error Scenario Testing

**Atomic Tasks:**

**6.2.1 (Manual Test): Test tag removed during read**
- Start scan operation
- Hold iPhone near tag briefly
- Remove tag before read completes
- Verify error message displays
- Verify retry option works
- **Acceptance:** Error handled gracefully with clear message
- **Time:** 10 minutes
- **Record results in:** `docs/nfc-test-checklist.md`

**6.2.2 (Manual Test): Test tag removed during write**
- Start write operation
- Hold iPhone near tag briefly
- Remove tag before write completes
- Verify error message displays
- Verify retry option works
- Verify partial write doesn't corrupt tag
- **Acceptance:** Error handled gracefully, tag remains usable
- **Time:** 10 minutes
- **Record results in:** `docs/nfc-test-checklist.md`

**6.2.3 (Manual Test): Test multiple tags in range**
- Place 2+ NFC tags close together
- Attempt to scan
- Verify error message about multiple tags
- Remove extra tags and verify retry works
- **Acceptance:** Multiple tag scenario detected and handled
- **Time:** 10 minutes
- **Record results in:** `docs/nfc-test-checklist.md`

**6.2.4 (Manual Test): Test unregistered tag**
- Use a blank or non-app tag
- Attempt to scan
- Verify "unregistered tag" message displays
- Verify option to register tag (if implemented)
- **Acceptance:** Unregistered tags handled appropriately
- **Time:** 10 minutes
- **Record results in:** `docs/nfc-test-checklist.md`

**6.2.5 (Manual Test): Test read-only tag (if available)**
- Use a read-only NFC tag (or locked tag)
- Attempt to write data
- Verify error message about read-only tag
- **Acceptance:** Read-only tag detected and error shown
- **Time:** 10 minutes (skip if read-only tag unavailable)
- **Record results in:** `docs/nfc-test-checklist.md`

**Dependencies:** 6.1.5 complete  
**Total Task Time:** ~50 minutes

---

### Task 6.3: Tag Compatibility and Performance Testing

**Atomic Tasks:**

**6.3.1 (Manual Test): Test with NTAG213 tags**
- Repeat core workflows (write, read, edit, clear) with NTAG213 tags
- Measure approximate scan time for each operation
- Verify data capacity is sufficient
- Note any issues or limitations
- **Acceptance:** NTAG213 tags work reliably
- **Time:** 20 minutes
- **Record results in:** `docs/nfc-test-checklist.md`

**6.3.2 (Manual Test): Test with NTAG215 tags (if available)**
- Repeat core workflows with NTAG215 tags
- Compare performance to NTAG213
- Verify larger capacity works correctly
- **Acceptance:** NTAG215 tags work reliably (or note if unavailable)
- **Time:** 20 minutes
- **Record results in:** `docs/nfc-test-checklist.md`

**6.3.3 (Manual Test): Test with alternative tag types (if available)**
- Test with any other available NFC tag types
- Document compatibility and issues
- Note which tags work best
- **Acceptance:** Tag compatibility documented
- **Time:** 15 minutes (skip if no alternative tags)
- **Record results in:** `docs/nfc-test-checklist.md`

**Dependencies:** 6.2.5 complete  
**Total Task Time:** ~55 minutes (adjust based on tag availability)

---

## Phase 7: Polish, Documentation & Demo Prep

### Task 7.1: Error Handling and User Experience Polish

**Atomic Tasks:**

**7.1.1 (Implement): Improve error messages and recovery**
- Review all error messages for clarity
- Ensure all errors have actionable next steps
- Add retry buttons where appropriate
- Improve error alert styling
- Add haptic feedback for errors
- **Acceptance:** All error scenarios have clear, helpful messages
- **Time:** 20 minutes

**7.1.2 (Implement): Add loading states and animations**
- Add loading indicators for all async operations
- Add smooth transitions between views
- Add success animations (checkmarks, etc.)
- Ensure no jarring UI changes
- **Acceptance:** App feels polished and responsive
- **Time:** 25 minutes

**7.1.3 (Implement): Improve NFC scanning UX**
- Add visual indicator showing where to hold phone
- Add progress feedback during scan
- Add sound/haptic feedback on successful scan
- Improve instructional text
- **Acceptance:** NFC scanning feels intuitive and responsive
- **Time:** 20 minutes

**7.1.4 (Validate): Conduct UX review on physical device**
- Test complete app flow on physical device
- Note any confusing or awkward interactions
- Verify one-handed usability
- Test in different lighting conditions
- **Acceptance:** App is intuitive and easy to use
- **Time:** 20 minutes

**Dependencies:** 6.3.3 complete  
**Total Task Time:** ~85 minutes

---

### Task 7.2: Documentation and Knowledge Capture

**Atomic Tasks:**

**7.2.1 (Documentation): Create setup and build instructions**
- Create `docs/setup-instructions.md`
- Document Xcode version requirements
- Document iOS version requirements
- Document build and deployment steps
- Document NFC capability configuration
- Add troubleshooting section
- **Acceptance:** Another developer can build and run the app
- **Time:** 25 minutes

**7.2.2 (Documentation): Document NFC testing findings**
- Create `docs/nfc-findings.md`
- Summarize tag compatibility results
- Document recommended tag types and procurement
- Note any limitations or issues discovered
- Include performance metrics (scan times, success rates)
- Add cost analysis for tags at scale
- **Acceptance:** Findings provide clear guidance for production decisions
- **Time:** 30 minutes

**7.2.3 (Documentation): Document known limitations**
- Create `docs/known-limitations.md`
- List prototype limitations (no cloud sync, iOS only, etc.)
- Document edge cases not handled
- Note areas needing improvement for production
- Add suggestions for future enhancements
- **Acceptance:** Limitations are clearly documented
- **Time:** 20 minutes

**7.2.4 (Documentation): Create demo script**
- Create `docs/demo-script.md`
- Write step-by-step demo flow (under 3 minutes)
- Include what to say at each step
- Note what to show on screen
- Add backup plan if NFC fails during demo
- Include photos/screenshots if helpful
- **Acceptance:** Demo can be executed smoothly by following script
- **Time:** 20 minutes

**Dependencies:** 7.1.4 complete  
**Total Task Time:** ~95 minutes

---

### Task 7.3: Final Validation and Demo Preparation

**Atomic Tasks:**

**7.3.1 (Validate): Run full test suite**
- Run all unit tests
- Verify 100% pass rate
- Fix any failing tests
- Check code coverage (aim for >80% for business logic)
- **Acceptance:** All automated tests pass
- **Time:** 15 minutes

**7.3.2 (Validate): Complete end-to-end demo rehearsal**
- Follow demo script from 7.2.4
- Use real NFC tags and containers
- Time the demo (should be under 3 minutes)
- Note any issues or improvements
- Practice until smooth
- **Acceptance:** Demo runs smoothly without issues
- **Time:** 20 minutes

**7.3.3 (Validate): Verify all acceptance criteria**
- Review AC1-AC6 from PRD
- Verify each criterion is met
- Document any deviations or limitations
- Update PRD status if needed
- **Acceptance:** All acceptance criteria validated and documented
- **Time:** 20 minutes

**7.3.4 (Validate): Final code review and cleanup**
- Review all code for consistency
- Remove debug code and commented-out code
- Ensure consistent naming conventions
- Add missing code comments where needed
- Verify no compiler warnings
- **Acceptance:** Code is clean and production-ready
- **Time:** 25 minutes

**Dependencies:** 7.2.4 complete  
**Total Task Time:** ~80 minutes

---

## Phase 8: Delivery and Handoff

### Task 8.1: Final Deliverables

**Atomic Tasks:**

**8.1.1 (Documentation): Create project summary document**
- Create `docs/project-summary.md`
- Summarize what was built
- List all features implemented
- Reference all documentation
- Include next steps for production
- **Acceptance:** Summary provides complete project overview
- **Time:** 20 minutes

**8.1.2 (Documentation): Update README**
- Create or update `README.md` in project root
- Add project description
- Add quick start instructions
- Link to all documentation
- Add screenshots (if available)
- Add license and contact info
- **Acceptance:** README provides clear project introduction
- **Time:** 20 minutes

**8.1.3 (Validate): Final build and archive**
- Create release build
- Archive app for distribution (if needed)
- Verify build succeeds without warnings
- Test archived build on physical device
- **Acceptance:** Clean release build created
- **Time:** 15 minutes

**8.1.4 (Delivery): Conduct stakeholder demo**
- Present working prototype to stakeholders
- Follow demo script
- Demonstrate all four core workflows
- Discuss findings and learnings
- Gather feedback
- **Acceptance:** Demo completed successfully, feedback captured
- **Time:** 30 minutes (including Q&A)

**Dependencies:** 7.3.4 complete  
**Total Task Time:** ~85 minutes

---

## Summary Statistics

**Total Phases:** 8  
**Total Parent Tasks:** 17  
**Total Atomic Tasks:** 78  
**Estimated Total Time:** 12-15 hours

### Time Breakdown by Phase:
- Phase 0 (Setup): ~25 minutes
- Phase 1 (Data Layer): ~145 minutes (~2.4 hours)
- Phase 2 (NFC Layer): ~130 minutes (~2.2 hours)
- Phase 3 (UI Layer): ~235 minutes (~3.9 hours)
- Phase 4 (Business Logic): ~145 minutes (~2.4 hours)
- Phase 5 (Integration): ~140 minutes (~2.3 hours)
- Phase 6 (Physical Testing): ~160 minutes (~2.7 hours)
- Phase 7 (Polish & Docs): ~260 minutes (~4.3 hours)
- Phase 8 (Delivery): ~85 minutes (~1.4 hours)

**Critical Path:** 0.1 → 1.1 → 1.2 → 2.1 → 4.1 → 3.1-3.5 → 5.1 → 6.1-6.3 → 7.1-7.3 → 8.1

### Key Dependencies:
- Physical iPhone required starting at Phase 6
- NFC tags required starting at Phase 6
- All unit tests must pass before physical device testing
- Demo preparation depends on successful NFC testing

---

## Notes and Recommendations

### Test-First Approach
This task list follows a strict test-first methodology:
1. Write tests for data models and business logic
2. Implement code to pass tests
3. Validate with test runs
4. Manual testing for NFC (cannot be automated)

### Incremental Validation
Each phase includes validation tasks to catch issues early:
- Unit tests run after each implementation
- Simulator testing validates UI flows
- Physical device testing validates NFC operations
- Demo rehearsal validates complete user experience

### Flexibility
- Some tasks can be parallelized (e.g., UI views can be built while NFC layer is in progress)
- Physical device testing (Phase 6) can be moved earlier if device is available
- Documentation tasks can be done incrementally throughout development

### Risk Mitigation
- Early NFC testing (Phase 6) validates core feasibility assumption
- Manual test checklist ensures comprehensive error scenario coverage
- Demo rehearsal catches issues before stakeholder presentation

### Success Criteria
The prototype is complete when:
- ✅ All unit tests pass (100% pass rate)
- ✅ All acceptance criteria validated (AC1-AC6)
- ✅ NFC operations work reliably (95%+ success rate)
- ✅ Demo can be completed in under 3 minutes
- ✅ All documentation complete
- ✅ Stakeholder demo successful

---

**Document Version:** 1.0  
**Created:** January 15, 2026  
**Status:** Ready for Implementation
