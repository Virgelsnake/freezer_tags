import Foundation

enum GS1StorageState: String, Codable, CaseIterable, Identifiable {
    case ambient
    case chilled
    case frozen
    case unknown

    var id: String { rawValue }
}

enum GS1PayloadType: String, Codable {
    case gs1DigitalLink = "gs1_digital_link"
    case appRecordPointer = "app_record_pointer"
    case plainJSONDemo = "plain_json_demo"
}

enum GS1TagStatus: String, Codable {
    case active
    case replaced
    case cleared
    case retired
    case unknown
}

enum GS1EvidenceEventType: String, Codable {
    case check
    case write
    case update
    case clear
    case export
    case exception
}

enum GS1CheckStatus: String, Codable, CaseIterable, Identifiable {
    case pass
    case concern
    case fail
    case noteOnly = "note_only"

    var id: String { rawValue }
}

enum GS1EvidenceWarningSeverity: String, Codable {
    case required
    case recommended
    case caution
}

struct GS1EvidenceWarning: Codable, Equatable, Identifiable {
    let id: String
    let severity: GS1EvidenceWarningSeverity
    let message: String

    init(id: String, severity: GS1EvidenceWarningSeverity, message: String) {
        self.id = id
        self.severity = severity
        self.message = message
    }
}

struct GS1ProductItemRecord: Identifiable, Codable, Equatable {
    let id: UUID
    var gtin: String
    var productName: String
    var brandOrSupplier: String
    var batchOrLot: String
    var serialOrItemID: String
    var expiryOrUseByDate: String
    var packedOrFrozenDate: String
    var quantityOrPackSize: String
    var storageState: GS1StorageState
    var storageInstruction: String
    var allergenSummary: String
    var sourceFileName: String?
    var sourceImportedAt: Date?
    var sourceHash: String?
    let createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        gtin: String = "",
        productName: String,
        brandOrSupplier: String = "",
        batchOrLot: String = "",
        serialOrItemID: String = "",
        expiryOrUseByDate: String = "",
        packedOrFrozenDate: String = "",
        quantityOrPackSize: String = "",
        storageState: GS1StorageState = .unknown,
        storageInstruction: String = "",
        allergenSummary: String = "",
        sourceFileName: String? = nil,
        sourceImportedAt: Date? = nil,
        sourceHash: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.gtin = gtin
        self.productName = productName
        self.brandOrSupplier = brandOrSupplier
        self.batchOrLot = batchOrLot
        self.serialOrItemID = serialOrItemID
        self.expiryOrUseByDate = expiryOrUseByDate
        self.packedOrFrozenDate = packedOrFrozenDate
        self.quantityOrPackSize = quantityOrPackSize
        self.storageState = storageState
        self.storageInstruction = storageInstruction
        self.allergenSummary = allergenSummary
        self.sourceFileName = sourceFileName
        self.sourceImportedAt = sourceImportedAt
        self.sourceHash = sourceHash
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var validationWarnings: [GS1EvidenceWarning] {
        GS1EvidenceValidator.validate(record: self)
    }
}

struct GS1TagLinkRecord: Identifiable, Codable, Equatable {
    var id: String { tagID }
    let tagID: String
    let ndefPayload: String
    let payloadType: GS1PayloadType
    let recordID: UUID
    let linkedAt: Date
    let linkedBy: String
    var tagStatus: GS1TagStatus
    var placementNote: String
}

struct GS1EvidenceEvent: Identifiable, Codable, Equatable {
    let id: UUID
    let eventType: GS1EvidenceEventType
    let eventTimestamp: Date
    let operatorName: String
    let deviceLabel: String
    let tagID: String
    let recordID: UUID
    let gtin: String
    let productName: String
    let batchOrLot: String
    let serialOrItemID: String
    let expiryOrUseByDate: String
    let checkNote: String
    let checkStatus: GS1CheckStatus
    let locationNote: String
    let payloadRead: String
    let payloadHash: String
    let previousEventHash: String?
    let eventHash: String
    let proofLimitVersion: String
    let warningMessages: [String]
}
