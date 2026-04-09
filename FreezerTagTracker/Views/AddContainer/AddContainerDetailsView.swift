import SwiftUI

struct AddContainerDetailsView: View {
    @ObservedObject var viewModel: AddContainerFlowViewModel
    let onCancel: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @FocusState private var focusedField: Field?
    @State private var activePicker: ActivePicker?
    @State private var pendingBestQualityDate = Date()
    @State private var pendingDateFrozen = Date()

    enum Field {
        case foodName
    }

    enum ActivePicker: String, Identifiable {
        case dateFrozen
        case bestQuality

        var id: String { rawValue }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                foodNameSection
                presetSection
                dateSection
                notesSection
                actionSection
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .sheet(item: $activePicker) { picker in
            switch picker {
            case .dateFrozen:
                datePickerSheet(
                    title: "Date frozen",
                    selection: $pendingDateFrozen,
                    onSave: { viewModel.updateDateFrozen(pendingDateFrozen) }
                )
            case .bestQuality:
                bestQualityDatePickerSheet
            }
        }
        .onAppear {
            pendingDateFrozen = viewModel.draft.dateFrozen
            pendingBestQualityDate = viewModel.draft.bestQualityDate ?? viewModel.draft.dateFrozen
            focusedField = .foodName
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Step 1 of 2")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color.secondary)

            Text("Add a container")
                .font(.largeTitle.weight(.bold))

            Text("Tell us what you are freezing, then we will help you write it to the tag.")
                .font(.body)
                .foregroundStyle(Color.secondary)
        }
    }

    private var foodNameSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Food name")
                .font(.headline)

            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 12) {
                    foodNameField
                    microphoneButton(maxWidth: true)
                }
            } else {
                HStack(alignment: .top, spacing: 12) {
                    foodNameField
                    microphoneButton(maxWidth: false)
                }
            }

            if let validationMessage = viewModel.validationMessage {
                Text(validationMessage == "Food name is required." ? "Enter a food name to continue" : validationMessage)
                    .font(.footnote)
                    .foregroundStyle(Color.red)
            } else {
                Text("Required")
                    .font(.footnote)
                    .foregroundStyle(Color.secondary)
            }
        }
    }

    private var foodNameField: some View {
        TextField(
            "Example: Beef stew",
            text: Binding(
                get: { viewModel.draft.foodName },
                set: { viewModel.updateFoodName($0) }
            )
        )
        .textInputAutocapitalization(.words)
        .autocorrectionDisabled()
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .frame(minHeight: 60)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(viewModel.validationMessage == nil ? Color(.separator) : Color.red, lineWidth: 1)
        )
        .focused($focusedField, equals: .foodName)
        .accessibilityLabel("Food name")
        .accessibilityValue(viewModel.draft.foodName.isEmpty ? "Empty" : viewModel.draft.foodName)
        .accessibilityHint("Required text field. Double tap to type or use dictation.")
    }

    private func microphoneButton(maxWidth: Bool) -> some View {
        Button {
            focusedField = .foodName
        } label: {
            Label("Speak food name", systemImage: "mic.fill")
                .font(.body.weight(.semibold))
                .frame(maxWidth: maxWidth ? .infinity : nil, minHeight: 60)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color(.tertiarySystemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color(.separator), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .accessibilityHint("Double tap to dictate the name of the food.")
    }

    private var presetSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Choose a food type")
                .font(.headline)

            Text("This can add a suggested best-quality date.")
                .font(.body)
                .foregroundStyle(Color.secondary)

            if dynamicTypeSize.isAccessibilitySize {
                VStack(spacing: 12) {
                    ForEach(viewModel.availablePresets, id: \.category) { preset in
                        FoodPresetButton(
                            title: preset.displayName,
                            isSelected: viewModel.draft.foodCategory == preset.category
                        ) {
                            viewModel.selectPreset(preset.category)
                            if let bestQualityDate = viewModel.draft.bestQualityDate {
                                pendingBestQualityDate = bestQualityDate
                            }
                        }
                    }
                }
            } else {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 140), spacing: 12, alignment: .leading)],
                    alignment: .leading,
                    spacing: 12
                ) {
                    ForEach(viewModel.availablePresets, id: \.category) { preset in
                        FoodPresetButton(
                            title: preset.displayName,
                            isSelected: viewModel.draft.foodCategory == preset.category
                        ) {
                            viewModel.selectPreset(preset.category)
                            if let bestQualityDate = viewModel.draft.bestQualityDate {
                                pendingBestQualityDate = bestQualityDate
                            }
                        }
                    }
                }
            }

            if let presetStatusMessage = viewModel.presetStatusMessage {
                Text(presetStatusMessage)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color.blue)
            }
        }
    }

    private var dateSection: some View {
        VStack(spacing: 12) {
            LabeledDateRow(
                title: "Date frozen",
                value: displayDate(viewModel.draft.dateFrozen, relativeTo: Date()),
                isEmpty: false
            ) {
                pendingDateFrozen = viewModel.draft.dateFrozen
                activePicker = .dateFrozen
            }

            LabeledDateRow(
                title: "Best quality by",
                value: viewModel.draft.bestQualityDate.map { displayDate($0, relativeTo: Date()) } ?? "Not set",
                isEmpty: viewModel.draft.bestQualityDate == nil
            ) {
                pendingBestQualityDate = viewModel.draft.bestQualityDate ?? viewModel.draft.dateFrozen
                activePicker = .bestQuality
            }
        }
    }

    private var notesSection: some View {
        CharacterCountTextEditor(
            text: Binding(
                get: { viewModel.draft.notes },
                set: { viewModel.updateNotes($0) }
            ),
            title: "Notes",
            placeholder: "Optional notes",
            characterLimit: 200
        )
    }

    private var actionSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Button {
                viewModel.goToReview()
            } label: {
                Text("Review and write to tag")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 60)
            }
            .buttonStyle(PrimaryActionButtonStyle())
            .disabled(!viewModel.canProceedToReview)
            .opacity(viewModel.canProceedToReview ? 1 : 0.45)
            .accessibilityHint(
                viewModel.canProceedToReview
                    ? "Moves to the final review screen before writing to the tag."
                    : "Disabled. Food name is required."
            )

            Button("Cancel", action: onCancel)
                .font(.body.weight(.semibold))
                .foregroundStyle(Color.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    private func datePickerSheet(
        title: String,
        selection: Binding<Date>,
        onSave: @escaping () -> Void
    ) -> some View {
        NavigationView {
            VStack(spacing: 24) {
                DatePicker(
                    title,
                    selection: selection,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .labelsHidden()

                Spacer()
            }
            .padding(20)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        activePicker = nil
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        onSave()
                        activePicker = nil
                    }
                }
            }
        }
    }

    private var bestQualityDatePickerSheet: some View {
        NavigationView {
            VStack(spacing: 24) {
                DatePicker(
                    "Best quality by",
                    selection: $pendingBestQualityDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .labelsHidden()

                if viewModel.draft.bestQualityDate != nil {
                    Button("Remove date") {
                        viewModel.updateBestQualityDate(nil)
                        activePicker = nil
                    }
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color.red)
                }

                Spacer()
            }
            .padding(20)
            .navigationTitle("Best quality by")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        activePicker = nil
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        viewModel.updateBestQualityDate(pendingBestQualityDate)
                        activePicker = nil
                    }
                }
            }
        }
    }

    private func displayDate(_ date: Date, relativeTo referenceDate: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDate(date, inSameDayAs: referenceDate) {
            return "Today"
        }

        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

private struct PrimaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(Color.white)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(configuration.isPressed ? Color.blue.opacity(0.85) : Color.blue)
            )
            .opacity(configuration.isPressed ? 0.92 : 1)
    }
}

#Preview {
    NavigationView {
        AddContainerDetailsView(viewModel: AddContainerFlowViewModel(), onCancel: {})
    }
}
