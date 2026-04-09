import Foundation

struct AddContainerDraft: Equatable {
    var foodName: String
    var foodCategory: FoodCategory?
    var dateFrozen: Date
    var bestQualityDate: Date?
    var notes: String
    var isBestQualityDateManuallyEdited: Bool

    init(
        foodName: String = "",
        foodCategory: FoodCategory? = nil,
        dateFrozen: Date = Date(),
        bestQualityDate: Date? = nil,
        notes: String = "",
        isBestQualityDateManuallyEdited: Bool = false
    ) {
        self.foodName = foodName
        self.foodCategory = foodCategory
        self.dateFrozen = dateFrozen
        self.bestQualityDate = bestQualityDate
        self.notes = notes
        self.isBestQualityDateManuallyEdited = isBestQualityDateManuallyEdited
    }

    var trimmedFoodName: String {
        foodName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var canProceedToReview: Bool {
        !trimmedFoodName.isEmpty && notes.count <= 200
    }
}
