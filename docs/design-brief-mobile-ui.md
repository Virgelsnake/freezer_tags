# Freezer Tag Tracker -- Mobile UI Design Brief

**Date:** 9 April 2026
**Prepared by:** Steve Shearman
**Document version:** 1.0
**Platform:** Native iOS (SwiftUI, iPhone)

---

## 1. Project Overview

### What We Are Building

Freezer Tag Tracker is an iOS app that solves a simple but universal problem: people freeze food in reusable containers and quickly forget what is inside. The app uses NFC (Near Field Communication) tags attached to containers so that a user can tap their iPhone against a container and instantly see what is in it, when it was frozen, and whether it is still within its best-before window.

The current prototype has validated the core technical feasibility of reading and writing NFC tags. This brief commissions a new mobile-first UI design that elevates the experience from a proof of concept into something that feels inclusive, modern, and delightful to use for everyone, including users who are blind or have cognitive conditions that affect memory.

### Why This Matters

This app sits at the intersection of practical daily life and genuine accessibility need. For a sighted user with good memory, forgetting what is in the freezer is a mild inconvenience. For a blind person or someone living with early-stage dementia, it can mean the difference between eating safely and confidently or avoiding the freezer altogether. The UI must treat accessibility not as a compliance checkbox but as a core design driver.

### Core Value Proposition

One tap on a container tells you exactly what is inside, when it went in, and whether it is still good.

---

## 2. Target Audience

The app serves two overlapping audiences, and the design must work brilliantly for both.

### Primary Audience A -- Elderly and Vulnerable Adults

Adults aged 65 and over, living independently or with light support, who freeze meals and leftovers regularly. This group includes people with age-related vision loss, reduced fine motor control, and early-stage cognitive conditions such as mild cognitive impairment (MCI) or early dementia. They may not be confident with technology and will abandon an app that feels complicated or overwhelming.

### Primary Audience B -- General Public (Inclusive Design as Differentiator)

Broad consumer audience across all ages who freeze food at home. These users expect a clean, modern app that works quickly and stays out of the way. For this group, the inclusive design principles (large touch targets, clear hierarchy, simple flows) will feel like premium quality rather than accommodation.

### Design Implication

Every screen must pass a simple test: "Could my 78-year-old mum who is losing her sight use this confidently on a Tuesday evening after dinner?" If the answer is yes, the general public will find it effortless.

---

## 3. Current App Structure and Flows

The existing prototype has the following screens and workflows. The new design should preserve these core flows but is free to reimagine navigation, layout, and interaction patterns.

### 3.1 Screens

**Home Screen**
The entry point. Currently shows a snowflake icon with two large action buttons: "Add Container" and "Scan Container". This is the hub from which all activity begins.

**Add Container Screen**
A form with the following fields: food name (required), date frozen (defaults to today), best-before date (optional toggle), and notes (optional, max 200 characters with a live character counter). A "Save & Scan Tag" button initiates the NFC write session.

**Scan Screen**
Presented as a modal. Shows three states: scanning (waiting for NFC), success (container found), and error (with retry). After a successful scan, the user is taken to the container detail view.

**Container Detail Screen**
Displays all information about a scanned container: food name, date frozen, days frozen, best-before status (fresh / approaching / expired), notes, and the NFC tag ID. Provides toolbar actions for "Edit" and "Clear & Reuse".

**Edit Container Screen**
A form identical in structure to Add Container, pre-populated with the existing data. Save button is disabled until changes are detected.

**Container Inventory List** (Designed but not yet built)
A list of all active (non-cleared) containers showing food name, date frozen, days frozen, best-before status, and a container count. Supports swipe-left to clear and swipe-right to view details. Includes sorting by date frozen, best-before date, or alphabetically.

### 3.2 Core User Flows

**Flow 1 -- Add a new container**
Home > Add Container > Fill form > Tap "Save & Scan Tag" > Hold iPhone to NFC tag > Success confirmation > Return to Home

**Flow 2 -- Scan an existing container**
Home > Scan Container > Hold iPhone to NFC tag > View Container Detail

**Flow 3 -- Edit a container**
Container Detail > Edit > Modify fields > Save

**Flow 4 -- Clear and reuse a container**
Container Detail > Clear & Reuse > Confirm > Container marked as empty

---

## 4. Existing User Stories

These user stories are drawn from the current product requirements. All must be supported by the new design.

### US-01: Write a New Container Record
**As a** home cook,
**I want to** enter details about food I am freezing and write them to an NFC tag on my container,
**So that** I can identify the contents later without opening the container.

**Acceptance criteria:**
- User can enter food name (required), date frozen, optional best-before date, and optional notes (max 200 characters)
- Date frozen defaults to today
- Form validation prevents submission without a food name
- After saving, app initiates NFC write session
- Success confirmation is displayed after a successful write
- Data is persisted locally

### US-02: Read/Scan an Existing Container
**As a** home cook,
**I want to** tap my iPhone against a tagged container and instantly see what is inside,
**So that** I can decide what to eat without opening containers or guessing.

**Acceptance criteria:**
- User initiates scan from the home screen
- App reads the NFC tag and displays the associated record
- Food name, date frozen, days frozen, best-before status, and notes are all visible
- Unregistered tags show an appropriate message
- Read failures offer a clear retry option

### US-03: Edit a Container Record
**As a** home cook,
**I want to** update the details on an existing container,
**So that** information stays accurate if I add items or correct a mistake.

**Acceptance criteria:**
- Edit is accessible from the container detail view
- Form is pre-populated with current data
- Same validation rules as adding a new container
- Save button is disabled until changes are made
- Success confirmation after saving

### US-04: Clear and Reuse a Container
**As a** home cook,
**I want to** mark a container as empty and ready for reuse,
**So that** I can recycle my containers and tags without confusion.

**Acceptance criteria:**
- Clear action is accessible from the container detail view
- A confirmation dialogue prevents accidental clearing
- Container is marked as cleared in the database
- Success confirmation is displayed

### US-05: View Container Inventory
**As a** home cook,
**I want to** see a list of everything currently in my freezer,
**So that** I can plan meals and avoid waste.

**Acceptance criteria:**
- List shows all active (non-cleared) containers
- Each row shows food name, date frozen, days frozen, and best-before status
- List is sortable by date frozen, best-before date, or food name
- Empty state is shown when no containers are active
- Swipe gestures provide quick actions (clear, view detail)
- Total count of active containers is visible

### US-06: Handle NFC Errors Gracefully
**As a** user,
**I want to** receive clear, helpful feedback when something goes wrong with scanning or writing,
**So that** I know what happened and what to do next.

**Acceptance criteria:**
- Tag read failures show a user-friendly message and retry option
- Tag write failures show a user-friendly message and retry option
- Unregistered tags display an appropriate message
- Tag-removed-during-operation is handled gracefully
- Multiple tags in range are handled with guidance

---

## 5. New User Stories -- Blind and Low-Vision Users

These stories ensure the app is fully usable with VoiceOver and other assistive technologies. The designer should treat these as first-class requirements, not edge cases.

### US-07: Navigate the Entire App with VoiceOver
**As a** blind user,
**I want to** navigate every screen and complete every workflow using only VoiceOver gestures,
**So that** I can use this app independently without sighted assistance.

**Acceptance criteria:**
- Every interactive element has a clear, descriptive accessibility label (not just the visible text)
- Every interactive element has an accessibility hint explaining what will happen on activation
- Focus order follows a logical reading sequence on every screen
- No information is conveyed by colour alone; all status indicators use text and/or iconography alongside colour
- Screen transitions announce the new context (e.g., "Container detail: Beef Stew, frozen 3 days ago")
- Modal sheets (such as the NFC scan sheet) announce their purpose when presented
- The app never traps focus in a dead end

### US-08: Receive Audio and Haptic Feedback During NFC Scanning
**As a** blind user,
**I want to** receive clear audio cues and haptic feedback throughout the NFC scanning process,
**So that** I know when to hold my phone near the tag, when the scan is in progress, and whether it succeeded or failed.

**Acceptance criteria:**
- A distinct sound or VoiceOver announcement plays when the scan session begins ("Ready to scan. Hold your iPhone near the container tag.")
- A subtle haptic pulse confirms the phone has detected a tag
- A success sound and strong haptic confirmation play on a successful read or write
- A failure sound and error haptic play on failure, followed by a VoiceOver announcement of the error and how to retry
- Haptic patterns are distinct enough to differentiate between "detected", "success", and "failure" without sound

### US-09: Understand Best-Before Status Without Seeing Colour
**As a** user who cannot see colour,
**I want** the best-before status to be conveyed through text, icons, and sound,
**So that** I can make safe decisions about whether food is still good to eat.

**Acceptance criteria:**
- "Fresh" status is communicated as text ("Fresh -- X days remaining") plus a recognisable icon, not just a green indicator
- "Approaching" status is communicated as text ("Use soon -- X days remaining") plus a warning icon
- "Expired" status is communicated as text ("Expired -- X days past best before") plus an alert icon
- VoiceOver reads the full status including the number of days
- A distinct haptic pattern accompanies each status level when the detail view loads

### US-10: Identify Containers by Sound When Browsing the Inventory List
**As a** blind user,
**I want to** quickly understand each item in my freezer inventory as I swipe through the list,
**So that** I can find what I am looking for without memorising positions.

**Acceptance criteria:**
- Each list row's VoiceOver label reads the full summary: "[Food name], frozen [X] days ago, [best-before status]"
- Swipe actions are announced: "Swipe left to clear and reuse, swipe right to view details"
- The active sort order is announced when changed
- The total container count is available as a VoiceOver summary at the top of the list
- Empty state is announced clearly: "Your freezer inventory is empty"

### US-11: Complete the Add Container Form Using Only Voice and Gestures
**As a** blind user,
**I want to** fill in the add-container form efficiently using VoiceOver and dictation,
**So that** tagging a new container is quick and does not require sighted help.

**Acceptance criteria:**
- Each form field announces its label, current value, and any constraints (e.g., "Food name, required, text field")
- The character counter for notes is announced as the user types (e.g., "142 of 200 characters")
- Date pickers are fully navigable with VoiceOver
- The save button announces its disabled/enabled state and the reason if disabled ("Save and Scan Tag, disabled, food name is required")
- Validation errors are announced immediately when they occur, not just displayed visually
- Form sections are grouped with accessibility containers for efficient navigation

---

## 6. New User Stories -- Users with Cognitive Conditions Affecting Memory

These stories address the needs of users living with conditions such as early-stage dementia, mild cognitive impairment, brain fog, ADHD, or age-related memory decline. The design must reduce cognitive load, provide reassurance, and prevent confusion.

### US-12: Understand What to Do at Every Step
**As a** user with memory difficulties,
**I want** every screen to clearly tell me what it is for and what I should do next,
**So that** I never feel lost or confused about where I am in the app.

**Acceptance criteria:**
- Every screen has a clear, simple heading that explains its purpose in plain language
- Primary actions are visually dominant and use action-oriented labels ("Scan a Container", not "Scan")
- Secondary actions are visually subordinate and clearly separated from primary actions
- No more than two primary actions are presented on any single screen
- Breadcrumb or progress indicators show where the user is in a multi-step flow
- A persistent "Home" affordance is always reachable

### US-13: Receive Reassurance After Completing an Action
**As a** user with memory difficulties,
**I want** clear, lingering confirmation when I complete an action,
**So that** I am confident something actually happened and do not repeat the action unnecessarily.

**Acceptance criteria:**
- Success confirmations remain visible for at least 4 seconds (not brief toasts)
- Confirmations use simple, affirming language ("Done! Beef Stew has been saved to your container")
- Confirmations include a summary of what was saved, not just "Success"
- The user is not automatically navigated away from a confirmation before they have processed it
- A "What just happened?" affordance or summary is available if the user returns to the home screen and has forgotten what they did

### US-14: Avoid Accidental Destructive Actions
**As a** user who may tap things without fully processing what they do,
**I want** destructive actions (like clearing a container) to require deliberate, multi-step confirmation,
**So that** I do not accidentally erase information I need.

**Acceptance criteria:**
- Destructive actions require a two-step confirmation: first tap reveals the option, second tap confirms
- Confirmation dialogues use plain language: "This will mark Beef Stew as empty. You will not be able to undo this. Are you sure?"
- Destructive buttons are visually distinct (but never rely on colour alone) and spatially separated from safe actions
- An undo window of at least 10 seconds is provided after clearing, with a prominent "Undo" button
- The undo option is announced by VoiceOver

### US-15: Recognise the App and Orient Quickly on Return
**As a** user who may not remember using the app recently,
**I want** the home screen to immediately remind me what this app does and show my recent activity,
**So that** I can re-orient myself without confusion.

**Acceptance criteria:**
- The home screen includes a brief, friendly tagline or description ("Tap a container to see what is inside")
- The most recently scanned or added container is displayed on the home screen as a "last activity" summary
- The home screen layout is consistent and never changes position of core elements
- If the user last used the app more than 24 hours ago, a gentle re-introduction is shown ("Welcome back. You have 7 containers in your freezer.")
- Visual and textual cues are consistent and predictable across sessions

### US-16: Use Simple, Consistent Language Throughout
**As a** user with cognitive difficulties,
**I want** the app to use short, familiar words and consistent terminology,
**So that** I do not have to decode jargon or remember different terms for the same thing.

**Acceptance criteria:**
- All UI text uses plain English at a reading level no higher than age 11
- The same concept always uses the same word (e.g., always "container", never switching between "container", "box", "item", "package")
- Button labels are verb-first and describe the outcome ("Save to Container", "Scan a Container")
- Error messages explain the problem and the solution in one sentence
- Technical terms like "NFC" and "NDEF" never appear in user-facing text
- Numbers are displayed simply (e.g., "3 days ago", not "3d 4h 22m")

### US-17: Receive Gentle Prompts for Items Approaching Expiry
**As a** user who may forget to check the freezer regularly,
**I want** the app to surface items that are approaching or past their best-before date when I open it,
**So that** I can use them before they go to waste.

**Acceptance criteria:**
- On app launch, if any containers are within 7 days of their best-before date or past it, a non-intrusive summary is displayed on the home screen
- The summary uses friendly, non-alarming language ("You have 2 items to use soon")
- Tapping the summary navigates to a filtered view of those items
- Items past their best-before date are clearly but gently indicated ("Best before date has passed")
- The prompts do not stack up or become overwhelming if many items are expiring

---

## 7. Branding and Visual Design Direction

The brand should feel warm, trustworthy, and modern without being cold or clinical. Think of the visual personality as a kind, capable friend who happens to be very well organised.

### 7.1 Colour Palette

Design an accessible colour palette that meets the following requirements:

**Primary colour:** A calming, mid-tone blue. Blue conveys trust and reliability and works well as a primary action colour against both light and dark backgrounds. Avoid overly saturated or electric blues; aim for something closer to a soft steel blue or a muted cornflower.

**Secondary colour:** A warm, soft teal or sage green. This will be used for positive status indicators (fresh items) and secondary actions. It should feel natural and reassuring.

**Accent colour:** A warm amber or soft coral for attention states (approaching best-before). This needs to feel like a gentle nudge, not an alarm.

**Alert colour:** A muted, warm red for expired items and destructive actions. Avoid harsh, high-saturation reds; the tone should be serious but not frightening.

**Neutral palette:** A range from warm off-white through warm greys to a soft charcoal for text. Avoid pure white (#FFFFFF) and pure black (#000000) as large background/text colours, as the stark contrast can cause visual fatigue.

**All colour pairings must achieve WCAG AAA contrast (7:1 minimum) for body text and WCAG AA (4.5:1 minimum) for large text and UI components.**

### 7.2 Typography

Use the iOS system font (SF Pro) to maintain native feel and excellent Dynamic Type support. Define a clear type scale:

- **Display/Title:** SF Pro Rounded, 28pt bold minimum. Used for screen headings and the food name on detail views.
- **Body:** SF Pro, 18pt regular minimum. Used for descriptions, notes, and list content.
- **Caption:** SF Pro, 14pt regular minimum. Used for timestamps and secondary metadata.
- **All text must support Dynamic Type scaling up to Accessibility XXL.** The layout must not break at any Dynamic Type size.

### 7.3 Spacing and Layout

- Generous whitespace throughout. The app should feel calm and uncluttered.
- Minimum touch target size: 60pt x 60pt (exceeding Apple's 44pt guideline). This accommodates reduced fine motor control.
- Consistent margins: at least 20pt horizontal margins on all screens.
- Clear visual separation between sections using spacing rather than heavy dividers.
- Content should breathe. When in doubt, add more space.

### 7.4 Iconography

- Use SF Symbols throughout for consistency with the iOS ecosystem.
- Icons should always be paired with text labels. Never use an icon alone to convey meaning.
- Icon weight should match the type weight of adjacent text.
- Status icons must be distinct in shape, not just colour (e.g., checkmark for fresh, clock for approaching, exclamation triangle for expired).

### 7.5 Visual Personality

- Rounded corners on cards and buttons (12-16pt radius).
- Subtle shadows for depth rather than hard borders.
- Smooth, gentle animations for state transitions (no abrupt changes).
- Illustrations or micro-animations on empty states and success confirmations to add warmth.
- The overall aesthetic should sit between Apple Health and Monzo: clean, modern, and reassuringly simple.

---

## 8. Design Specifications and Constraints

### 8.1 Platform Constraints

- **iOS 15.0+ only.** The designer should use iOS design patterns and components but does not need to design for Android.
- **iPhone only** (no iPad layout required for this phase).
- **SwiftUI implementation.** Designs should be achievable in SwiftUI without custom UIKit bridges where possible.
- **Apple's NFC system sheet cannot be customised or suppressed.** When the app initiates an NFC session, Apple presents a system-level "Ready to Scan" popup that persists for approximately 1.5 seconds after a successful scan. The design must account for this overlay and ensure the transition to the result screen feels smooth despite it.

### 8.2 Accessibility Requirements (Non-Negotiable)

These are hard requirements, not aspirational goals:

- **WCAG 2.1 Level AAA compliance** for colour contrast on all text.
- **Minimum touch target: 60pt x 60pt** for all interactive elements.
- **Full VoiceOver support** with custom accessibility labels, hints, and traits for every element.
- **Full Dynamic Type support** up to Accessibility XXL. Layouts must reflow gracefully at all sizes.
- **No information conveyed by colour alone.** Every colour-coded status must also use text and a distinct icon shape.
- **Haptic feedback** for all significant interactions: button presses, NFC events, status changes, destructive action confirmations.
- **Reduce Motion support.** All animations must respect the system "Reduce Motion" setting, with static alternatives.
- **High Contrast mode support.** Designs must remain legible and usable when the system high-contrast setting is enabled.
- **Minimum font size: 14pt** for any text in the interface, even captions and metadata.

### 8.3 NFC Interaction Design

The NFC scanning moment is the signature interaction of the app and deserves particular attention:

- **Pre-scan:** The screen should clearly instruct the user on what to do ("Hold the top of your iPhone near the tag on your container"). Include a simple illustration or animation showing phone-to-container proximity.
- **During scan:** Provide continuous feedback that something is happening. Consider a pulsing animation, haptic heartbeat, or audio tone.
- **Post-scan success:** A clear, celebratory moment. Show the container name immediately. The transition from "scanning" to "here is your food" should feel instant and satisfying.
- **Post-scan failure:** Calm, helpful guidance. Never blame the user. Offer a clear retry action and simple troubleshooting ("Try holding your phone a little closer to the tag").

### 8.4 Data Model Summary

The designer should be aware of the data available for display:

| Field | Type | Notes |
|-------|------|-------|
| Food name | Text (required) | Up to 100 characters |
| Date frozen | Date (required) | Defaults to today on creation |
| Days frozen | Computed integer | Calculated from date frozen |
| Best-before date | Date (optional) | User-toggled |
| Best-before status | Enum | Fresh / Approaching (within 7 days) / Expired / None |
| Notes | Text (optional) | Up to 200 characters |
| Tag ID | String | Technical identifier, low prominence |
| Is cleared | Boolean | Whether container has been emptied |
| Created at | Timestamp | Record creation |
| Updated at | Timestamp | Last modification |

### 8.5 Performance Expectations

- NFC read time: under 2 seconds in typical conditions
- NFC write time: under 3 seconds in typical conditions
- Inventory list: smooth 60fps scrolling with 50+ containers
- All animations: 60fps, under 300ms duration

---

## 9. Deliverables Requested from the Designer

1. **Screen designs** for all screens listed in Section 3, plus any new screens implied by the user stories in Sections 5 and 6 (e.g., expiry summary, re-orientation welcome-back state)
2. **Component library** showing buttons, form fields, status badges, list rows, confirmation dialogues, and empty states at all relevant sizes
3. **Interaction specifications** for the NFC scanning flow, including all states and transitions
4. **VoiceOver annotations** on every screen showing accessibility labels, hints, focus order, and groupings
5. **Dynamic Type specimens** showing key screens at default, Large, and Accessibility XXL sizes
6. **Colour palette specification** with contrast ratios documented for all pairings
7. **Motion specifications** showing all animations with durations, easing curves, and Reduce Motion alternatives
8. **Haptic map** documenting which haptic feedback type is used for each interaction

---

## 10. Out of Scope

The following are explicitly not part of this design phase:

- iPad or Mac layouts
- Android design
- Multi-user accounts, authentication, or cloud sync
- Photo capture or barcode scanning
- Recipe integration or nutritional information
- Push notifications or background scanning
- Onboarding tutorial or walkthrough (may be a future phase)
- App Store listing design or marketing materials
- Settings screen (may be added in a future phase)

---

## 11. Reference and Inspiration

The designer is encouraged to study:

- **Apple Health app** for its clean information hierarchy and accessible use of colour and iconography
- **Monzo banking app** for its warm, friendly tone and clear transaction-detail pattern
- **Be My Eyes app** for its excellent VoiceOver experience and inclusive design thinking
- **Apple's Human Interface Guidelines** (particularly the Accessibility and Inclusion sections)
- **WCAG 2.1 Level AAA** guidelines for contrast and interaction requirements

---

## 12. Success Criteria for the Design

The design will be considered successful if:

1. A blind user can complete all four core flows (add, scan, edit, clear) using only VoiceOver, with no sighted assistance, in under twice the time of a sighted user
2. A user with mild cognitive impairment can add and scan a container without external prompting or written instructions
3. A sighted user with no accessibility needs finds the app visually appealing and faster to use than the current prototype
4. All screens pass WCAG 2.1 Level AAA contrast requirements when audited
5. The design can be implemented in SwiftUI without requiring custom UIKit components for core flows
6. Every screen has been annotated with VoiceOver labels, hints, and focus order

---

*End of brief.*
