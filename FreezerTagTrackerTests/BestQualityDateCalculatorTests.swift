import XCTest
@testable import FreezerTagTracker

final class BestQualityDateCalculatorTests: XCTestCase {
    func testSuggestedDateUsesPresetMonthsForFoodCategory() {
        let calendar = Calendar(identifier: .gregorian)
        let frozenOn = calendar.date(from: DateComponents(year: 2026, month: 4, day: 9))!
        let calculator = BestQualityDateCalculator(
            presetProvider: AddContainerSettingsStore(userDefaults: UserDefaults(suiteName: #function)!)
        )

        XCTAssertEqual(
            calculator.suggestedDate(for: .fish, frozenOn: frozenOn),
            calendar.date(byAdding: .month, value: 4, to: frozenOn)
        )
        XCTAssertEqual(
            calculator.suggestedDate(for: .poultry, frozenOn: frozenOn),
            calendar.date(byAdding: .month, value: 9, to: frozenOn)
        )
        XCTAssertNil(calculator.suggestedDate(for: .other, frozenOn: frozenOn))
    }

    func testPresetDescriptionReturnsReusableUiCopy() {
        let calculator = BestQualityDateCalculator(
            presetProvider: AddContainerSettingsStore(userDefaults: UserDefaults(suiteName: #function)!)
        )

        XCTAssertEqual(calculator.presetDescription(for: .beef), "Suggested date based on USDA guidance")
        XCTAssertEqual(calculator.presetDescription(for: .other), "No automatic date")
    }

    func testPresetDescriptionMatchesPresetSuggestionCopy() {
        let store = AddContainerSettingsStore(userDefaults: UserDefaults(suiteName: #function)!)
        let calculator = BestQualityDateCalculator(presetProvider: store)

        XCTAssertEqual(calculator.presetDescription(for: .preparedMeal), store.preset(for: .preparedMeal).suggestionCopy)
    }

    func testSuggestedDateUsesSavedPresetOverrideWhenPresent() {
        let calendar = Calendar(identifier: .gregorian)
        let frozenOn = calendar.date(from: DateComponents(year: 2026, month: 4, day: 9))!
        let userDefaults = UserDefaults(suiteName: #function)!
        userDefaults.removePersistentDomain(forName: #function)

        let store = AddContainerSettingsStore(userDefaults: userDefaults)
        store.save(AddContainerSettings(presetOverrides: [.beef: 6]))
        let calculator = BestQualityDateCalculator(presetProvider: store)

        XCTAssertEqual(
            calculator.suggestedDate(for: .beef, frozenOn: frozenOn),
            calendar.date(byAdding: .month, value: 6, to: frozenOn)
        )
    }
}
