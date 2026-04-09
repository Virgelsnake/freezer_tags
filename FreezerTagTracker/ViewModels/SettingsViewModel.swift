import Foundation

final class SettingsViewModel: ObservableObject {
    @Published var spokenGuidanceEnabled: Bool
    @Published var spokenConfirmationsEnabled: Bool
    @Published var hapticsEnabled: Bool
    @Published var microphoneShortcutEnabled: Bool
    @Published var showReadDetailsAgainButton: Bool

    private let settingsStore: AddContainerSettingsProviding
    private let defaultPresetMonths: [FoodCategory: Int]
    private var presetOverrides: [FoodCategory: Int]

    init(settingsStore: AddContainerSettingsProviding = AddContainerSettingsStore()) {
        self.settingsStore = settingsStore

        let settings = settingsStore.load()
        spokenGuidanceEnabled = settings.spokenGuidanceEnabled
        spokenConfirmationsEnabled = settings.spokenConfirmationsEnabled
        hapticsEnabled = settings.hapticsEnabled
        microphoneShortcutEnabled = settings.microphoneShortcutEnabled
        showReadDetailsAgainButton = settings.showReadDetailsAgainButton
        presetOverrides = settings.presetOverrides
        defaultPresetMonths = Dictionary(
            uniqueKeysWithValues: AddContainerSettingsStore.defaultPresets.map {
                ($0.category, $0.recommendedStorageMonths)
            }
        )
    }

    var editablePresetCategories: [FoodCategory] {
        AddContainerSettingsStore.defaultPresets
            .map(\.category)
            .filter { $0 != .other }
    }

    func presetMonths(for category: FoodCategory) -> Int? {
        guard category != .other else {
            return nil
        }

        return presetOverrides[category] ?? defaultPresetMonths[category]
    }

    func updatePresetMonths(_ months: Int, for category: FoodCategory) {
        guard category != .other else {
            return
        }

        let defaultMonths = defaultPresetMonths[category] ?? months
        presetOverrides[category] = months == defaultMonths ? nil : months
        persistSettings()
    }

    func resetPresetDefaults() {
        presetOverrides = [:]
        persistSettings()
    }

    func persistSettings() {
        settingsStore.save(
            AddContainerSettings(
                spokenGuidanceEnabled: spokenGuidanceEnabled,
                spokenConfirmationsEnabled: spokenConfirmationsEnabled,
                hapticsEnabled: hapticsEnabled,
                microphoneShortcutEnabled: microphoneShortcutEnabled,
                showReadDetailsAgainButton: showReadDetailsAgainButton,
                presetOverrides: presetOverrides
            )
        )
        objectWillChange.send()
    }
}
