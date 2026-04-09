import Foundation

struct BestQualityDateCalculator {
    private let presetProvider: FoodCategoryPresetProviding
    private let calendar: Calendar

    init(
        presetProvider: FoodCategoryPresetProviding = AddContainerSettingsStore(),
        calendar: Calendar = .current
    ) {
        self.presetProvider = presetProvider
        self.calendar = calendar
    }

    func suggestedDate(for category: FoodCategory, frozenOn: Date) -> Date? {
        let preset = presetProvider.preset(for: category)

        guard preset.recommendedStorageMonths > 0 else {
            return nil
        }

        return calendar.date(byAdding: .month, value: preset.recommendedStorageMonths, to: frozenOn)
    }

    func presetDescription(for category: FoodCategory) -> String {
        presetProvider.preset(for: category).suggestionCopy
    }
}
