import SwiftUI

struct AddContainerView: View {
    @ObservedObject var viewModel: ContainerViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var foodName = ""
    @State private var dateFrozen = Date()
    @State private var notes = ""
    @State private var bestBeforeDate: Date?
    @State private var hasBestBeforeDate = false
    @State private var showingValidationError = false
    @State private var validationMessage = ""
    @State private var isSaving = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case foodName
        case notes
    }
    
    private var isValid: Bool {
        !foodName.trimmingCharacters(in: .whitespaces).isEmpty && notes.count <= 200
    }
    
    private var remainingCharacters: Int {
        200 - notes.count
    }
    
    var body: some View {
        Form {
            Section {
                TextField("Food Name", text: $foodName)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .foodName)
                
                DatePicker("Date Frozen", selection: $dateFrozen, displayedComponents: .date)
            } header: {
                Text("Container Information")
            }
            
            Section {
                Toggle("Set Best Before Date", isOn: $hasBestBeforeDate)
                    .onChange(of: hasBestBeforeDate) { newValue in
                        if newValue && bestBeforeDate == nil {
                            bestBeforeDate = Calendar.current.date(byAdding: .month, value: 3, to: Date())
                        } else if !newValue {
                            bestBeforeDate = nil
                        }
                    }
                
                if hasBestBeforeDate, let _ = bestBeforeDate {
                    DatePicker("Best Before Date", selection: Binding(
                        get: { bestBeforeDate ?? Date() },
                        set: { bestBeforeDate = $0 }
                    ), displayedComponents: .date)
                }
            } header: {
                Text("Best Before Date (Optional)")
            } footer: {
                if hasBestBeforeDate {
                    Text("You'll be notified when the date approaches or passes")
                        .font(.caption)
                }
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
                        .focused($focusedField, equals: .notes)
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
            
            Section {
                Button(action: saveAndScan) {
                    HStack {
                        if isSaving {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            Image(systemName: "wave.3.right.circle.fill")
                        }
                        Text(isSaving ? "Scanning..." : "Save & Scan Tag")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                }
                .disabled(!isValid || isSaving)
            }
        }
        .navigationTitle("Add Container")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    focusedField = nil
                }
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .alert("Validation Error", isPresented: $showingValidationError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(validationMessage)
        }
    }
    
    private func saveAndScan() {
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
        
        viewModel.saveContainerWithNFC(
            foodName: trimmedFoodName,
            dateFrozen: dateFrozen,
            notes: notes.isEmpty ? nil : notes,
            bestBeforeDate: hasBestBeforeDate ? bestBeforeDate : nil
        ) { result in
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
        AddContainerView(viewModel: ContainerViewModel(dataStore: DataStore(inMemory: true)))
    }
}
