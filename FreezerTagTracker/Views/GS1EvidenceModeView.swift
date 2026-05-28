import SwiftUI

struct GS1EvidenceModeView: View {
    @StateObject private var viewModel = GS1EvidenceViewModel()

    var body: some View {
        Form {
            Section("Mode boundary") {
                Text("GS1 Evidence Mode uses GS1-style field names and export shape for a PoC. It is not GS1-certified and is not food-safety or legal compliance proof.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Text(GS1EvidenceProofLimit.text)
                    .font(.footnote)
            }

            Section("Manual product/item record") {
                TextField("Product name (required)", text: $viewModel.productName)
                TextField("GTIN, if supplied", text: $viewModel.gtin)
                TextField("Brand or supplier", text: $viewModel.brandOrSupplier)
                TextField("Batch/lot", text: $viewModel.batchOrLot)
                TextField("Serial or item ID", text: $viewModel.serialOrItemID)
                TextField("Expiry/use-by date", text: $viewModel.expiryOrUseByDate)
                TextField("Packed/frozen date", text: $viewModel.packedOrFrozenDate)
                TextField("Quantity or pack size", text: $viewModel.quantityOrPackSize)
                Picker("Storage state", selection: $viewModel.storageState) {
                    ForEach(GS1StorageState.allCases) { state in
                        Text(state.rawValue.capitalized).tag(state)
                    }
                }
                TextField("Storage instruction", text: $viewModel.storageInstruction)
                TextField("Allergen summary, if supplied", text: $viewModel.allergenSummary)

                Button("Save manual record") {
                    viewModel.saveManualRecord()
                }

                Button("Load demo record") {
                    viewModel.loadDemoRecord()
                }
            }

            if let errorMessage = viewModel.errorMessage {
                Section("Action needed") {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }

            if !viewModel.records.isEmpty {
                Section("Selected record") {
                    Picker("Record", selection: Binding(
                        get: { viewModel.selectedRecordID ?? viewModel.records.first?.id },
                        set: { viewModel.selectedRecordID = $0 }
                    )) {
                        ForEach(viewModel.records) { record in
                            Text(record.productName).tag(Optional(record.id))
                        }
                    }

                    if let record = viewModel.selectedRecord {
                        EvidenceFieldRow(label: "Product", value: record.productName)
                        EvidenceFieldRow(label: "GTIN", value: record.gtin)
                        EvidenceFieldRow(label: "Batch/lot", value: record.batchOrLot)
                        EvidenceFieldRow(label: "Serial/item", value: record.serialOrItemID)
                        EvidenceFieldRow(label: "Expiry/use-by", value: record.expiryOrUseByDate)
                    }
                }

                Section("Validation warnings") {
                    if viewModel.selectedRecordWarnings.isEmpty {
                        Text("No warnings for the supplied fields.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(viewModel.selectedRecordWarnings) { warning in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(warning.severity.rawValue.capitalized)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(warning.message)
                            }
                        }
                    }
                }

                Section("Simulator scan/check") {
                    Text("This path simulates scanning a linked NFC tag so the evidence logic can be verified without NFC hardware. Existing domestic NFC flow is unchanged.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    TextField("Operator name", text: $viewModel.operatorName)
                    TextField("Device label", text: $viewModel.deviceLabel)
                    TextField("Location note", text: $viewModel.locationNote)
                    Picker("Check status", selection: $viewModel.checkStatus) {
                        ForEach(GS1CheckStatus.allCases) { status in
                            Text(status.rawValue.replacingOccurrences(of: "_", with: " ").capitalized).tag(status)
                        }
                    }
                    TextEditor(text: $viewModel.checkNote)
                        .frame(minHeight: 80)
                    Button("Simulate scan and save check") {
                        viewModel.simulateScanAndSaveCheck()
                    }
                }
            }

            Section("Evidence export") {
                Text("Export content includes the proof-limit version and wording. It is audit evidence from this app, not proof of food safety or full compliance.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                HStack {
                    Button("Generate CSV") {
                        viewModel.generateCSVExport()
                    }
                    Button("Generate JSON") {
                        viewModel.generateJSONExport()
                    }
                }

                if !viewModel.exportText.isEmpty {
                    TextEditor(text: $viewModel.exportText)
                        .font(.system(.caption, design: .monospaced))
                        .frame(minHeight: 180)
                }
            }

            Section("Recent events") {
                if viewModel.events.isEmpty {
                    Text("No evidence events yet.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.events) { event in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(event.productName)
                                .font(.headline)
                            Text("\(event.checkStatus.rawValue.replacingOccurrences(of: "_", with: " ").capitalized): \(event.checkNote)")
                                .font(.subheadline)
                            Text(event.tagID)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Section("Deferred in this slice") {
                Text("CSV/JSON document import, production NFC write/read for GS1 payloads, native share-sheet export, Core Data migration, tag lifecycle controls, cloud identity, and formal compliance verification are deferred.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("GS1 Evidence")
    }
}

private struct EvidenceFieldRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value.isEmpty ? "Missing" : value)
                .multilineTextAlignment(.trailing)
        }
    }
}
