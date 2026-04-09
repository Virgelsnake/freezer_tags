import SwiftUI

struct FoodPresetEditorView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        Form {
            Section {
                ForEach(viewModel.editablePresetCategories, id: \.self) { category in
                    Stepper(value: binding(for: category), in: 1...12) {
                        HStack {
                            Text(category.displayName)
                            Spacer()
                            Text(monthLabel(for: category))
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                HStack {
                    Text(FoodCategory.other.displayName)
                    Spacer()
                    Text("No automatic date")
                        .foregroundStyle(.secondary)
                }
            } footer: {
                Text("Suggested best-quality dates can be reset at any time.")
            }

            Section {
                Button("Reset to defaults", role: .destructive) {
                    viewModel.resetPresetDefaults()
                }
            }
        }
        .navigationTitle("Food expiry presets")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func binding(for category: FoodCategory) -> Binding<Int> {
        Binding(
            get: { viewModel.presetMonths(for: category) ?? 1 },
            set: { viewModel.updatePresetMonths($0, for: category) }
        )
    }

    private func monthLabel(for category: FoodCategory) -> String {
        guard let months = viewModel.presetMonths(for: category) else {
            return "No automatic date"
        }

        return months == 1 ? "1 month" : "\(months) months"
    }
}

#Preview {
    NavigationView {
        FoodPresetEditorView(viewModel: SettingsViewModel())
    }
}
