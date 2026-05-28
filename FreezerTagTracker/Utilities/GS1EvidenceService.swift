import CryptoKit
import Foundation

enum GS1EvidenceError: LocalizedError, Equatable {
    case missingProductName
    case missingCheckNote
    case missingRecord

    var errorDescription: String? {
        switch self {
        case .missingProductName:
            return "Product name is required."
        case .missingCheckNote:
            return "A check note is required before an evidence event can be saved."
        case .missingRecord:
            return "Create or select a product/item record first."
        }
    }
}

enum GS1EvidenceProofLimit {
    static let version = "gs1-evidence-proof-limit-v1"

    static let text = "This evidence shows that this device scanned this NFC tag and recorded this check note at this time using the data stored in this app. It does not prove the food itself was safe, that the tag was never moved, that the operator performed the check correctly, or that the record meets every legal or GS1 compliance requirement."
}

enum GS1EvidenceValidator {
    static func validate(record: GS1ProductItemRecord) -> [GS1EvidenceWarning] {
        var warnings: [GS1EvidenceWarning] = []

        if record.productName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            warnings.append(.init(
                id: "missing_product_name",
                severity: .required,
                message: "Product name is required for a useful item record."
            ))
        }

        let gtin = record.gtin.trimmingCharacters(in: .whitespacesAndNewlines)
        if !gtin.isEmpty && !isValidGTIN(gtin) {
            warnings.append(.init(
                id: "malformed_gtin",
                severity: .caution,
                message: "GTIN appears malformed. Keep the supplied value, but verify it before using this as GS1-style evidence."
            ))
        }

        if record.batchOrLot.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            warnings.append(.init(
                id: "missing_batch_or_lot",
                severity: .recommended,
                message: "Batch/lot is recommended for operational evidence."
            ))
        }

        if record.expiryOrUseByDate.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            warnings.append(.init(
                id: "missing_expiry_or_use_by_date",
                severity: .recommended,
                message: "Expiry/use-by date is strongly recommended for perishable food evidence."
            ))
        }

        if record.storageInstruction.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            warnings.append(.init(
                id: "missing_storage_instruction",
                severity: .recommended,
                message: "Storage instruction is recommended so the evidence line carries handling context."
            ))
        }

        return warnings
    }

    static func isValidGTIN(_ value: String) -> Bool {
        let digits = value.filter(\.isNumber)
        guard digits == value, [8, 12, 13, 14].contains(digits.count) else {
            return false
        }

        let numbers = digits.compactMap { Int(String($0)) }
        guard numbers.count == digits.count, let checkDigit = numbers.last else {
            return false
        }

        let body = numbers.dropLast().reversed()
        let sum = body.enumerated().reduce(0) { partial, item in
            let multiplier = item.offset.isMultiple(of: 2) ? 3 : 1
            return partial + item.element * multiplier
        }
        let calculated = (10 - (sum % 10)) % 10
        return calculated == checkDigit
    }
}

enum GS1EvidenceService {
    static func makeDemoRecord(now: Date = Date()) -> GS1ProductItemRecord {
        GS1ProductItemRecord(
            gtin: "05012345678900",
            productName: "Demo frozen meal",
            brandOrSupplier: "Demo supplier",
            batchOrLot: "LOT-2026-05",
            serialOrItemID: "ITEM-0001",
            expiryOrUseByDate: "2026-12-31",
            packedOrFrozenDate: "2026-05-28",
            quantityOrPackSize: "1 tray",
            storageState: .frozen,
            storageInstruction: "Keep frozen. Demo data only.",
            allergenSummary: "Only if supplied by operator",
            sourceFileName: "manual-demo",
            sourceImportedAt: now,
            sourceHash: sha256("manual-demo-\(now.timeIntervalSince1970)"),
            createdAt: now,
            updatedAt: now
        )
    }

    static func makePointerPayload(recordID: UUID) -> String {
        "freezer-tag://gs1-record/\(recordID.uuidString)"
    }

    static func makeSimulatorTagLink(
        record: GS1ProductItemRecord,
        operatorName: String,
        now: Date = Date()
    ) -> GS1TagLinkRecord {
        GS1TagLinkRecord(
            tagID: "SIM-GS1-\(record.id.uuidString.prefix(8))",
            ndefPayload: makePointerPayload(recordID: record.id),
            payloadType: .appRecordPointer,
            recordID: record.id,
            linkedAt: now,
            linkedBy: cleaned(operatorName, fallback: "Local operator"),
            tagStatus: .active,
            placementNote: "Simulator/demo path. For physical demos, prefer external tag placement unless food-contact documentation exists."
        )
    }

    static func makeCheckEvent(
        record: GS1ProductItemRecord,
        tagLink: GS1TagLinkRecord,
        checkNote: String,
        checkStatus: GS1CheckStatus,
        operatorName: String,
        deviceLabel: String,
        locationNote: String,
        previousEventHash: String? = nil,
        now: Date = Date()
    ) throws -> GS1EvidenceEvent {
        let trimmedNote = checkNote.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedNote.isEmpty else {
            throw GS1EvidenceError.missingCheckNote
        }

        let payloadHash = sha256(tagLink.ndefPayload)
        let warnings = record.validationWarnings.map(\.message)
        let eventSeed = [
            now.iso8601EvidenceString,
            tagLink.tagID,
            record.id.uuidString,
            record.gtin,
            record.batchOrLot,
            record.serialOrItemID,
            trimmedNote,
            checkStatus.rawValue,
            payloadHash,
            previousEventHash ?? ""
        ].joined(separator: "|")

        return GS1EvidenceEvent(
            id: UUID(),
            eventType: .check,
            eventTimestamp: now,
            operatorName: cleaned(operatorName, fallback: "Local operator"),
            deviceLabel: cleaned(deviceLabel, fallback: "This device"),
            tagID: tagLink.tagID,
            recordID: record.id,
            gtin: record.gtin,
            productName: record.productName,
            batchOrLot: record.batchOrLot,
            serialOrItemID: record.serialOrItemID,
            expiryOrUseByDate: record.expiryOrUseByDate,
            checkNote: trimmedNote,
            checkStatus: checkStatus,
            locationNote: locationNote.trimmingCharacters(in: .whitespacesAndNewlines),
            payloadRead: tagLink.ndefPayload,
            payloadHash: payloadHash,
            previousEventHash: previousEventHash,
            eventHash: sha256(eventSeed),
            proofLimitVersion: GS1EvidenceProofLimit.version,
            warningMessages: warnings
        )
    }

    static func sha256(_ value: String) -> String {
        let digest = SHA256.hash(data: Data(value.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    private static func cleaned(_ value: String, fallback: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? fallback : trimmed
    }
}

enum GS1EvidenceExportGenerator {
    static func makeJSON(events: [GS1EvidenceEvent]) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .custom { date, encoder in
            var container = encoder.singleValueContainer()
            try container.encode(date.iso8601EvidenceString)
        }
        let data = try encoder.encode(events)
        return String(data: data, encoding: .utf8) ?? "[]"
    }

    static func makeCSV(events: [GS1EvidenceEvent]) -> String {
        let header = [
            "event_id",
            "event_type",
            "event_timestamp",
            "operator_name",
            "device_label",
            "tag_id",
            "record_id",
            "gtin",
            "product_name",
            "batch_or_lot",
            "serial_or_item_id",
            "expiry_or_use_by_date",
            "check_status",
            "check_note",
            "location_note",
            "payload_read",
            "payload_hash",
            "event_hash",
            "proof_limit_version",
            "proof_limit",
            "warnings"
        ]

        let rows = events.map { event in
            [
                event.id.uuidString,
                event.eventType.rawValue,
                event.eventTimestamp.iso8601EvidenceString,
                event.operatorName,
                event.deviceLabel,
                event.tagID,
                event.recordID.uuidString,
                event.gtin,
                event.productName,
                event.batchOrLot,
                event.serialOrItemID,
                event.expiryOrUseByDate,
                event.checkStatus.rawValue,
                event.checkNote,
                event.locationNote,
                event.payloadRead,
                event.payloadHash,
                event.eventHash,
                event.proofLimitVersion,
                GS1EvidenceProofLimit.text,
                event.warningMessages.joined(separator: " | ")
            ].map(csvEscape).joined(separator: ",")
        }

        return ([header.joined(separator: ",")] + rows).joined(separator: "\n")
    }

    private static func csvEscape(_ value: String) -> String {
        if value.contains(",") || value.contains("\"") || value.contains("\n") {
            return "\"\(value.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return value
    }
}

private extension Date {
    var iso8601EvidenceString: String {
        ISO8601DateFormatter.evidenceFormatter.string(from: self)
    }
}

private extension ISO8601DateFormatter {
    static let evidenceFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
}
