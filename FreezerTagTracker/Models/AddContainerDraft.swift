import Foundation

struct ContainerSummaryItem: Equatable, Hashable {
    let title: String
    let value: String
}

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

    func summaryItems(
        in language: AppLanguage = .english,
        relativeTo referenceDate: Date = Date(),
        calendar: Calendar = .current
    ) -> [ContainerSummaryItem] {
        let strings = language.strings
        var items = [
            ContainerSummaryItem(title: strings.foodName, value: trimmedFoodName),
            ContainerSummaryItem(title: strings.foodType, value: foodCategory?.displayName(in: language) ?? strings.notSet),
            ContainerSummaryItem(
                title: strings.dateFrozen,
                value: strings.today(relativeTo: referenceDate, comparedTo: dateFrozen, calendar: calendar)
            ),
            ContainerSummaryItem(
                title: strings.bestQualityBy,
                value: bestQualityDate.map {
                    strings.longDateString($0, calendar: calendar)
                } ?? strings.notSet
            ),
        ]

        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedNotes.isEmpty {
            items.append(ContainerSummaryItem(title: strings.notes, value: trimmedNotes))
        }

        return items
    }
}
