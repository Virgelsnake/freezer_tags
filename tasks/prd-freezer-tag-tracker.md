# Product Requirements Document: Freezer Tag Tracker

## Overview

Freezer Tag Tracker is a proof-of-concept iOS application that enables home cooks to identify and manage the contents of reusable food containers in their freezer using NFC technology. By tapping an NFC-enabled container with an iPhone, users can instantly view, update, or clear information about what's inside without opening the container or guessing its contents.

This is a **feasibility prototype** designed to validate that NFC read/write operations work reliably for this use case before investing in a full commercial product.

---

## Platforms & Release Targets

**In Scope:**
- **iOS only** (native iPhone app)
- Target: iOS 13.0+ (minimum version for Core NFC write capabilities)
- Devices: iPhone 7 and newer (devices with NFC hardware)

**Assumptions:**
- Testing will be conducted on physical iPhone devices (NFC cannot be tested in simulator)
- Initial prototype targets recent iOS versions (iOS 15+) for development convenience

---

## Recommended Stack & Rationale

**Primary Stack: Native iOS (Swift + SwiftUI)**

**Components:**
- **Language:** Swift 5.9+
- **UI Framework:** SwiftUI
- **NFC Framework:** Core NFC (Apple's native framework)
- **Data Persistence:** SwiftData or Core Data (local storage only)
- **Development Environment:** Xcode 15+

**Rationale:**
- **Core NFC Integration:** Native framework provides full access to NDEF read/write operations with proven reliability
- **Performance:** No bridge overhead; direct hardware access ensures fast tag scanning
- **Prototype Speed:** SwiftUI enables rapid UI development with declarative syntax
- **Future-Proof:** Native approach provides foundation for App Clips, Shortcuts, or background scanning if needed later
- **No Backend Complexity:** Local-only storage keeps the prototype simple and focused on NFC validation

**Trade-offs:**
- ✅ Best NFC reliability and performance
- ✅ Native iOS UX patterns
- ✅ Fastest development for iOS-only prototype
- ❌ iOS-only (no Android support)
- ❌ Requires Swift/iOS development knowledge

---

## Goals

1. **Validate NFC Feasibility:** Prove that consumer-grade NFC tags can reliably store and retrieve freezer container data via iPhone
2. **Demonstrate Core Workflows:** Successfully implement write, read, edit, and clear operations on NFC tags
3. **Enable In-Person Demo:** Create a working prototype that can be demonstrated with real tags and containers
4. **Inform Commercial Viability:** Gather learnings about tag types, data capacity, and user experience to guide product decisions

---

## User Stories & Personas

### Primary Persona: Home Cook

**Profile:**
- Regularly freezes leftovers and meal prep in reusable containers
- Loses track of what's in unlabelled frozen containers
- Wants quick identification without opening containers (avoiding frost, maintaining temperature)
- Comfortable using iPhone apps but not tech-savvy

**User Story:**
> As a **home cook** who freezes leftovers in unlabelled boxes,  
> I want to tap an NFC-enabled container with my iPhone and see the saved information about what is inside,  
> so that I can quickly identify, update, or reuse the container without guessing or opening it.

---

## Functional Requirements

### 1. NFC Tag Management

**1.1.** The app must detect and read NDEF-formatted NFC tags when the iPhone is held near them  
**1.2.** The app must write data to NDEF-formatted NFC tags  
**1.3.** The app must support at least one common NFC tag type (e.g., NTAG213, NTAG215, or similar)  
**1.4.** The app must handle tag read/write errors gracefully with clear user feedback

### 2. Container Record Management

**2.1.** Each container record must include:
- Container ID (unique identifier from NFC tag)
- Food name (required text field)
- Date frozen (required date field)
- Optional notes (optional text field, max 200 characters)

**2.2.** The app must store container records locally on the device  
**2.3.** The app must link each record to its physical NFC tag via the tag's unique ID

### 3. Create/Write Workflow

**3.1.** The app must provide an "Add Container" flow accessible from the home screen  
**3.2.** The app must present a form to capture food name, date frozen, and optional notes  
**3.3.** After form completion, the app must prompt the user to scan an NFC tag  
**3.4.** The app must write the record to the tag and save it locally  
**3.5.** The app must display a confirmation message upon successful write  
**3.6.** The app must handle write failures with clear error messages and retry options

### 4. Read/Scan Workflow

**4.1.** The app must provide a "Scan Container" flow accessible from the home screen  
**4.2.** The app must prompt the user to hold the iPhone near an NFC tag  
**4.3.** Upon successful read, the app must display the container's food name, date frozen, and notes  
**4.4.** The app must handle tags with no associated record (show "unregistered tag" message)  
**4.5.** The app must handle read failures with clear error messages

### 5. Edit/Update Workflow

**5.1.** From the container details screen (after scanning), the app must provide an "Edit" action  
**5.2.** The app must allow editing of food name, date frozen, and notes  
**5.3.** Upon saving edits, the app must update the local record  
**5.4.** The app must optionally rewrite the updated data to the NFC tag  
**5.5.** The app must display a confirmation message upon successful update

### 6. Clear/Reuse Workflow

**6.1.** From the container details screen, the app must provide a "Clear & Reuse" action  
**6.2.** The app must prompt for confirmation before clearing  
**6.3.** Upon confirmation, the app must mark the container record as empty/cleared  
**6.4.** The app must optionally clear or reset the NFC tag data  
**6.5.** The app must display a confirmation that the container is ready for reuse

### 7. User Interface Requirements

**7.1.** The app must have a clear home screen with "Add Container" and "Scan Container" actions  
**7.2.** The app must provide visual feedback during NFC scanning (e.g., "Hold iPhone near tag...")  
**7.3.** The app must use standard iOS UI patterns and conventions  
**7.4.** The app must be usable with one hand while holding a container

---

## Acceptance Criteria & Test Strategy

### Test Approach
- **Test-First Development:** Write unit tests for data models and business logic before implementation
- **Manual NFC Testing:** NFC operations require physical device testing (cannot be automated in simulator)
- **Integration Tests:** Validate data persistence and retrieval flows
- **User Acceptance Testing:** Conduct in-person demos with real tags and containers

### Acceptance Criteria

**AC1: Write New Container Record**
- ✅ User can enter food name, date, and notes in a form
- ✅ User can scan an NFC tag to write the record
- ✅ App displays success confirmation
- ✅ Data is saved locally and retrievable
- **Test:** Unit test for data model validation; manual test for NFC write

**AC2: Read Existing Container Record**
- ✅ User can initiate scan from home screen
- ✅ App reads NFC tag and displays associated record
- ✅ All fields (food name, date, notes) are displayed correctly
- **Test:** Unit test for data retrieval; manual test for NFC read

**AC3: Edit Container Record**
- ✅ User can tap "Edit" from container details screen
- ✅ User can modify any field and save changes
- ✅ Updated data is saved locally
- ✅ App displays success confirmation
- **Test:** Unit test for update logic; manual test for full flow

**AC4: Clear Container for Reuse**
- ✅ User can tap "Clear & Reuse" from container details screen
- ✅ App prompts for confirmation
- ✅ Container record is marked as cleared/empty
- ✅ App displays confirmation message
- **Test:** Unit test for clear operation; manual test for full flow

**AC5: Error Handling**
- ✅ App handles tag read failures gracefully (clear error message)
- ✅ App handles tag write failures gracefully (clear error message, retry option)
- ✅ App handles unregistered tags (displays appropriate message)
- **Test:** Manual testing with various error scenarios

**AC6: Demo Readiness**
- ✅ All four core workflows (write, read, edit, clear) can be demonstrated in sequence
- ✅ Demo can be completed in under 3 minutes
- ✅ Works with real NFC tags attached to physical containers
- **Test:** Full end-to-end demo with stakeholders

---

## Definition of Done

### For Each Feature:
- [ ] Unit tests written and passing for business logic
- [ ] Manual NFC testing completed on physical device
- [ ] Code reviewed and merged to main branch
- [ ] No critical bugs or crashes

### For Prototype Completion:
- [ ] All acceptance criteria (AC1-AC6) validated
- [ ] Successful in-person demo completed with real tags
- [ ] Documentation created: setup instructions, known limitations, tag recommendations
- [ ] Learnings documented: tag types tested, data capacity findings, UX observations

---

## Non-Goals (Out of Scope)

**For this feasibility prototype, the following are explicitly out of scope:**

1. **Multi-User & Cloud Sync:** No user accounts, authentication, or cloud backend
2. **Cross-Platform Support:** No Android or web versions
3. **Advanced Features:**
   - No photos or images on tags
   - No barcode/QR code scanning
   - No recipe integration or meal planning
   - No inventory analytics or expiration alerts
4. **Background Scanning:** No system-wide NFC shortcuts or background tag detection
5. **Tag Provisioning:** No bulk tag writing or tag management tools
6. **Commercial Features:** No payment processing, user onboarding, or app store optimization
7. **Complex Data:** No nutritional info, portion sizes, or multi-item containers

---

## Design Considerations

### UI/UX Principles
- **Simplicity First:** Minimal screens, clear actions, no unnecessary complexity
- **One-Handed Use:** Design for users holding a container in one hand, phone in the other
- **Clear Feedback:** Visual and haptic feedback during NFC scanning
- **Error Recovery:** Always provide clear next steps when operations fail

### Key Screens
1. **Home Screen:** Two primary actions (Add Container, Scan Container)
2. **Add Container Form:** Food name, date picker, notes field, "Scan Tag" button
3. **Scanning View:** Visual indicator (animation or progress) while waiting for tag
4. **Container Details:** Display all fields, with Edit and Clear actions
5. **Edit Form:** Pre-populated form with Save/Cancel actions

### iOS Design Patterns
- Use standard SwiftUI components (NavigationStack, Form, List)
- Follow iOS Human Interface Guidelines
- Use SF Symbols for icons
- Support light and dark mode

---

## Technical Considerations

### NFC Implementation Details

**Core NFC Framework:**
- Use `NFCNDEFReaderSession` for reading tags
- Use `NFCNDEFReaderSession` with write capability for writing tags
- Handle `NFCNDEFMessage` and `NFCNDEFPayload` for data encoding

**Tag Type Selection:**
- Recommend NTAG213 or NTAG215 tags (widely available, good capacity)
- NTAG213: 144 bytes user memory (~sufficient for basic records)
- NTAG215: 504 bytes user memory (more headroom)
- Tags must be NDEF-formatted

**Data Storage Strategy:**
- **Option A (Hybrid):** Store minimal ID on tag, full record in local database (recommended for prototype)
- **Option B (Tag-Only):** Store all data directly on tag (simpler but limited by tag capacity)
- Use SwiftData or Core Data for local persistence

**Permissions:**
- Add `NFCReaderUsageDescription` to Info.plist
- Request NFC permission on first use

### Dependencies
- No external dependencies required (Core NFC is built-in)
- Optional: Consider SwiftData (iOS 17+) or Core Data (iOS 13+) for persistence

### Known Constraints
- NFC write operations require user to hold phone steady near tag for 1-2 seconds
- Some tag types may have write limitations or require specific formatting
- Freezer environment may affect tag adhesion (not app functionality)

---

## Implementation Notes (Non-Binding)

### Suggested Module Structure
```
FreezerTagTracker/
├── Models/
│   ├── ContainerRecord.swift (data model)
│   └── NFCManager.swift (NFC operations wrapper)
├── Views/
│   ├── HomeView.swift
│   ├── AddContainerView.swift
│   ├── ScanView.swift
│   ├── ContainerDetailView.swift
│   └── EditContainerView.swift
├── ViewModels/
│   └── ContainerViewModel.swift
└── Persistence/
    └── DataStore.swift (SwiftData/Core Data wrapper)
```

### Implementation Sequence
1. **Phase 1 - Data Layer:** Create data models and local persistence (testable without NFC)
2. **Phase 2 - UI Shell:** Build all views with mock data (testable in simulator)
3. **Phase 3 - NFC Read:** Implement tag reading and display
4. **Phase 4 - NFC Write:** Implement tag writing for new containers
5. **Phase 5 - Edit/Clear:** Complete update and clear workflows
6. **Phase 6 - Polish:** Error handling, feedback, and demo preparation

### Edge Cases to Handle
- **Tag already written by another app:** Display warning, offer to overwrite
- **Tag write interrupted:** Detect partial write, offer retry
- **Multiple tags detected:** Prompt user to remove extra tags
- **Tag removed too quickly:** Detect incomplete read/write, prompt to retry
- **Empty/unformatted tag:** Offer to format as NDEF (if possible)
- **Tag memory full:** Detect capacity issues, suggest using hybrid storage approach

### Testing Recommendations
- **Unit Tests:** Data model validation, date formatting, record CRUD operations
- **Manual Test Checklist:** Create a checklist for physical device testing (write, read, edit, clear, error scenarios)
- **Tag Testing:** Test with at least 2-3 different tag types to validate compatibility
- **Environment Testing:** Test tags in freezer conditions (cold, moisture) to validate durability

---

## Success Metrics

### Prototype Success Criteria
1. **Technical Validation:** Successfully read/write to NFC tags in 95%+ of attempts
2. **Workflow Completion:** All four core workflows (write, read, edit, clear) demonstrated successfully
3. **Demo Success:** Complete end-to-end demo without crashes or critical errors
4. **Tag Compatibility:** Identify at least one reliable, cost-effective tag type suitable for production

### Learnings to Capture
- **Tag Performance:** Which tag types work best? Data capacity limits?
- **User Experience:** How long does scanning take? Is the UX intuitive?
- **Technical Feasibility:** Any unexpected limitations or challenges with Core NFC?
- **Cost Analysis:** Estimated per-tag cost at scale (for commercial viability assessment)

---

## Open Questions

1. **Tag Procurement:** Where will you source NFC tags for testing? (Recommendation: Amazon, AliExpress, or TagsForDroid for small quantities)
2. **Tag Attachment:** How will tags be attached to containers? (Adhesive stickers, embedded in lids, reusable clips?)
3. **Freezer Testing:** Will you test tag durability in actual freezer conditions during this prototype phase?
4. **Data Retention:** Should cleared containers retain history, or completely delete records?
5. **Tag Reuse:** If a tag is cleared, should it be rewritable for a new container, or one-time use?
6. **Error Logging:** Do you want to log NFC errors for debugging, or keep it simple for the prototype?

---

## Appendix: Source Notes

**Primary Source:** `@user_story` file provided by user

**Key Facts Extracted:**
- Target user: Home cook freezing leftovers in reusable containers
- Core problem: Cannot identify frozen container contents without opening
- Solution: NFC tags + iPhone app for tap-to-view functionality
- Data fields: Container ID, food name, date frozen, optional notes
- Four core workflows: Create/write, read, edit/update, clear/reuse
- Out of scope: Multi-user sync, cloud backend, complex data, background scanning
- Definition of done: Successfully demonstrate all three flows (write, read, edit) with real tags
- Commercial intent: Prototype to validate feasibility before scaling to dropship product
- Tag considerations: Cost-effective, freezer-safe, food-safe, bulk purchasable

**Assumptions Made:**
- iOS 13.0+ target (minimum for Core NFC write support)
- NTAG213/215 tag types (common, affordable, sufficient capacity)
- SwiftUI for UI (modern, rapid development)
- Local-only storage (no backend for prototype)
- Manual testing approach (NFC cannot be simulated)

---

**Document Version:** 1.0  
**Created:** January 15, 2026  
**Status:** Draft - Awaiting Review
