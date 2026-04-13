import SwiftUI

struct AddContainerDetailsView: View {
    @ObservedObject var viewModel: AddContainerFlowViewModel
    let onCancel: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @FocusState private var focusedField: Field?
    @FocusState private var isNotesFocused: Bool
    @StateObject private var foodNameSpeechRecognizer = SpeechToTextRecognizer(copy: .foodName)
    @StateObject private var notesSpeechRecognizer = SpeechToTextRecognizer(copy: .notes)
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
        .accessibilityIdentifier("addContainer.details.screen")
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
            focusedField = nil
            isNotesFocused = false
            dismissKeyboard()
            viewModel.handleDetailsScreenAppeared()
        }
        .onDisappear {
            foodNameSpeechRecognizer.stopListening()
            notesSpeechRecognizer.stopListening()
        }
        .onChange(of: focusedField) { field in
            guard field == .foodName else {
                return
            }

            foodNameSpeechRecognizer.stopListening()
            notesSpeechRecognizer.stopListening()
        }
        .onChange(of: isNotesFocused) { isFocused in
            guard isFocused else {
                return
            }

            foodNameSpeechRecognizer.stopListening()
            notesSpeechRecognizer.stopListening()
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
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Step 1 of 2. Add a container. Tell us what you are freezing, then we will help you write it to the tag.")
        .accessibilitySortPriority(6)
    }

    private var foodNameSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Food name")
                .font(.headline)

            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 12) {
                    foodNameField
                    if viewModel.showsMicrophoneShortcut {
                        microphoneButton(maxWidth: true)
                    }
                }
            } else {
                HStack(alignment: .top, spacing: 12) {
                    foodNameField
                    if viewModel.showsMicrophoneShortcut {
                        microphoneButton(maxWidth: false)
                    }
                }
            }

            if let validationMessage = viewModel.validationMessage {
                Text(validationMessage == "Food name is required." ? "Enter a food name to continue" : validationMessage)
                    .font(.footnote)
                    .foregroundStyle(Color.red)
            } else if let speechStatusMessage = foodNameSpeechRecognizer.statusMessage {
                Text(speechStatusMessage)
                    .font(.footnote)
                    .foregroundStyle(foodNameSpeechRecognizer.isShowingError ? Color.red : Color.secondary)
            } else {
                Text("Required")
                    .font(.footnote)
                    .foregroundStyle(Color.secondary)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilitySortPriority(5)
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
        .accessibilityIdentifier("addContainer.foodNameField")
    }

    private func microphoneButton(maxWidth: Bool) -> some View {
        Button {
            focusedField = nil
            isNotesFocused = false
            dismissKeyboard()
            notesSpeechRecognizer.stopListening()
            foodNameSpeechRecognizer.toggleListening { transcript in
                viewModel.updateFoodName(transcript)
            }
        } label: {
            Label(foodNameSpeechRecognizer.buttonTitle, systemImage: foodNameSpeechRecognizer.buttonSystemImage)
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
        .accessibilityHint(foodNameSpeechRecognizer.isListening ? "Double tap to stop listening." : "Double tap to dictate the name of the food.")
        .accessibilityIdentifier("addContainer.microphoneButton")
    }

    private func notesMicrophoneButton(maxWidth: Bool) -> some View {
        Button {
            focusedField = nil
            isNotesFocused = false
            dismissKeyboard()
            foodNameSpeechRecognizer.stopListening()
            let existingNotes = viewModel.draft.notes.trimmingCharacters(in: .whitespacesAndNewlines)
            notesSpeechRecognizer.toggleListening { transcript in
                viewModel.updateNotes(combinedNotes(base: existingNotes, dictatedNote: transcript))
            }
        } label: {
            Label(notesSpeechRecognizer.buttonTitle, systemImage: notesSpeechRecognizer.buttonSystemImage)
                .font(.footnote.weight(.semibold))
                .frame(maxWidth: maxWidth ? .infinity : nil, minHeight: 44)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(.tertiarySystemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color(.separator), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .accessibilityHint(notesSpeechRecognizer.isListening ? "Double tap to stop listening." : "Double tap to dictate a note.")
        .accessibilityIdentifier("addContainer.notesMicrophoneButton")
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
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
                            isSelected: viewModel.draft.foodCategory == preset.category,
                            accessibilityIdentifier: "addContainer.preset.\(preset.category.rawValue)"
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
                            isSelected: viewModel.draft.foodCategory == preset.category,
                            accessibilityIdentifier: "addContainer.preset.\(preset.category.rawValue)"
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
        .accessibilityElement(children: .contain)
        .accessibilitySortPriority(4)
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
        .accessibilityElement(children: .contain)
        .accessibilitySortPriority(3)
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Notes")
                        .font(.headline)

                    if viewModel.showsMicrophoneShortcut {
                        notesMicrophoneButton(maxWidth: true)
                    }
                }
            } else {
                HStack(alignment: .center, spacing: 12) {
                    Text("Notes")
                        .font(.headline)

                    Spacer(minLength: 12)

                    if viewModel.showsMicrophoneShortcut {
                        notesMicrophoneButton(maxWidth: false)
                    }
                }
            }

            CharacterCountTextEditor(
                text: Binding(
                    get: { viewModel.draft.notes },
                    set: { viewModel.updateNotes($0) }
                ),
                title: nil,
                accessibilityLabel: "Notes",
                placeholder: "Optional notes",
                characterLimit: 200,
                focus: $isNotesFocused
            )

            if let statusMessage = notesSpeechRecognizer.statusMessage {
                Text(statusMessage)
                    .font(.footnote)
                    .foregroundStyle(notesSpeechRecognizer.isShowingError ? Color.red : Color.secondary)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilitySortPriority(2)
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
            .accessibilityIdentifier("addContainer.reviewButton")

            Button("Cancel", action: onCancel)
                .font(.body.weight(.semibold))
                .foregroundStyle(Color.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .accessibilityHint("Closes the add-container flow without saving.")
                .accessibilityIdentifier("addContainer.cancelButton")
        }
        .accessibilityElement(children: .contain)
        .accessibilitySortPriority(1)
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

    private func combinedNotes(base: String, dictatedNote: String) -> String {
        let trimmedTranscript = dictatedNote.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedTranscript.isEmpty else {
            return base
        }

        guard !base.isEmpty else {
            return trimmedTranscript
        }

        return "\(base)\n\(trimmedTranscript)"
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
