import Foundation

enum FoodCategory: String, Codable, CaseIterable, Hashable {
    case beef
    case fish
    case pastries
    case poultry
    case preparedMeal
    case vegetables
    case other

    var displayName: String {
        displayName(in: .english)
    }

    func displayName(in language: AppLanguage) -> String {
        language.strings.foodCategory(self)
    }
}
