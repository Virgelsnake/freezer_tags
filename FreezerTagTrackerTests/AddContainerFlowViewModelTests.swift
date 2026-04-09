import XCTest
@testable import FreezerTagTracker

final class AddContainerFlowViewModelTests: XCTestCase {
    func testAvailablePresetsMatchesExpectedOrder() {
        let viewModel = AddContainerFlowViewModel()

        XCTAssertEqual(
            viewModel.availablePresets.map(\.category),
            [.beef, .poultry, .fish, .preparedMeal, .pastries, .vegetables, .other]
        )
    }

    func testGoToReviewWithEmptyFoodNameStaysOnDetailsAndSetsValidationMessage() {
        let viewModel = AddContainerFlowViewModel()

        XCTAssertNil(viewModel.writeResult)

        viewModel.goToReview()

        XCTAssertEqual(viewModel.step, .details)
        XCTAssertEqual(viewModel.validationMessage, "Food name is required.")
    }

    func testGoToReviewWithFoodNameAdvancesToReviewAndClearsValidationMessage() {
        let draft = AddContainerDraft(foodName: "Beef Stew")
        let viewModel = AddContainerFlowViewModel(draft: draft)
        viewModel.validationMessage = "Old error"

        viewModel.goToReview()

        XCTAssertEqual(viewModel.step, .review)
        XCTAssertNil(viewModel.validationMessage)
    }

    func testSelectPresetSetsFoodCategoryAndSuggestedBestQualityDate() {
        let calendar = Calendar(identifier: .gregorian)
        let dateFrozen = calendar.date(from: DateComponents(year: 2026, month: 4, day: 9))!
        let viewModel = AddContainerFlowViewModel(draft: AddContainerDraft(dateFrozen: dateFrozen))

        viewModel.selectPreset(.beef)

        XCTAssertEqual(viewModel.draft.foodCategory, .beef)
        XCTAssertEqual(
            viewModel.draft.bestQualityDate,
            calendar.date(byAdding: .month, value: 4, to: dateFrozen)
        )
        XCTAssertFalse(viewModel.draft.isBestQualityDateManuallyEdited)
    }

    func testUpdateDateFrozenRefreshesSuggestedBestQualityDateWhenNotManuallyEdited() {
        let calendar = Calendar(identifier: .gregorian)
        let dateFrozen = calendar.date(from: DateComponents(year: 2026, month: 4, day: 9))!
        let updatedDateFrozen = calendar.date(from: DateComponents(year: 2026, month: 5, day: 1))!
        let viewModel = AddContainerFlowViewModel(draft: AddContainerDraft(dateFrozen: dateFrozen))

        viewModel.selectPreset(.poultry)
        viewModel.updateDateFrozen(updatedDateFrozen)

        XCTAssertEqual(viewModel.draft.dateFrozen, updatedDateFrozen)
        XCTAssertEqual(
            viewModel.draft.bestQualityDate,
            calendar.date(byAdding: .month, value: 9, to: updatedDateFrozen)
        )
    }

    func testUpdateDateFrozenPreservesManualBestQualityDateOverride() {
        let calendar = Calendar(identifier: .gregorian)
        let dateFrozen = calendar.date(from: DateComponents(year: 2026, month: 4, day: 9))!
        let updatedDateFrozen = calendar.date(from: DateComponents(year: 2026, month: 5, day: 1))!
        let manualBestQualityDate = calendar.date(from: DateComponents(year: 2026, month: 12, day: 25))!
        let viewModel = AddContainerFlowViewModel(draft: AddContainerDraft(dateFrozen: dateFrozen))

        viewModel.selectPreset(.beef)
        viewModel.updateBestQualityDate(manualBestQualityDate)
        viewModel.updateDateFrozen(updatedDateFrozen)

        XCTAssertTrue(viewModel.draft.isBestQualityDateManuallyEdited)
        XCTAssertEqual(viewModel.draft.bestQualityDate, manualBestQualityDate)
    }

    func testUpdateFoodNameClearsRequiredValidationMessage() {
        let viewModel = AddContainerFlowViewModel()

        viewModel.goToReview()
        viewModel.updateFoodName("Vegetable soup")

        XCTAssertNil(viewModel.validationMessage)
        XCTAssertEqual(viewModel.draft.foodName, "Vegetable soup")
    }

    func testUpdateNotesClampsToCharacterLimit() {
        let viewModel = AddContainerFlowViewModel()

        viewModel.updateNotes(String(repeating: "a", count: 250))

        XCTAssertEqual(viewModel.draft.notes.count, 200)
    }

    func testGoBackToDetailsReturnsToDetailsAndClearsValidationMessage() {
        let viewModel = AddContainerFlowViewModel(draft: AddContainerDraft(foodName: "Fish pie"))

        viewModel.goToReview()
        viewModel.validationMessage = "Old message"
        viewModel.goBackToDetails()

        XCTAssertEqual(viewModel.step, .details)
        XCTAssertNil(viewModel.validationMessage)
    }
}
