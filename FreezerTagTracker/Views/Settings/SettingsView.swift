import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss

    init(viewModel: SettingsViewModel = SettingsViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Form {
            Section("Guidance") {
                Toggle("Spoken guidance", isOn: boolBinding(\.spokenGuidanceEnabled))
                Toggle("Spoken confirmations", isOn: boolBinding(\.spokenConfirmationsEnabled))
                Toggle("Haptics", isOn: boolBinding(\.hapticsEnabled))
                Toggle("Show microphone shortcut", isOn: boolBinding(\.microphoneShortcutEnabled))
                Toggle("Show Read details again button", isOn: boolBinding(\.showReadDetailsAgainButton))
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
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }

    private func boolBinding(_ keyPath: ReferenceWritableKeyPath<SettingsViewModel, Bool>) -> Binding<Bool> {
        Binding(
            get: { viewModel[keyPath: keyPath] },
            set: {
                viewModel[keyPath: keyPath] = $0
                viewModel.persistSettings()
            }
        )
    }
}

#Preview {
    NavigationView {
        SettingsView()
    }
}
