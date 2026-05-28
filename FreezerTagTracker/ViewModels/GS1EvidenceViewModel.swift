import Foundation

final class GS1EvidenceViewModel: ObservableObject {
    @Published var records: [GS1ProductItemRecord]
    @Published var tagLinks: [GS1TagLinkRecord]
    @Published var events: [GS1EvidenceEvent]
    @Published var selectedRecordID: UUID?
    @Published var errorMessage: String?
    @Published var exportText: String = ""

    @Published var gtin: String = ""
    @Published var productName: String = ""
    @Published var brandOrSupplier: String = ""
    @Published var batchOrLot: String = ""
    @Published var serialOrItemID: String = ""
    @Published var expiryOrUseByDate: String = ""
    @Published var packedOrFrozenDate: String = ""
    @Published var quantityOrPackSize: String = ""
    @Published var storageState: GS1StorageState = .frozen
    @Published var storageInstruction: String = ""
    @Published var allergenSummary: String = ""

    @Published var operatorName: String = "Local operator"
    @Published var deviceLabel: String = "Simulator device"
    @Published var checkStatus: GS1CheckStatus = .noteOnly
    @Published var checkNote: String = ""
    @Published var locationNote: String = ""

    private let store: GS1EvidenceStoring

    init(store: GS1EvidenceStoring = GS1EvidenceUserDefaultsStore()) {
        self.store = store
        records = store.loadRecords()
        tagLinks = store.loadTagLinks()
        events = store.loadEvents()
        selectedRecordID = records.first?.id
    }

    var selectedRecord: GS1ProductItemRecord? {
        guard let selectedRecordID else { return records.first }
        return records.first { $0.id == selectedRecordID }
    }

    var selectedTagLink: GS1TagLinkRecord? {
        guard let selectedRecord else { return nil }
        return tagLinks.first { $0.recordID == selectedRecord.id && $0.tagStatus == .active }
    }

    var selectedRecordWarnings: [GS1EvidenceWarning] {
        selectedRecord?.validationWarnings ?? []
    }

    func saveManualRecord() {
        let trimmedName = productName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            errorMessage = GS1EvidenceError.missingProductName.localizedDescription
            return
        }

        let record = GS1ProductItemRecord(
            gtin: gtin,
            productName: trimmedName,
            brandOrSupplier: brandOrSupplier,
            batchOrLot: batchOrLot,
            serialOrItemID: serialOrItemID,
            expiryOrUseByDate: expiryOrUseByDate,
            packedOrFrozenDate: packedOrFrozenDate,
            quantityOrPackSize: quantityOrPackSize,
            storageState: storageState,
            storageInstruction: storageInstruction,
            allergenSummary: allergenSummary,
            sourceFileName: "manual-entry",
            sourceImportedAt: Date()
        )
        upsert(record: record)
        clearManualFields(keepOperatorFields: true)
        errorMessage = nil
    }

    func loadDemoRecord() {
        upsert(record: GS1EvidenceService.makeDemoRecord())
        errorMessage = nil
    }

    func simulateScanAndSaveCheck() {
        guard let record = selectedRecord else {
            errorMessage = GS1EvidenceError.missingRecord.localizedDescription
            return
        }

        let link = selectedTagLink ?? GS1EvidenceService.makeSimulatorTagLink(
            record: record,
            operatorName: operatorName
        )
        if selectedTagLink == nil {
            tagLinks.append(link)
            store.saveTagLinks(tagLinks)
        }

        do {
            let event = try GS1EvidenceService.makeCheckEvent(
                record: record,
                tagLink: link,
                checkNote: checkNote,
                checkStatus: checkStatus,
                operatorName: operatorName,
                deviceLabel: deviceLabel,
                locationNote: locationNote,
                previousEventHash: events.last?.eventHash
            )
            events.insert(event, at: 0)
            store.saveEvents(events)
            checkNote = ""
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func generateCSVExport() {
        exportText = GS1EvidenceExportGenerator.makeCSV(events: events)
    }

    func generateJSONExport() {
        do {
            exportText = try GS1EvidenceExportGenerator.makeJSON(events: events)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func upsert(record: GS1ProductItemRecord) {
        if let index = records.firstIndex(where: { $0.id == record.id }) {
            records[index] = record
        } else {
            records.insert(record, at: 0)
        }
        selectedRecordID = record.id
        store.saveRecords(records)
    }

    private func clearManualFields(keepOperatorFields: Bool) {
        gtin = ""
        productName = ""
        brandOrSupplier = ""
        batchOrLot = ""
        serialOrItemID = ""
        expiryOrUseByDate = ""
        packedOrFrozenDate = ""
        quantityOrPackSize = ""
        storageState = .frozen
        storageInstruction = ""
        allergenSummary = ""
        if !keepOperatorFields {
            operatorName = "Local operator"
            deviceLabel = "Simulator device"
        }
    }
}

protocol GS1EvidenceStoring {
    func loadRecords() -> [GS1ProductItemRecord]
    func saveRecords(_ records: [GS1ProductItemRecord])
    func loadTagLinks() -> [GS1TagLinkRecord]
    func saveTagLinks(_ links: [GS1TagLinkRecord])
    func loadEvents() -> [GS1EvidenceEvent]
    func saveEvents(_ events: [GS1EvidenceEvent])
}

final class GS1EvidenceUserDefaultsStore: GS1EvidenceStoring {
    private let defaults: UserDefaults
    private let recordsKey = "gs1Evidence.records.v1"
    private let tagLinksKey = "gs1Evidence.tagLinks.v1"
    private let eventsKey = "gs1Evidence.events.v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadRecords() -> [GS1ProductItemRecord] {
        loadArray(key: recordsKey)
    }

    func saveRecords(_ records: [GS1ProductItemRecord]) {
        save(records, key: recordsKey)
    }

    func loadTagLinks() -> [GS1TagLinkRecord] {
        loadArray(key: tagLinksKey)
    }

    func saveTagLinks(_ links: [GS1TagLinkRecord]) {
        save(links, key: tagLinksKey)
    }

    func loadEvents() -> [GS1EvidenceEvent] {
        loadArray(key: eventsKey)
    }

    func saveEvents(_ events: [GS1EvidenceEvent]) {
        save(events, key: eventsKey)
    }

    private func loadArray<T: Decodable>(key: String) -> [T] {
        guard let data = defaults.data(forKey: key),
              let value = try? JSONDecoder().decode([T].self, from: data) else {
            return []
        }
        return value
    }

    private func save<T: Encodable>(_ value: T, key: String) {
        let data = try? JSONEncoder().encode(value)
        defaults.set(data, forKey: key)
    }
}
