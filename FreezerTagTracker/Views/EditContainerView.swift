import SwiftUI

struct EditContainerView: View {
    let container: ContainerRecord
    @ObservedObject var viewModel: ContainerViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var foodName: String
    @State private var dateFrozen: Date
    @State private var notes: String
    @State private var showingValidationError = false
    @State private var validationMessage = ""
    @State private var isSaving = false
    
    init(container: ContainerRecord, viewModel: ContainerViewModel) {
        self.container = container
        self.viewModel = viewModel
        _foodName = State(initialValue: container.foodName)
        _dateFrozen = State(initialValue: container.dateFrozen)
        _notes = State(initialValue: container.notes ?? "")
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
        notes != (container.notes ?? "")
    }
    
    var body: some View {
        Form {
            Section {
                TextField("Food Name", text: $foodName)
                    .autocorrectionDisabled()
                
                DatePicker("Date Frozen", selection: $dateFrozen, displayedComponents: .date)
            } header: {
                Text("Container Information")
            }
            
            Section {
                ZStack(alignment: .topLeading) {
                    if notes.isEmpty {
                        Text("Optional notes (e.g., ingredients, portions)")
                            .foregroundStyle(.secondary)
                            .padding(.top, 8)
                            .padding(.leading, 4)
                    }
                    
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                        .onChange(of: notes) { newValue in
                            if newValue.count > 200 {
                                notes = String(newValue.prefix(200))
                            }
                        }
                }
                
                HStack {
                    Spacer()
                    Text("\(remainingCharacters) characters remaining")
                        .font(.caption)
                        .foregroundStyle(remainingCharacters < 20 ? .red : .secondary)
                }
            } header: {
                Text("Notes (Optional)")
            }
        }
        .navigationTitle("Edit Container")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button(isSaving ? "Saving..." : "Save") {
                    saveChanges()
                }
                .disabled(!isValid || !hasChanges || isSaving)
            }
        }
        .alert("Validation Error", isPresented: $showingValidationError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(validationMessage)
        }
    }
    
    private func saveChanges() {
        let trimmedFoodName = foodName.trimmingCharacters(in: .whitespaces)
        
        guard !trimmedFoodName.isEmpty else {
            validationMessage = "Please enter a food name"
            showingValidationError = true
            return
        }
        
        guard notes.count <= 200 else {
            validationMessage = "Notes must be 200 characters or less"
            showingValidationError = true
            return
        }
        
        isSaving = true
        
        var updatedRecord = container
        updatedRecord.foodName = trimmedFoodName
        updatedRecord.dateFrozen = dateFrozen
        updatedRecord.notes = notes.isEmpty ? nil : notes
        
        viewModel.updateContainer(record: updatedRecord) { result in
            isSaving = false
            
            switch result {
            case .success:
                dismiss()
            case .failure(let error):
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
}
