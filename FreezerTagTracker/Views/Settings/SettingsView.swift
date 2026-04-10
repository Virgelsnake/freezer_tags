import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss

    init(viewModel: SettingsViewModel = SettingsViewModel()) {
        self.viewModel = viewModel
    }

    var body: some View {
        Form {
            Section("Guidance") {
                Toggle("Spoken guidance", isOn: $viewModel.spokenGuidanceEnabled)
                    .onChange(of: viewModel.spokenGuidanceEnabled) { _ in
                        viewModel.persistSettings()
                    }

                Toggle("Spoken confirmations", isOn: $viewModel.spokenConfirmationsEnabled)
                    .onChange(of: viewModel.spokenConfirmationsEnabled) { _ in
                        viewModel.persistSettings()
                    }

                Toggle("Haptics", isOn: $viewModel.hapticsEnabled)
                    .onChange(of: viewModel.hapticsEnabled) { _ in
                        viewModel.persistSettings()
                    }

                Toggle("Show microphone shortcut", isOn: $viewModel.microphoneShortcutEnabled)
                    .accessibilityIdentifier("settings.microphoneShortcutToggle")
                    .onChange(of: viewModel.microphoneShortcutEnabled) { _ in
                        viewModel.persistSettings()
                    }

                Toggle("Show Read details again button", isOn: $viewModel.showReadDetailsAgainButton)
                    .accessibilityIdentifier("settings.readDetailsAgainToggle")
                    .onChange(of: viewModel.showReadDetailsAgainButton) { _ in
                        viewModel.persistSettings()
                    }
            }

            Section("Food expiry presets") {
                Text("These dates are suggested for best quality and can be changed.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                NavigationLink("Edit preset month values") {
                    FoodPresetEditorView(viewModel: viewModel)
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            viewModel.persistSettings()
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Done") {
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
