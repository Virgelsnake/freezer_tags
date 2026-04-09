# Freezer Tag Tracker - Add Container UX Spec

**Date:** 9 April 2026
**Related brief:** [design-brief-mobile-ui.md](/Users/steveshearman/xcode_projects/freezer_tag_poc/docs/design-brief-mobile-ui.md)
**Scope:** Add details -> review -> write to tag
**Decision status:** Agreed direction based on product discussion

## 1. Agreed Product Decisions

- Use USDA-style freezer guidance as the default source for best-quality dates.
- Use a 2-step add flow: `Add details` -> `Review and write`.
- Turn spoken guidance and spoken confirmations on by default.
- Keep system accessibility features automatic and system-driven.
- Expose app-owned assistance features in Settings.
- Ship fixed food presets with the option for users to edit them in Settings.
- Keep the default success message short and offer a `Read details again` action.

## 2. UX Goal

This flow should feel less like filling in a form and more like being gently guided through a task. The user should always know:

- what this screen is for
- what to do next
- what was just saved
- whether the tag was updated successfully

The flow must work well for:

- blind and low-vision users using VoiceOver
- older adults with reduced dexterity or memory confidence
- users who prefer dictation over typing
- sighted mainstream users who simply want a fast, low-friction experience

## 3. Core UX Principles

### 3.1 Reduce effort before reducing time

The flow should minimize typing, decision load, and memory burden before optimizing raw speed.

### 3.2 Give feedback in more than one channel

Important moments should be confirmed through:

- visible text
- clear iconography
- haptics
- spoken feedback

### 3.3 Keep the next action obvious

Each screen should have one dominant primary action and no more than one meaningful secondary action.

### 3.4 Speak plainly

Do not expose technical terms such as `NFC`, `NDEF`, or `write session` in user-facing copy.

Preferred language:

- `tag`
- `container`
- `save`
- `write to tag`
- `try again`

Avoid:

- `payload`
- `encode`
- `scan state`
- `read/write mode`

### 3.5 Treat dates as quality guidance

USDA freezer times are quality guidance, not hard safety cutoffs. User-facing language should say `Best quality by` rather than implying that food becomes unsafe on that date.

## 4. Flow Overview

### 4.1 Step sequence

1. User opens `Add a container`.
2. User enters or dictates the food name.
3. User optionally taps a food preset to auto-fill a `Best quality by` date.
4. User reviews simple details and taps `Review and write to tag`.
5. User lands on a summary screen and taps `Write to tag`.
6. App launches the Apple NFC system sheet.
7. User holds phone near the tag.
8. App shows a success or retry state with visible, spoken, and haptic confirmation.

### 4.2 Primary user promise

`Tell us what you are freezing, then we will help you save it to the container tag.`

## 5. Screen Spec

## 5.1 Screen A - Add a container

### Purpose

Collect the minimum information needed to save a new freezer record with as little typing and recall effort as possible.

### Heading and helper copy

- Title: `Add a container`
- Intro text: `Tell us what you are freezing, then we will help you write it to the tag.`

### Layout

Top to bottom:

1. Progress label: `Step 1 of 2`
2. Screen title and helper text
3. Food name field
4. Microphone action
5. Food type presets
6. Date frozen row
7. Best quality by row
8. Notes field
9. Primary button
10. Secondary text button

### Controls and exact copy

#### Food name

- Label: `Food name`
- Placeholder: `Example: Beef stew`
- Assistive hint text below field: `Required`

#### Microphone action

- Button label: `Speak food name`
- Icon: `mic.fill`
- Placement: trailing edge of the food name field or directly below it as a full-width secondary button at large Dynamic Type sizes

#### Food type presets

- Section label: `Choose a food type`
- Helper text: `This can add a suggested best-quality date.`

Default preset chips/cards:

- `Beef`
- `Poultry`
- `Fish`
- `Prepared meal`
- `Pastries`
- `Vegetables`
- `Other`

Selected state copy:

- Inline supporting text: `Best-quality date added from USDA guidance.`

#### Date frozen

- Row label: `Date frozen`
- Default value: `Today`
- Edit action label: `Change`

#### Best quality by

- Row label when empty: `Best quality by`
- Empty state value: `Not set`
- Auto-filled state label example: `Best quality by 12 October 2026`
- Edit action label: `Change`
- Remove action label: `Remove date`

#### Notes

- Label: `Notes`
- Placeholder: `Optional notes`
- Character helper: `0 of 200 characters`

#### Primary CTA

- Button label: `Review and write to tag`

#### Secondary action

- Text button label: `Cancel`

### Interaction behavior

- `Food name` is the first responder when the screen opens unless VoiceOver focus should land on the title first.
- If the user taps a preset before entering a name, that is allowed. The preset should still fill the date.
- If a preset is selected and the user edits the date manually, the preset remains selected but the helper text changes to `Date changed`.
- If the user has not entered a food name, the primary CTA remains disabled.
- Disabled button spoken explanation: `Food name is required.`

### Spoken guidance

When spoken guidance is on and VoiceOver is off:

- On entry: `Add a container. Tell us what you are freezing.`
- On preset selection: `Beef selected. Best-quality date added.`
- On microphone tap: `Listening for food name.`
- On validation error: `Food name is required before you can continue.`

When VoiceOver is on:

- Use accessibility announcements for screen arrival and validation changes.
- Do not layer custom speech on top of VoiceOver speech.

### VoiceOver labels and hints

- Food name field:
  - Label: `Food name`
  - Value: current text or `Empty`
  - Hint: `Required text field. Double tap to type or use dictation.`
- Speak food name button:
  - Label: `Speak food name`
  - Hint: `Double tap to dictate the name of the food.`
- Preset card example:
  - Label: `Beef`
  - Value when selected: `Selected`
  - Hint: `Adds a suggested best-quality date based on USDA guidance.`
- Date frozen row:
  - Label: `Date frozen`
  - Value: `Today` or chosen date
  - Hint: `Double tap to change the frozen date.`
- Best quality row:
  - Label: `Best quality by`
  - Value: chosen date or `Not set`
  - Hint: `Double tap to change the suggested date.`
- Notes field:
  - Label: `Notes`
  - Value: current text or `Empty`
  - Hint: `Optional text field, maximum 200 characters.`
- Primary button:
  - Label: `Review and write to tag`
  - Hint when enabled: `Moves to the final review screen before writing to the tag.`
  - Hint when disabled: `Disabled. Food name is required.`

### Focus order

1. Step 1 of 2
2. Add a container
3. Intro text
4. Food name
5. Speak food name
6. Choose a food type
7. Food type options in reading order
8. Date frozen
9. Best quality by
10. Notes
11. Review and write to tag
12. Cancel

## 5.2 Screen B - Review and write

### Purpose

Give the user one calm review moment before the tag is updated.

### Heading and helper copy

- Progress label: `Step 2 of 2`
- Title: `Review and write`
- Intro text: `Check these details, then hold your iPhone near the tag.`

### Summary card content

- Food name
- Food type
- Date frozen
- Best quality by
- Notes only if present

### Exact copy

- Summary heading: `What will be saved`
- Primary CTA: `Write to tag`
- Secondary CTA: `Go back and change`

### Spoken guidance

When spoken guidance is on and VoiceOver is off:

- On entry: `Review and write. Check the details, then write them to the tag.`

When the user taps `Write to tag`:

- `Hold the top of your iPhone near the tag on your container.`

### VoiceOver labels and hints

- Summary card:
  - Label: `What will be saved`
  - Value: concatenated summary of fields
  - Hint: `Review the saved details before writing to the tag.`
- Write to tag button:
  - Label: `Write to tag`
  - Hint: `Starts the tag writing step.`
- Go back and change button:
  - Label: `Go back and change`
  - Hint: `Returns to the previous screen to edit the details.`

### Focus order

1. Step 2 of 2
2. Review and write
3. Intro text
4. What will be saved
5. Write to tag
6. Go back and change

## 5.3 Screen C - Writing companion state

### Purpose

Support the Apple NFC system sheet with matching in-app guidance before and after the system overlay appears.

### Visible content behind the Apple system sheet

- Title: `Hold your phone near the tag`
- Helper text: `Keep the top of your iPhone close to the container tag until you feel confirmation.`
- Simple illustration: phone near tag
- Progress indicator: gentle pulse

### Motion

- Default: slow pulse around phone illustration every 1.2 seconds
- Reduce Motion: static illustration with a subtle opacity change or no motion

### Spoken guidance

- At session start: `Ready to write. Hold your iPhone near the tag.`
- On tag detection: no long sentence; use a brief cue only if VoiceOver is off

### Failure prevention note

Do not show extra controls here other than a passive `Cancel` affordance if supported by the current implementation. Keep the state visually quiet.

## 5.4 Screen D - Write success

### Purpose

Deliver a visible and audible confirmation that the record was saved and the tag was updated.

### Required behavior

- Stay on screen for at least 4 seconds before any automatic dismissal.
- Do not navigate away immediately.
- Make the success state feel conclusive and reassuring.

### Exact copy

- Title: `Saved to your container`
- Body: `[Food name] has been saved and the tag was updated.`
- Primary CTA: `Done`
- Secondary CTA: `Read details again`
- Optional tertiary text link: `Add another container`

### Spoken confirmation

Default short message:

- `Saved. Tag updated.`

Full replay message when `Read details again` is tapped:

- `[Food name]. Frozen [date frozen]. Best quality by [date]. Tag updated successfully.`

If no best-quality date is set:

- `[Food name]. Frozen [date frozen]. No best-quality date saved. Tag updated successfully.`

### VoiceOver labels and hints

- Success title:
  - Label: `Saved to your container`
- Body:
  - Label: full visible sentence
- Done button:
  - Label: `Done`
  - Hint: `Returns to the home screen.`
- Read details again button:
  - Label: `Read details again`
  - Hint: `Speaks the saved container details aloud.`

## 5.5 Screen E - Write failure

### Purpose

Help the user recover without blame or technical jargon.

### Exact copy

- Title: `That did not save to the tag`
- Body: `Try holding your iPhone a little closer and keep it still.`
- Primary CTA: `Try again`
- Secondary CTA: `Go back`
- Help text button: `What should I do?`

Expanded help sheet copy:

- Title: `Try these steps`
- Bullets:
  - `Hold the top of your iPhone near the tag.`
  - `Keep your phone still for a moment.`
  - `Move away other tagged containers if they are nearby.`

### Spoken confirmation

- Failure message: `The tag was not updated. Try holding your phone a little closer and keep it still.`

### VoiceOver labels and hints

- Try again button:
  - Label: `Try again`
  - Hint: `Starts the tag writing step again.`
- Go back button:
  - Label: `Go back`
  - Hint: `Returns to the review screen.`

## 6. USDA Preset Model

These presets should be presented as recommended `best quality by` defaults. They should remain editable by the user.

| Preset | Default rule | Notes |
|---|---|---|
| Beef | 4 months | Conservative default aligned to USDA guidance for uncooked ground/stew meat; user-editable |
| Poultry | 9 months | Default aligned to uncooked poultry parts; whole poultry may last longer |
| Fish | 4 months | Conservative default based on USDA/FSIS catfish guidance; broad seafood variation means this should stay editable |
| Prepared meal | 3 months | Based on USDA guidance for leftovers, casseroles, soups, and stews |
| Pastries | 2 months | Conservative inferred default based on USDA guidance for pies and similar baked filled products; mark as editable |
| Vegetables | 8 months | Product decision default; not directly covered in the cited USDA meat/poultry sources, so this should be clearly editable in Settings |
| Other | No automatic date | Avoid false precision when the category is too broad |

### Preset disclosure text

On the add screen:

- `Suggested date based on USDA guidance`

In Settings:

- `These dates are suggested for best quality and can be changed.`

## 7. Haptic Map

| Moment | Haptic intent | Recommended feel |
|---|---|---|
| Tap on primary button | Confirm action received | Light impact |
| Tap on preset | Confirm selection | Light impact |
| Start writing flow | Signal transition into tag-writing mode | Soft notification or medium impact |
| Tag detected | Distinct recognition moment | Short double pulse |
| Write success | Strong confirmation | Success notification haptic |
| Write failure | Clear but calm warning | Error notification haptic |
| Validation error | Gentle correction | Light warning tap, not harsh |
| Read details again tapped | Acknowledge replay action | Light impact |

### Haptic rules

- Haptics must be individually toggleable in Settings.
- Haptics should never be the only source of meaning.
- Haptic patterns for `detected`, `success`, and `failure` must be easy to distinguish.

## 8. Spoken Copy Matrix

| Moment | Default spoken copy |
|---|---|
| Enter add screen | `Add a container. Tell us what you are freezing.` |
| Preset selected | `[Preset] selected. Best-quality date added.` |
| Validation error | `Food name is required before you can continue.` |
| Enter review screen | `Review and write. Check the details, then write them to the tag.` |
| Start write | `Ready to write. Hold your iPhone near the tag.` |
| Success | `Saved. Tag updated.` |
| Replay details | `[Food name]. Frozen [date]. Best quality by [date]. Tag updated successfully.` |
| Failure | `The tag was not updated. Try holding your phone a little closer and keep it still.` |

### Speech rules

- If VoiceOver is active, use accessibility announcements and do not duplicate the same message with app speech.
- If Spoken Confirmations is off, keep only the visible confirmation and haptic feedback.
- If both Spoken Guidance and Haptics are off, the UI must still be fully understandable visually.

## 9. iOS Accessibility Features To Explicitly Support

The app should support these iOS capabilities without requiring users to discover workarounds:

- VoiceOver
- Dictation
- Voice Control
- Switch Control
- Dynamic Type up to Accessibility XXL
- Bold Text
- Increase Contrast
- Differentiate Without Color
- Reduce Motion
- Full Keyboard Access where relevant

### Product behavior notes

- The microphone shortcut is an app convenience; users can also use system dictation from the keyboard.
- `Read details again` should remain accessible as a normal button, not a custom hidden gesture.
- Any icon-only affordance must also have visible text.
- All interactive elements must remain at least 60 by 60 points.

## 10. Settings Additions Required

The original brief marked Settings as out of scope. This flow now requires a lightweight Settings screen or Settings section containing:

- `Spoken guidance` toggle, default `On`
- `Spoken confirmations` toggle, default `On`
- `Haptics` toggle, default `On`
- `Show microphone shortcut` toggle, default `On`
- `Food expiry presets` editor

### Preset editor requirements

- Users can change the default month count for each preset.
- Users can reset presets to app defaults.
- The app should describe presets as `best-quality suggestions`.
- `Other` should remain available even if other presets are customized.

## 11. Open Design Risks

- `Fish` is too broad for one universal USDA rule. If seafood becomes a major use case, split it into `Lean fish`, `Fatty fish`, and `Shellfish`.
- `Pastries` is also broad. The default should be conservative and clearly editable.
- `Vegetables` is not strongly supported by the current USDA sources reviewed for this phase, so the product should avoid overclaiming authority there.
- The Apple NFC system sheet cannot be customized, so the in-app writing companion state must be designed to work around that system interruption rather than replace it.

## 12. Source Notes

This spec uses official USDA FSIS material as the primary source for freezer-quality guidance, especially:

- FSIS `Freezing and Food Safety`
- FSIS `Keep Food Safe! Food Safety Basics`
- FSIS `Safe Handling of Take-Out Foods`
- FSIS `Catfish From Farm to Table`

Where a preset is inferred rather than directly mapped from an official USDA category, the spec marks it as conservative and editable.
