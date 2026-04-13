import Foundation

protocol FoodCategoryPresetProviding {
    func preset(for category: FoodCategory) -> FoodCategoryPreset
    func presets() -> [FoodCategoryPreset]
}

struct FoodCategoryPreset: Codable, Equatable {
    let category: FoodCategory
    let displayName: String
    let recommendedStorageMonths: Int

    var suggestionCopy: String {
        recommendedStorageMonths > 0
            ? "Suggested date based on USDA guidance"
            : "No automatic date"
    }
}
