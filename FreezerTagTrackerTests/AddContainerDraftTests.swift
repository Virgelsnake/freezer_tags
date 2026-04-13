import XCTest
@testable import FreezerTagTracker

final class AddContainerDraftTests: XCTestCase {
    func testSummaryItemsIncludeReadableValuesAndOmitBlankNotes() {
        let calendar = Calendar(identifier: .gregorian)
        let referenceDate = calendar.date(from: DateComponents(year: 2026, month: 4, day: 9))!
        let bestQualityDate = calendar.date(from: DateComponents(year: 2026, month: 8, day: 9))!
        let draft = AddContainerDraft(
            foodName: "Beef stew",
            foodCategory: .beef,
            dateFrozen: referenceDate,
            bestQualityDate: bestQualityDate,
            notes: "  "
        )

        XCTAssertEqual(
            draft.summaryItems(relativeTo: referenceDate),
            [
                ContainerSummaryItem(title: "Food name", value: "Beef stew"),
                ContainerSummaryItem(title: "Food type", value: "Beef"),
                ContainerSummaryItem(title: "Date frozen", value: "Today"),
                ContainerSummaryItem(title: "Best quality by", value: "9 August 2026"),
            ]
        )
    }

    func testSummaryItemsShowNotSetValuesAndIncludeNotesWhenPresent() {
        let calendar = Calendar(identifier: .gregorian)
        let referenceDate = calendar.date(from: DateComponents(year: 2026, month: 4, day: 9))!
        let frozenDate = calendar.date(from: DateComponents(year: 2026, month: 4, day: 7))!
        let draft = AddContainerDraft(
            foodName: "Vegetable soup",
            foodCategory: nil,
            dateFrozen: frozenDate,
            bestQualityDate: nil,
            notes: "Family dinner leftovers"
        )

        XCTAssertEqual(
            draft.summaryItems(relativeTo: referenceDate),
            [
                ContainerSummaryItem(title: "Food name", value: "Vegetable soup"),
                ContainerSummaryItem(title: "Food type", value: "Not set"),
                ContainerSummaryItem(title: "Date frozen", value: "7 April 2026"),
                ContainerSummaryItem(title: "Best quality by", value: "Not set"),
                ContainerSummaryItem(title: "Notes", value: "Family dinner leftovers"),
            ]
        )
    }
}
