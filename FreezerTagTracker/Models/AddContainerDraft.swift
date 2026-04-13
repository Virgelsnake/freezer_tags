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
        relativeTo referenceDate: Date = Date(),
        calendar: Calendar = .current
    ) -> [ContainerSummaryItem] {
        var items = [
            ContainerSummaryItem(title: "Food name", value: trimmedFoodName),
            ContainerSummaryItem(title: "Food type", value: foodCategory?.displayName ?? "Not set"),
            ContainerSummaryItem(
                title: "Date frozen",
                value: Self.displayDate(dateFrozen, relativeTo: referenceDate, calendar: calendar)
            ),
            ContainerSummaryItem(
                title: "Best quality by",
                value: bestQualityDate.map {
                    Self.formattedDate($0, calendar: calendar)
                } ?? "Not set"
            ),
        ]

        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedNotes.isEmpty {
            items.append(ContainerSummaryItem(title: "Notes", value: trimmedNotes))
        }

        return items
    }

    private static func displayDate(_ date: Date, relativeTo referenceDate: Date, calendar: Calendar) -> String {
        if calendar.isDate(date, inSameDayAs: referenceDate) {
            return "Today"
        }

        return formattedDate(date, calendar: calendar)
    }

    private static func formattedDate(_ date: Date, calendar: Calendar) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = calendar.timeZone
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: date)
    }
}
