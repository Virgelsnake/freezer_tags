# Freezer Tag GS1 Evidence Mode

This implementation adds a second app mode for a market-facing evidence demo while preserving the domestic freezer container PoC.

## Simulator-verifiable script

1. Open **GS1 Evidence Mode** from the home screen.
2. Create a manual product/item record, or load the demo record.
3. Review validation warnings for missing or malformed GS1-style fields.
4. Enter an operator, device label, status, location note, and required check note.
5. Use **Simulate scan and save check**.
6. Generate CSV or JSON evidence text.

The simulator path creates an app-record pointer payload and a simulated tag ID. It is deliberately labelled as a simulator/demo path.

## What this proves

- The app can hold a GS1-style product/item record shape.
- The app warns when recommended evidence fields are missing.
- The app can create a local tag-link record for a selected item.
- The app can create a check event with a copied item snapshot, payload hash, event hash, check note, operator/device fields, and proof-limit version.
- CSV and JSON export generation are deterministic and unit-tested.

## What this does not prove

This mode does not prove formal GS1 certification, legal compliance, food-safety compliance, tamper-proof chain of custody, or that a tag was never moved between items.

Proof-limit wording shown in the app and included in export:

> This evidence shows that this device scanned this NFC tag and recorded this check note at this time using the data stored in this app. It does not prove the food itself was safe, that the tag was never moved, that the operator performed the check correctly, or that the record meets every legal or GS1 compliance requirement.

## NFC and tag placement boundary

Steve has physically confirmed the existing domestic PoC NFC cards work, including through the container. This GS1 Evidence Mode slice does not yet write or read GS1-style payloads through the physical NFC path.

The current generic Amazon PVC NFC cards should be treated as PoC/dev tags only. Do not treat them as customer-facing food-contact tags unless suitable food-contact documentation is obtained. For demos and commercial notes, prefer external tag placement.

## Deferred scope

- CSV/JSON document import.
- Physical NFC write/read integration for GS1 evidence payloads.
- Native share-sheet file export.
- Core Data migration for evidence records.
- Tag lifecycle actions beyond the simulator link.
- Hash-chain review UI and stronger tamper-evidence.
- Backend identity, cloud sync, or regulatory reporting.
