# PRD: Container Inventory List with Accessibility-First Design

## Overview

Create a comprehensive inventory view that displays all active containers (tags with data) in a table format with swipe gestures for quick tag reset actions. The UI/UX must be designed with accessibility as a core principle, not as an afterthought, ensuring the app is fully usable by visually impaired users without relying solely on iOS accessibility features.

## Problem Statement

Currently, users can only view containers one at a time by scanning NFC tags. There is no way to:
- See an overview of all containers in the freezer
- Quickly identify which tags are in use vs. available
- Reset a tag after using the food without scanning it
- Navigate the app effectively if visually impaired

## Goals

1. **Inventory Management**: Provide a clear overview of all containers with active data
2. **Quick Actions**: Enable fast tag reset via swipe gestures
3. **Accessibility-First**: Design UI/UX that works for visually impaired users as a primary use case, not an accommodation
4. **Efficiency**: Reduce the need to physically scan tags for common operations

## User Stories

### Primary Users
- **As a home cook**, I want to see all my frozen containers in one list so I can quickly find what I'm looking for
- **As a home cook**, I want to swipe to reset a tag after I use the food so I don't need to scan it again
- **As a visually impaired user**, I want large, high-contrast UI elements with clear audio feedback so I can use the app independently
- **As a visually impaired user**, I want haptic feedback for all interactions so I can confirm my actions without seeing the screen

### Secondary Users
- **As a user with motor impairments**, I want large touch targets and forgiving swipe gestures
- **As a user in a dark freezer**, I want high contrast UI that works in low light conditions

## Requirements

### Functional Requirements

#### Inventory Table View
- **FR-1**: Display all containers with active data (not cleared) in a table/list format
- **FR-2**: Show key information for each container:
  - Food name (large, bold text)
  - Date frozen
  - Days frozen count
  - Best before date (if set) with status indicator
  - Visual status badge (Fresh/Approaching/Expired)
- **FR-3**: Sort containers by:
  - Default: Date frozen (oldest first)
  - Optional: Best before date (soonest first)
  - Optional: Food name (alphabetical)
- **FR-4**: Show count of active containers vs. total tags
- **FR-5**: Empty state when no containers are active

#### Swipe Gestures
- **FR-6**: Swipe left to reveal "Clear & Reuse" action
- **FR-7**: Swipe right to reveal "View Details" action
- **FR-8**: Confirmation dialog for destructive actions (Clear)
- **FR-9**: Haptic feedback on swipe threshold reached
- **FR-10**: Audio feedback (optional system sound) on action completion

#### Navigation
- **FR-11**: Accessible from main HomeView as primary navigation option
- **FR-12**: Tap on container row to view full details
- **FR-13**: Pull to refresh to reload data from Core Data

### Accessibility-First UI/UX Requirements

#### Visual Design
- **ACC-1**: Minimum touch target size: 60pt x 60pt (exceeds Apple's 44pt minimum)
- **ACC-2**: High contrast color scheme:
  - Text contrast ratio: minimum 7:1 (WCAG AAA)
  - Interactive elements: minimum 4.5:1
  - Status indicators: color + icon + text (never color alone)
- **ACC-3**: Font sizes:
  - Primary text (food name): minimum 20pt, bold
  - Secondary text (dates): minimum 16pt
  - Support Dynamic Type up to Accessibility XXL
- **ACC-4**: Spacing:
  - Minimum 16pt between interactive elements
  - Generous padding (24pt) around content
- **ACC-5**: Status indicators use multiple cues:
  - Color (green/orange/red)
  - Icon (checkmark/warning/x)
  - Text label ("Fresh"/"Expiring Soon"/"Expired")

#### Haptic Feedback
- **ACC-6**: Light impact on swipe gesture start
- **ACC-7**: Medium impact when swipe threshold reached (action will trigger)
- **ACC-8**: Success notification haptic on action completion
- **ACC-9**: Warning haptic on destructive action confirmation

#### Audio Feedback
- **ACC-10**: VoiceOver labels for all elements with clear, descriptive text
- **ACC-11**: VoiceOver hints for swipe actions ("Swipe left to clear, swipe right to view details")
- **ACC-12**: Optional audio cues (system sounds) for:
  - Swipe action triggered
  - Tag cleared successfully
  - Error states
- **ACC-13**: Speak container details on row focus (food name, days frozen, status)

#### Gesture Design
- **ACC-14**: Swipe threshold: 40% of screen width (forgiving for motor impairments)
- **ACC-15**: Swipe velocity threshold: low (slow swipes work)
- **ACC-16**: Alternative to swipe: Long press reveals action menu
- **ACC-17**: Undo capability for accidental clears (5-second window)

#### Screen Reader Support
- **ACC-18**: Semantic HTML-like structure (List, ListItem roles)
- **ACC-19**: Accessibility labels describe state ("Chicken Soup, frozen 3 days ago, fresh")
- **ACC-20**: Action buttons have clear labels ("Clear and reuse this container")
- **ACC-21**: Status changes announced ("Container cleared successfully")

### Non-Functional Requirements

#### Performance
- **NFR-1**: List loads in < 500ms for up to 100 containers
- **NFR-2**: Swipe gestures respond in < 16ms (60fps)
- **NFR-3**: Smooth scrolling with no jank

#### Usability
- **NFR-4**: First-time users can complete a swipe action without tutorial
- **NFR-5**: Visually impaired users can navigate entire list with VoiceOver
- **NFR-6**: Users can complete common tasks (view, clear) without scanning tags

## Design Specifications

### Inventory List Row Layout

```
┌─────────────────────────────────────────────────────┐
│  🥘  Chicken Soup                          [Fresh]  │
│      Frozen 3 days ago • Jan 12, 2026              │
│      Best Before: Apr 12, 2026 (87 days left)      │
└─────────────────────────────────────────────────────┘
```

### Swipe Actions

**Swipe Left (Destructive):**
```
┌─────────────────────────────────────────────────────┐
│                                      [Clear & Reuse] │
│  🥘  Chicken Soup                                   │
│      Frozen 3 days ago                              │
└─────────────────────────────────────────────────────┘
```

**Swipe Right (Non-destructive):**
```
┌─────────────────────────────────────────────────────┐
│  [View Details]                                     │
│                    Chicken Soup  🥘                 │
│                    Frozen 3 days ago                │
└─────────────────────────────────────────────────────┘
```

### Color Palette (High Contrast)

- **Background**: Pure white (#FFFFFF) or pure black (#000000) in dark mode
- **Primary Text**: Pure black (#000000) or pure white (#FFFFFF)
- **Secondary Text**: Dark gray (#333333) or light gray (#CCCCCC)
- **Fresh Status**: Dark green (#006400) with ✓ icon
- **Approaching Status**: Dark orange (#CC5500) with ⚠ icon
- **Expired Status**: Dark red (#CC0000) with ✗ icon
- **Interactive Elements**: iOS system blue with 4.5:1 contrast

### Typography

- **Food Name**: SF Pro Display, Bold, 20pt minimum
- **Dates**: SF Pro Text, Regular, 16pt minimum
- **Status Labels**: SF Pro Text, Semibold, 14pt minimum
- **All text**: Support Dynamic Type scaling

## Technical Considerations

### Data Model
- Use existing `ContainerRecord` model
- Filter for `isCleared == false` to show active containers
- Real-time updates when containers are cleared or edited

### State Management
- Use existing `ContainerViewModel`
- Add computed property for active containers
- Observe changes to refresh list automatically

### Swipe Implementation
- Use SwiftUI's native `swipeActions()` modifier
- Custom gesture recognizers for enhanced haptic feedback
- Undo stack for accidental clears

### Accessibility Testing
- Test with VoiceOver enabled throughout development
- Test with Dynamic Type at all sizes
- Test with Reduce Motion enabled
- Test with high contrast mode
- User testing with visually impaired users

## Success Metrics

1. **Usability**: 90% of users can clear a container via swipe on first attempt
2. **Accessibility**: 100% of features usable with VoiceOver
3. **Performance**: List scrolling maintains 60fps with 50+ containers
4. **Adoption**: 70% of users use inventory view instead of scanning for common tasks
5. **User Satisfaction**: Visually impaired users rate app 4.5/5 or higher

## Out of Scope (Future Enhancements)

- Search/filter functionality
- Batch operations (clear multiple containers)
- Custom sorting preferences saved
- Export inventory to CSV
- Sharing inventory with family members
- Barcode scanning for food items
- Recipe suggestions based on inventory

## Dependencies

- Existing Core Data persistence layer
- Existing ContainerViewModel
- iOS 15+ for SwiftUI features
- Physical device for haptic testing

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Swipe gestures conflict with system gestures | High | Use custom thresholds, provide alternative long-press |
| Performance issues with large lists | Medium | Implement lazy loading, pagination if needed |
| Accessibility features not discoverable | High | In-app tutorial, clear VoiceOver hints |
| Color contrast fails in all lighting | Medium | Test in various conditions, provide ultra-high contrast mode |

## Timeline Estimate

- Design & Prototyping: 2 days
- Core List Implementation: 3 days
- Swipe Gestures & Actions: 2 days
- Accessibility Features: 3 days
- Testing & Refinement: 2 days
- **Total**: ~12 days

## Acceptance Criteria

- [ ] Inventory list displays all active containers with correct information
- [ ] Swipe left reveals Clear action with confirmation
- [ ] Swipe right reveals View Details action
- [ ] All touch targets are minimum 60pt x 60pt
- [ ] Text contrast meets WCAG AAA (7:1 minimum)
- [ ] Haptic feedback works on all swipe interactions
- [ ] VoiceOver can navigate entire list and perform all actions
- [ ] Dynamic Type works correctly at all sizes
- [ ] List performs smoothly with 50+ containers
- [ ] Empty state displays when no containers active
- [ ] Pull to refresh updates data
- [ ] Status indicators use color + icon + text
- [ ] Undo works for accidental clears (5-second window)
- [ ] App passes accessibility audit with visually impaired users
