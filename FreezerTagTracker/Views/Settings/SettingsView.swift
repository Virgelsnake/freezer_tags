import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss

    init(viewModel: SettingsViewModel = SettingsViewModel()) {
        self.viewModel = viewModel
    }

    var body: some View {
        let strings = viewModel.strings

        Form {
            Section(strings.guidanceSectionTitle) {
                Toggle(strings.spokenGuidance, isOn: $viewModel.spokenGuidanceEnabled)
                    .onChange(of: viewModel.spokenGuidanceEnabled) { _ in
                        viewModel.persistSettings()
                    }

                Toggle(strings.spokenConfirmations, isOn: $viewModel.spokenConfirmationsEnabled)
                    .onChange(of: viewModel.spokenConfirmationsEnabled) { _ in
                        viewModel.persistSettings()
                    }

                Toggle(strings.haptics, isOn: $viewModel.hapticsEnabled)
                    .onChange(of: viewModel.hapticsEnabled) { _ in
                        viewModel.persistSettings()
                    }

                Toggle(strings.showMicrophoneShortcut, isOn: $viewModel.microphoneShortcutEnabled)
                    .accessibilityIdentifier("settings.microphoneShortcutToggle")
                    .onChange(of: viewModel.microphoneShortcutEnabled) { _ in
                        viewModel.persistSettings()
                    }

                Toggle(strings.showReadDetailsAgainButton, isOn: $viewModel.showReadDetailsAgainButton)
                    .accessibilityIdentifier("settings.readDetailsAgainToggle")
                    .onChange(of: viewModel.showReadDetailsAgainButton) { _ in
                        viewModel.persistSettings()
                    }
            }

            Section(strings.languageSectionTitle) {
                Picker(strings.languagePickerLabel, selection: $viewModel.language) {
                    ForEach(AppLanguage.allCases) { language in
                        Text(strings.languageName(language)).tag(language)
                    }
                }
                .onChange(of: viewModel.language) { _ in
                    viewModel.persistSettings()
                }

                Text(strings.languagePickerDescription)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section(strings.foodExpiryPresetsSectionTitle) {
                Text(strings.presetsDescription)
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                NavigationLink(strings.editPresetMonthValues) {
                    FoodPresetEditorView(viewModel: viewModel)
                }
            }
        }
        .navigationTitle(strings.settingsTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            viewModel.persistSettings()
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(strings.done) {
                    viewModel.persistSettings()
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        SettingsView()
    }
}
