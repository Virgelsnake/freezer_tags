import Foundation

final class SettingsViewModel: ObservableObject {
    @Published var spokenGuidanceEnabled: Bool
    @Published var spokenConfirmationsEnabled: Bool
    @Published var hapticsEnabled: Bool
    @Published var microphoneShortcutEnabled: Bool
    @Published var showReadDetailsAgainButton: Bool
    @Published var language: AppLanguage
    @Published private var presetOverrides: [FoodCategory: Int]

    private let settingsStore: AddContainerSettingsProviding
    private let defaultPresetMonths: [FoodCategory: Int]

    init(settingsStore: AddContainerSettingsProviding = AddContainerSettingsStore()) {
        self.settingsStore = settingsStore

        let settings = settingsStore.load()
        spokenGuidanceEnabled = settings.spokenGuidanceEnabled
        spokenConfirmationsEnabled = settings.spokenConfirmationsEnabled
        hapticsEnabled = settings.hapticsEnabled
        microphoneShortcutEnabled = settings.microphoneShortcutEnabled
        showReadDetailsAgainButton = settings.showReadDetailsAgainButton
        language = settings.language
        presetOverrides = settings.presetOverrides
        defaultPresetMonths = Dictionary(
            uniqueKeysWithValues: AddContainerSettingsStore.defaultPresets.map {
                ($0.category, $0.recommendedStorageMonths)
            }
        )
    }

    var strings: AppStrings {
        language.strings
    }

    var locale: Locale {
        language.locale
    }

    var editablePresetCategories: [FoodCategory] {
        AddContainerSettingsStore.defaultPresets
            .map(\.category)
            .filter { $0 != .other }
    }

    var currentSettings: AddContainerSettings {
        AddContainerSettings(
            spokenGuidanceEnabled: spokenGuidanceEnabled,
            spokenConfirmationsEnabled: spokenConfirmationsEnabled,
            hapticsEnabled: hapticsEnabled,
            microphoneShortcutEnabled: microphoneShortcutEnabled,
            showReadDetailsAgainButton: showReadDetailsAgainButton,
            language: language,
            presetOverrides: presetOverrides
        )
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
        settingsStore.save(currentSettings)
    }
}
