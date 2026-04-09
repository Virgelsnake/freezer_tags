import XCTest
@testable import FreezerTagTracker

final class SettingsViewModelTests: XCTestCase {
    func testLoadsPersistedSettingsAndPresets() {
        let store = InMemorySettingsStore(
            settings: AddContainerSettings(
                spokenGuidanceEnabled: false,
                spokenConfirmationsEnabled: true,
                hapticsEnabled: false,
                microphoneShortcutEnabled: true,
                showReadDetailsAgainButton: false,
                presetOverrides: [.beef: 6]
            )
        )

        let viewModel = SettingsViewModel(settingsStore: store)

        XCTAssertFalse(viewModel.spokenGuidanceEnabled)
        XCTAssertTrue(viewModel.spokenConfirmationsEnabled)
        XCTAssertFalse(viewModel.hapticsEnabled)
        XCTAssertEqual(viewModel.presetMonths(for: .beef), 6)
        XCTAssertNil(viewModel.presetMonths(for: .other))
    }

    func testUpdatingTogglesPersistsToStore() {
        let store = InMemorySettingsStore()
        let viewModel = SettingsViewModel(settingsStore: store)

        viewModel.spokenGuidanceEnabled = false
        viewModel.hapticsEnabled = false
        viewModel.showReadDetailsAgainButton = false
        viewModel.persistSettings()

        let saved = store.load()
        XCTAssertFalse(saved.spokenGuidanceEnabled)
        XCTAssertFalse(saved.hapticsEnabled)
        XCTAssertFalse(saved.showReadDetailsAgainButton)
    }

    func testUpdatingPresetMonthsAndResettingDefaultsPersistsExpectedValues() {
        let store = InMemorySettingsStore()
        let viewModel = SettingsViewModel(settingsStore: store)

        viewModel.updatePresetMonths(6, for: .beef)
        viewModel.updatePresetMonths(5, for: .preparedMeal)

        XCTAssertEqual(store.load().presetOverrides[.beef], 6)
        XCTAssertEqual(store.load().presetOverrides[.preparedMeal], 5)
        XCTAssertEqual(viewModel.presetMonths(for: .beef), 6)

        viewModel.resetPresetDefaults()

        XCTAssertEqual(store.load().presetOverrides, [:])
        XCTAssertEqual(viewModel.presetMonths(for: .beef), 4)
        XCTAssertEqual(viewModel.presetMonths(for: .preparedMeal), 3)
    }
}

private final class InMemorySettingsStore: AddContainerSettingsProviding {
    private var settings: AddContainerSettings

    init(settings: AddContainerSettings = AddContainerSettings()) {
        self.settings = settings
    }

    func load() -> AddContainerSettings {
        settings
    }

    func save(_ settings: AddContainerSettings) {
        self.settings = settings
    }

    func preset(for category: FoodCategory) -> FoodCategoryPreset {
        presets().first(where: { $0.category == category })!
    }

    func presets() -> [FoodCategoryPreset] {
        let overrides = settings.presetOverrides

        return AddContainerSettingsStore.defaultPresets.map { preset in
            FoodCategoryPreset(
                category: preset.category,
                displayName: preset.displayName,
                recommendedStorageMonths: overrides[preset.category] ?? preset.recommendedStorageMonths
            )
        }
    }
}
