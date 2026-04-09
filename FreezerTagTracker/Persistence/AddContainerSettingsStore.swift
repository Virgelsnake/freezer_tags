import Foundation

protocol AddContainerSettingsProviding: FoodCategoryPresetProviding {
    func load() -> AddContainerSettings
    func save(_ settings: AddContainerSettings)
}

final class AddContainerSettingsStore: AddContainerSettingsProviding {
    private enum Keys {
        static let settings = "addContainerSettings"
    }

    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func load() -> AddContainerSettings {
        guard let data = userDefaults.data(forKey: Keys.settings),
              let settings = try? decoder.decode(AddContainerSettings.self, from: data) else {
            return AddContainerSettings()
        }

        return settings
    }

    func save(_ settings: AddContainerSettings) {
        guard let data = try? encoder.encode(settings) else {
            return
        }

        userDefaults.set(data, forKey: Keys.settings)
    }

    func updateSettings(_ update: (inout AddContainerSettings) -> Void) {
        var settings = load()
        update(&settings)
        save(settings)
    }

    func presetOverride(for category: FoodCategory) -> Int? {
        load().presetOverrides[category]
    }

    func setPresetOverride(_ months: Int?, for category: FoodCategory) {
        updateSettings { settings in
            settings.presetOverrides[category] = months
        }
    }

    func presets() -> [FoodCategoryPreset] {
        let overrides = load().presetOverrides

        return Self.defaultPresets.map { preset in
            FoodCategoryPreset(
                category: preset.category,
                displayName: preset.displayName,
                recommendedStorageMonths: overrides[preset.category] ?? preset.recommendedStorageMonths
            )
        }
    }

    func preset(for category: FoodCategory) -> FoodCategoryPreset {
        presets().first(where: { $0.category == category })
            ?? FoodCategoryPreset(
                category: category,
                displayName: category.displayName,
                recommendedStorageMonths: 0
            )
    }

    static let defaultPresets: [FoodCategoryPreset] = [
        FoodCategoryPreset(category: .beef, displayName: FoodCategory.beef.displayName, recommendedStorageMonths: 4),
        FoodCategoryPreset(category: .poultry, displayName: FoodCategory.poultry.displayName, recommendedStorageMonths: 9),
        FoodCategoryPreset(category: .fish, displayName: FoodCategory.fish.displayName, recommendedStorageMonths: 4),
        FoodCategoryPreset(category: .preparedMeal, displayName: FoodCategory.preparedMeal.displayName, recommendedStorageMonths: 3),
        FoodCategoryPreset(category: .pastries, displayName: FoodCategory.pastries.displayName, recommendedStorageMonths: 2),
        FoodCategoryPreset(category: .vegetables, displayName: FoodCategory.vegetables.displayName, recommendedStorageMonths: 8),
        FoodCategoryPreset(category: .other, displayName: FoodCategory.other.displayName, recommendedStorageMonths: 0),
    ]
}
