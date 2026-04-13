import SwiftUI

struct FoodPresetEditorView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        let strings = viewModel.strings

        Form {
            Section {
                ForEach(viewModel.editablePresetCategories, id: \.self) { category in
                    Stepper(value: binding(for: category), in: 1...12) {
                        HStack {
                            Text(strings.foodCategory(category))
                            Spacer()
                            Text(monthLabel(for: category))
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                HStack {
                    Text(strings.foodCategory(.other))
                    Spacer()
                    Text(strings.noAutomaticDate)
                        .foregroundStyle(.secondary)
                }
            } footer: {
                Text(strings.suggestedDatesResettable)
            }

            Section {
                Button(strings.resetToDefaults, role: .destructive) {
                    viewModel.resetPresetDefaults()
                }
            }
        }
        .navigationTitle(strings.foodExpiryPresetsSectionTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func binding(for category: FoodCategory) -> Binding<Int> {
        Binding(
            get: { viewModel.presetMonths(for: category) ?? 1 },
            set: { viewModel.updatePresetMonths($0, for: category) }
        )
    }

    private func monthLabel(for category: FoodCategory) -> String {
        let strings = viewModel.strings
        guard let months = viewModel.presetMonths(for: category) else {
            return strings.noAutomaticDate
        }

        return strings.monthLabel(months)
    }
}

#Preview {
    NavigationView {
        FoodPresetEditorView(viewModel: SettingsViewModel())
    }
}
