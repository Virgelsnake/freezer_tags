# Freezer Tag Tracker - Add Container Low-Fidelity Wireframes

**Date:** 9 April 2026
**Related UX spec:** [add-container-ux-spec.md](/Users/steveshearman/xcode_projects/freezer_tag_poc/docs/add-container-ux-spec.md)
**Purpose:** Low-fidelity wireframes, content model, and component states for the add-container flow

## 1. Flow Summary

This wireframe set covers:

1. `Add a container`
2. `Review and write`
3. `Hold your phone near the tag`
4. `Write success`
5. `Write failure`
6. `Settings` additions required to support the flow

The intent is to give design and engineering a shared target for layout, hierarchy, copy, and state behavior before visual polish.

## 2. Wireframe Principles

- One dominant primary action per screen
- Large touch targets, minimum 60 by 60 points
- Strong reading order for VoiceOver and Switch Control
- Minimal typing, with food presets and dictation support
- Short, plain-English copy
- Confirmation through text, sound, and haptics
- No reliance on color alone

## 3. Screen A - Add a Container

### 3.1 Default state

```text
+--------------------------------------------------+
| Back                                             |
|                                                  |
| Step 1 of 2                                      |
| Add a container                                  |
| Tell us what you are freezing, then we will      |
| help you write it to the tag.                    |
|                                                  |
| Food name                                        |
| +--------------------------------------------+   |
| | Example: Beef stew                      [Mic]| |
| +--------------------------------------------+   |
| Required                                         |
|                                                  |
| Choose a food type                               |
| This can add a suggested best-quality date.      |
|                                                  |
| [ Beef ]   [ Poultry ]   [ Fish ]                |
| [ Prepared meal ]   [ Pastries ]                 |
| [ Vegetables ]   [ Other ]                       |
|                                                  |
| Date frozen                         Today   >    |
|                                                  |
| Best quality by                     Not set >    |
|                                                  |
| Notes                                            |
| +--------------------------------------------+   |
| | Optional notes                              |  |
| |                                            |   |
| +--------------------------------------------+   |
| 0 of 200 characters                             |
|                                                  |
| [ Review and write to tag ]                     |
|                                                  |
| Cancel                                           |
+--------------------------------------------------+
```

### 3.2 Primary UX notes

- The `Food name` field is the first task and should visually dominate the screen.
- The microphone affordance must remain visible, not hidden behind a keyboard menu.
- Food presets should wrap cleanly at large Dynamic Type sizes and may become stacked full-width buttons.
- `Date frozen` and `Best quality by` should be row-based controls, not tiny inline date widgets.
- `Notes` should appear clearly optional.

### 3.3 Empty-state component behavior

| Component | State | Behavior |
|---|---|---|
| Food name | Empty | Primary CTA disabled |
| Review button | Disabled | Announces why it is disabled |
| Best quality by | Empty | Shows `Not set` |
| Presets | None selected | No helper confirmation shown |
| Notes | Empty | Counter remains visible |

## 4. Screen A Variants

### 4.1 Preset selected

```text
+--------------------------------------------------+
| Step 1 of 2                                      |
| Add a container                                  |
|                                                  |
| Food name                                        |
| +--------------------------------------------+   |
| | Beef stew                                [Mic]| |
| +--------------------------------------------+   |
|                                                  |
| Choose a food type                               |
| This can add a suggested best-quality date.      |
|                                                  |
| [ Beef Selected ]   [ Poultry ]   [ Fish ]       |
| [ Prepared meal ]   [ Pastries ]                 |
| [ Vegetables ]   [ Other ]                       |
|                                                  |
| Suggested date based on USDA guidance            |
|                                                  |
| Date frozen                         Today   >    |
|                                                  |
| Best quality by                9 August 2026 >   |
|                                                  |
| Notes                                            |
| +--------------------------------------------+   |
| | Optional notes                              |  |
| +--------------------------------------------+   |
|                                                  |
| [ Review and write to tag ]                     |
|                                                  |
| Cancel                                           |
+--------------------------------------------------+
```

### 4.2 Validation error

```text
+--------------------------------------------------+
| Step 1 of 2                                      |
| Add a container                                  |
|                                                  |
| Food name                                        |
| +--------------------------------------------+   |
| |                                            |   |
| +--------------------------------------------+   |
| Enter a food name to continue                    |
|                                                  |
| Choose a food type                               |
| ...                                              |
|                                                  |
| [ Review and write to tag ]   disabled           |
+--------------------------------------------------+
```

### 4.3 Dictation active

```text
+--------------------------------------------------+
| Step 1 of 2                                      |
| Add a container                                  |
|                                                  |
| Food name                                        |
| +--------------------------------------------+   |
| | Beef stew                                [Mic]| |
| +--------------------------------------------+   |
| Listening for food name...                       |
|                                                  |
| Choose a food type                               |
| ... dimmed while keyboard/dictation is active    |
+--------------------------------------------------+
```

### 4.4 Large text fallback layout

```text
+--------------------------------------------------+
| Step 1 of 2                                      |
| Add a container                                  |
| Tell us what you are freezing.                   |
|                                                  |
| Food name                                        |
| +--------------------------------------------+   |
| | Example: Beef stew                           |  |
| +--------------------------------------------+   |
| [ Speak food name ]                             |
|                                                  |
| Choose a food type                               |
| [ Beef ]                                         |
| [ Poultry ]                                      |
| [ Fish ]                                         |
| [ Prepared meal ]                                |
| [ Pastries ]                                     |
| [ Vegetables ]                                   |
| [ Other ]                                        |
|                                                  |
| Date frozen                                      |
| [ Today                                 > ]      |
|                                                  |
| Best quality by                                  |
| [ Not set                               > ]      |
|                                                  |
| [ Review and write to tag ]                     |
| Cancel                                           |
+--------------------------------------------------+
```

## 5. Screen B - Review and Write

### 5.1 Default state

```text
+--------------------------------------------------+
| Back                                             |
|                                                  |
| Step 2 of 2                                      |
| Review and write                                 |
| Check these details, then hold your iPhone       |
| near the tag.                                    |
|                                                  |
| What will be saved                               |
| +--------------------------------------------+   |
| | Food name        Beef stew                  |  |
| | Food type        Beef                       |  |
| | Date frozen      Today                      |  |
| | Best quality by  9 August 2026              |  |
| | Notes            Family dinner leftovers    |  |
| +--------------------------------------------+   |
|                                                  |
| [ Write to tag ]                                 |
|                                                  |
| Go back and change                               |
+--------------------------------------------------+
```

### 5.2 UX notes

- The summary card should be glanceable, not dense.
- Values should line up clearly so the user can spot mistakes quickly.
- If notes are empty, omit the notes row entirely rather than showing an empty label.
- The primary CTA should stay pinned near the bottom when screen height allows.

### 5.3 No best-quality date variant

```text
+--------------------------------------------------+
| What will be saved                               |
| +--------------------------------------------+   |
| | Food name        Vegetable soup             |  |
| | Food type        Other                      |  |
| | Date frozen      Today                      |  |
| | Best quality by  Not set                    |  |
| +--------------------------------------------+   |
|                                                  |
| [ Write to tag ]                                 |
+--------------------------------------------------+
```

## 6. Screen C - Hold Your Phone Near the Tag

### 6.1 Writing companion state

```text
+--------------------------------------------------+
|                                                  |
| Hold your phone near the tag                     |
| Keep the top of your iPhone close to the         |
| container tag until you feel confirmation.       |
|                                                  |
|                [ phone illustration ]            |
|                     (( pulse ))                  |
|                [ container + tag ]               |
|                                                  |
|                Writing to tag...                 |
|                                                  |
| Cancel                                           |
+--------------------------------------------------+
```

### 6.2 UX notes

- This screen visually supports the Apple system NFC sheet rather than replacing it.
- Avoid clutter and avoid competing explanations.
- `Cancel` should only be shown if cancellation is available in the implementation.
- The pulse should be calm and steady, never frantic.

### 6.3 Reduce Motion variant

```text
+--------------------------------------------------+
| Hold your phone near the tag                     |
| Keep the top of your iPhone close to the         |
| container tag until you feel confirmation.       |
|                                                  |
|                [ phone illustration ]            |
|                [ container + tag ]               |
|                                                  |
|                Writing to tag...                 |
+--------------------------------------------------+
```

## 7. Screen D - Write Success

### 7.1 Default state

```text
+--------------------------------------------------+
|                                                  |
|               [ checkmark icon ]                 |
|                                                  |
| Saved to your container                          |
| Beef stew has been saved and the tag was         |
| updated.                                         |
|                                                  |
| +--------------------------------------------+   |
| | Food name        Beef stew                  |  |
| | Date frozen      Today                      |  |
| | Best quality by  9 August 2026              |  |
| +--------------------------------------------+   |
|                                                  |
| [ Done ]                                         |
|                                                  |
| [ Read details again ]                           |
|                                                  |
| Add another container                            |
+--------------------------------------------------+
```

### 7.2 UX notes

- The success state should remain stable for at least 4 seconds.
- The full summary card helps users with memory confidence and gives sighted reassurance.
- `Read details again` must be a normal visible button, not a hidden gesture or speaker icon only.
- `Add another container` should be visually tertiary.

### 7.3 Replay state

```text
+--------------------------------------------------+
| Saved to your container                          |
|                                                  |
| Reading saved details...                         |
|                                                  |
| [ Done ]                                         |
| [ Read details again ]                           |
+--------------------------------------------------+
```

## 8. Screen E - Write Failure

### 8.1 Default failure state

```text
+--------------------------------------------------+
|                                                  |
|              [ warning icon ]                    |
|                                                  |
| That did not save to the tag                     |
| Try holding your iPhone a little closer and      |
| keep it still.                                   |
|                                                  |
| [ Try again ]                                    |
|                                                  |
| Go back                                          |
|                                                  |
| What should I do?                                |
+--------------------------------------------------+
```

### 8.2 Expanded help sheet

```text
+--------------------------------------------------+
| Try these steps                                  |
|                                                  |
| - Hold the top of your iPhone near the tag.      |
| - Keep your phone still for a moment.            |
| - Move away other tagged containers nearby.      |
|                                                  |
| [ Try again ]                                    |
| Not now                                          |
+--------------------------------------------------+
```

### 8.3 UX notes

- The message should stay calm and never imply user blame.
- `Try again` must be immediately visible and dominant.
- `Go back` lets users recover without feeling trapped.

## 9. Settings Wireframes

### 9.1 Accessibility support section

```text
+--------------------------------------------------+
| Settings                                         |
|                                                  |
| Accessibility support                            |
| Spoken guidance                     [ On ]       |
| Spoken confirmations                [ On ]       |
| Haptics                             [ On ]       |
| Show microphone shortcut            [ On ]       |
|                                                  |
| Food expiry presets                              |
| Beef                                4 months  >  |
| Poultry                             9 months  >  |
| Fish                                4 months  >  |
| Prepared meal                       3 months  >  |
| Pastries                            2 months  >  |
| Vegetables                          8 months  >  |
| Other                               No date   >  |
+--------------------------------------------------+
```

### 9.2 Preset editor

```text
+--------------------------------------------------+
| Back                                             |
|                                                  |
| Beef preset                                      |
| Suggested best-quality date for this category.   |
|                                                  |
| Default time                                     |
| [ - ]       4 months       [ + ]                 |
|                                                  |
| Source                                           |
| USDA-style guidance and app default              |
|                                                  |
| [ Save ]                                         |
| Reset to app default                             |
+--------------------------------------------------+
```

## 10. Component Inventory

### 10.1 Text field - Food name

States:

- Empty
- Focused
- Filled
- Error
- Voice dictation active

Required content:

- Visible label
- Placeholder
- Required helper or error text
- Trailing microphone action

### 10.2 Preset card

States:

- Default
- Pressed
- Selected
- Selected then manually edited
- Disabled if ever used in a read-only mode

Required content:

- Preset name
- Optional selected indicator
- Never icon-only

### 10.3 Date row

States:

- Default with value
- Empty
- Auto-filled
- Manually edited

Required content:

- Label
- Value
- Chevron or explicit change affordance

### 10.4 Primary button

States:

- Enabled
- Pressed
- Disabled
- Busy if needed during transition

Required behavior:

- Clear spoken explanation when disabled
- Minimum 60 by 60 points

### 10.5 Spoken replay button

States:

- Default
- Pressed
- Replaying

Required behavior:

- Works with and without VoiceOver
- Stays visible after success

### 10.6 Confirmation card

Used on:

- Review screen
- Success screen

Required content:

- Key fields only
- Large readable values
- Stable layout at large text sizes

## 11. State Matrix

| Screen | State | Trigger | Expected response |
|---|---|---|---|
| Add | Empty | First open | Focus title or food field, CTA disabled |
| Add | Preset selected | User taps preset | Date auto-fills, spoken confirmation, light haptic |
| Add | Validation error | CTA tapped without name | Error text shown, spoken explanation |
| Add | Dictation | User taps mic | Listening state shown |
| Review | Default | CTA from add screen | Summary card visible, write CTA enabled |
| Write | In progress | User taps `Write to tag` | NFC system sheet appears, pulse shown |
| Write | Success | Tag updated | Success haptic, short spoken confirmation, success screen |
| Write | Failure | Write error | Error haptic, retry state with recovery copy |
| Success | Replay | User taps `Read details again` | Full summary spoken aloud |

## 12. Engineering Notes

- The wireframes assume SwiftUI layouts that can reflow vertically at large Dynamic Type sizes.
- The microphone action should use the system speech input path already available on iOS where possible.
- Spoken guidance should avoid overlapping with VoiceOver speech.
- Success and failure screens should remain usable even if haptics and spoken feedback are both disabled.

## 13. Handoff Checklist

- Copy matches the UX spec exactly or intentionally with a documented change
- Every interactive control has a visible label
- VoiceOver order matches the top-to-bottom layout
- Large-text layout is considered for every screen
- Success state lingers long enough for reassurance
- Failure recovery is visible and simple
- Settings include editable preset defaults
