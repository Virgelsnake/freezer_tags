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
        switch self {
        case .beef:
            return "Beef"
        case .fish:
            return "Fish"
        case .pastries:
            return "Pastries"
        case .poultry:
            return "Poultry"
        case .preparedMeal:
            return "Prepared meal"
        case .vegetables:
            return "Vegetables"
        case .other:
            return "Other"
        }
    }
}
