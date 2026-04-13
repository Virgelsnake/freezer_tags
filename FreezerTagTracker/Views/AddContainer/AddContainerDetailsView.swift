import SwiftUI

struct AddContainerDetailsView: View {
    @ObservedObject var viewModel: AddContainerFlowViewModel
    let onCancel: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @FocusState private var focusedField: Field?
    @FocusState private var isNotesFocused: Bool
    @StateObject private var foodNameSpeechRecognizer: SpeechToTextRecognizer
    @StateObject private var notesSpeechRecognizer: SpeechToTextRecognizer
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

    init(viewModel: AddContainerFlowViewModel, onCancel: @escaping () -> Void) {
        let language = viewModel.currentLanguage
        self.viewModel = viewModel
        self.onCancel = onCancel
        _foodNameSpeechRecognizer = StateObject(
            wrappedValue: SpeechToTextRecognizer(
                copy: .foodName(in: language),
                locale: language.locale
            )
        )
        _notesSpeechRecognizer = StateObject(
            wrappedValue: SpeechToTextRecognizer(
                copy: .notes(in: language),
                locale: language.locale
            )
        )
    }

    private var strings: AppStrings {
        viewModel.currentLanguage.strings
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
                    title: strings.dateFrozen,
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
            Text(strings.step1Of2)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color.secondary)

            Text(strings.addContainerTitle)
                .font(.largeTitle.weight(.bold))

            Text(strings.addContainerSubtitle)
                .font(.body)
                .foregroundStyle(Color.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(strings.addContainerAccessibilityHeader)
        .accessibilitySortPriority(6)
    }

    private var foodNameSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(strings.foodName)
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
                Text(validationMessage == strings.foodNameRequiredMessage ? strings.foodNameRequiredToContinue : validationMessage)
                    .font(.footnote)
                    .foregroundStyle(Color.red)
            } else if let speechStatusMessage = foodNameSpeechRecognizer.statusMessage {
                Text(speechStatusMessage)
                    .font(.footnote)
                    .foregroundStyle(foodNameSpeechRecognizer.isShowingError ? Color.red : Color.secondary)
            } else {
                Text(strings.required)
                    .font(.footnote)
                    .foregroundStyle(Color.secondary)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilitySortPriority(5)
    }

    private var foodNameField: some View {
        TextField(
            strings.foodNameExample,
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
        .accessibilityLabel(strings.foodName)
        .accessibilityValue(viewModel.draft.foodName.isEmpty ? strings.empty : viewModel.draft.foodName)
        .accessibilityHint(strings.foodNameFieldHint)
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
        .accessibilityHint(foodNameSpeechRecognizer.isListening ? strings.stopListeningHint : strings.dictateFoodNameHint)
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
        .accessibilityHint(notesSpeechRecognizer.isListening ? strings.stopListeningHint : strings.dictateNoteHint)
        .accessibilityIdentifier("addContainer.notesMicrophoneButton")
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    private var presetSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(strings.chooseFoodType)
                .font(.headline)

            Text(strings.foodTypeSuggestionDescription)
                .font(.body)
                .foregroundStyle(Color.secondary)

            if dynamicTypeSize.isAccessibilitySize {
                VStack(spacing: 12) {
                    ForEach(viewModel.availablePresets, id: \.category) { preset in
                        FoodPresetButton(
                            title: strings.foodCategory(preset.category),
                            isSelected: viewModel.draft.foodCategory == preset.category,
                            accessibilityIdentifier: "addContainer.preset.\(preset.category.rawValue)",
                            accessibilityValue: viewModel.draft.foodCategory == preset.category ? strings.selected : strings.notSelected,
                            accessibilityHint: strings.presetAccessibilityHint(isSelected: viewModel.draft.foodCategory == preset.category)
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
                            title: strings.foodCategory(preset.category),
                            isSelected: viewModel.draft.foodCategory == preset.category,
                            accessibilityIdentifier: "addContainer.preset.\(preset.category.rawValue)",
                            accessibilityValue: viewModel.draft.foodCategory == preset.category ? strings.selected : strings.notSelected,
                            accessibilityHint: strings.presetAccessibilityHint(isSelected: viewModel.draft.foodCategory == preset.category)
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
                title: strings.dateFrozen,
                value: displayDate(viewModel.draft.dateFrozen, relativeTo: Date()),
                isEmpty: false,
                accessibilityHint: strings.changeDateHint
            ) {
                pendingDateFrozen = viewModel.draft.dateFrozen
                activePicker = .dateFrozen
            }

            LabeledDateRow(
                title: strings.bestQualityBy,
                value: viewModel.draft.bestQualityDate.map { displayDate($0, relativeTo: Date()) } ?? strings.notSet,
                isEmpty: viewModel.draft.bestQualityDate == nil,
                accessibilityHint: strings.changeDateHint
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
                    Text(strings.notes)
                        .font(.headline)

                    if viewModel.showsMicrophoneShortcut {
                        notesMicrophoneButton(maxWidth: true)
                    }
                }
            } else {
                HStack(alignment: .center, spacing: 12) {
                    Text(strings.notes)
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
                accessibilityLabel: strings.notes,
                placeholder: strings.optionalNotesPlaceholder(),
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
                Text(strings.reviewAndWriteToTag)
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 60)
            }
            .buttonStyle(PrimaryActionButtonStyle())
            .disabled(!viewModel.canProceedToReview)
            .opacity(viewModel.canProceedToReview ? 1 : 0.45)
            .accessibilityHint(strings.reviewButtonHint(canProceed: viewModel.canProceedToReview))
            .accessibilityIdentifier("addContainer.reviewButton")

            Button(strings.cancel, action: onCancel)
                .font(.body.weight(.semibold))
                .foregroundStyle(Color.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .accessibilityHint(strings.closeAddContainerHint)
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
                    Button(strings.cancel) {
                        activePicker = nil
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(strings.done) {
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
                    strings.bestQualityBy,
                    selection: $pendingBestQualityDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .labelsHidden()

                if viewModel.draft.bestQualityDate != nil {
                    Button(strings.removeDate) {
                        viewModel.updateBestQualityDate(nil)
                        activePicker = nil
                    }
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color.red)
                }

                Spacer()
            }
            .padding(20)
            .navigationTitle(strings.bestQualityBy)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(strings.cancel) {
                        activePicker = nil
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(strings.done) {
                        viewModel.updateBestQualityDate(pendingBestQualityDate)
                        activePicker = nil
                    }
                }
            }
        }
    }

    private func displayDate(_ date: Date, relativeTo referenceDate: Date) -> String {
        strings.today(relativeTo: referenceDate, comparedTo: date)
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
    .environmentObject(SettingsViewModel())
}
