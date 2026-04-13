import SwiftUI

struct EditContainerView: View {
    let container: ContainerRecord
    @ObservedObject var viewModel: ContainerViewModel
    @EnvironmentObject private var settingsViewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var foodName: String
    @State private var dateFrozen: Date
    @State private var notes: String
    @State private var bestBeforeDate: Date?
    @State private var hasBestBeforeDate: Bool
    @State private var showingValidationError = false
    @State private var validationMessage = ""
    @State private var isSaving = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case foodName
        case notes
    }
    
    init(container: ContainerRecord, viewModel: ContainerViewModel) {
        self.container = container
        self.viewModel = viewModel
        _foodName = State(initialValue: container.foodName)
        _dateFrozen = State(initialValue: container.dateFrozen)
        _notes = State(initialValue: container.notes ?? "")
        _bestBeforeDate = State(initialValue: container.bestBeforeDate)
        _hasBestBeforeDate = State(initialValue: container.bestBeforeDate != nil)
    }
    
    private var isValid: Bool {
        !foodName.trimmingCharacters(in: .whitespaces).isEmpty && notes.count <= 200
    }
    
    private var remainingCharacters: Int {
        200 - notes.count
    }
    
    private var hasChanges: Bool {
        foodName != container.foodName ||
        dateFrozen != container.dateFrozen ||
        notes != (container.notes ?? "") ||
        bestBeforeDate != container.bestBeforeDate
    }
    
    var body: some View {
        let strings = settingsViewModel.strings

        Form {
            Section {
                TextField(strings.foodName, text: $foodName)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .foodName)
                
                DatePicker(strings.dateFrozen, selection: $dateFrozen, displayedComponents: .date)
            } header: {
                Text(strings.containerInformation)
            }
            
            Section {
                Toggle(strings.setBestBeforeDate, isOn: $hasBestBeforeDate)
                    .onChange(of: hasBestBeforeDate) { newValue in
                        if newValue && bestBeforeDate == nil {
                            bestBeforeDate = Calendar.current.date(byAdding: .month, value: 3, to: Date())
                        } else if !newValue {
                            bestBeforeDate = nil
                        }
                    }
                
                if hasBestBeforeDate, let _ = bestBeforeDate {
                    DatePicker(strings.bestBefore, selection: Binding(
                        get: { bestBeforeDate ?? Date() },
                        set: { bestBeforeDate = $0 }
                    ), displayedComponents: .date)
                }
            } header: {
                Text(strings.bestBeforeOptional)
            } footer: {
                if hasBestBeforeDate {
                    Text(strings.bestBeforeInfo)
                        .font(.caption)
                }
            }
            
            Section {
                ZStack(alignment: .topLeading) {
                    if notes.isEmpty {
                        Text(strings.optionalNotesPlaceholder(example: true))
                            .foregroundStyle(.secondary)
                            .padding(.top, 8)
                            .padding(.leading, 4)
                    }
                    
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                        .focused($focusedField, equals: .notes)
                        .onChange(of: notes) { newValue in
                            if newValue.count > 200 {
                                notes = String(newValue.prefix(200))
                            }
                        }
                }
                
                HStack {
                    Spacer()
                    Text(strings.charactersRemaining(remainingCharacters))
                        .font(.caption)
                        .foregroundStyle(remainingCharacters < 20 ? .red : .secondary)
                }
            } header: {
                Text(strings.optionalNotes)
            }
        }
        .navigationTitle(strings.editContainerTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button(strings.done) {
                    focusedField = nil
                }
            }
            ToolbarItem(placement: .cancellationAction) {
                Button(strings.cancel) {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button(isSaving ? strings.saving : strings.save) {
                    saveChanges()
                }
                .disabled(!isValid || !hasChanges || isSaving)
            }
        }
        .alert(strings.validationErrorTitle, isPresented: $showingValidationError) {
            Button(strings.done, role: .cancel) { }
        } message: {
            Text(validationMessage)
        }
        .onAppear {
            print("🟡 EditContainerView: onAppear - editing container: \(container.foodName)")
            print("🟡 EditContainerView: isValid=\(isValid), hasChanges=\(hasChanges)")
        }
    }
    
    private func saveChanges() {
        print("🟡 EditContainerView: saveChanges() called")
        let trimmedFoodName = foodName.trimmingCharacters(in: .whitespaces)
        
        guard !trimmedFoodName.isEmpty else {
            print("❌ EditContainerView: Validation failed - empty food name")
            validationMessage = settingsViewModel.strings.pleaseEnterFoodName
            showingValidationError = true
            return
        }
        
        guard notes.count <= 200 else {
            print("❌ EditContainerView: Validation failed - notes too long")
            validationMessage = settingsViewModel.strings.notesMustBeShorter
            showingValidationError = true
            return
        }
        
        print("🟡 EditContainerView: Validation passed, setting isSaving=true")
        isSaving = true
        
        var updatedRecord = container
        updatedRecord.foodName = trimmedFoodName
        updatedRecord.dateFrozen = dateFrozen
        updatedRecord.notes = notes.isEmpty ? nil : notes
        updatedRecord.bestBeforeDate = hasBestBeforeDate ? bestBeforeDate : nil
        
        print("🟡 EditContainerView: Calling viewModel.updateContainer with id=\(updatedRecord.id), foodName=\(trimmedFoodName)")
        viewModel.updateContainer(record: updatedRecord) { result in
            print("🟡 EditContainerView: updateContainer callback received")
            isSaving = false
            
            switch result {
            case .success:
                print("✅ EditContainerView: Update succeeded, dismissing")
                dismiss()
            case .failure(let error):
                print("❌ EditContainerView: Update failed - \(error.localizedDescription)")
                validationMessage = error.localizedDescription
                showingValidationError = true
            }
        }
    }
}

#Preview {
    NavigationView {
        EditContainerView(
            container: ContainerRecord(
                tagID: "test-tag-123",
                foodName: "Chicken Soup",
                dateFrozen: Date(),
                notes: "Contains vegetables"
            ),
            viewModel: ContainerViewModel(dataStore: DataStore(inMemory: true))
        )
    }
    .environmentObject(SettingsViewModel())
}
