import XCTest
@testable import FreezerTagTracker

final class AddContainerSettingsStoreTests: XCTestCase {
    private var userDefaults: UserDefaults!
    private var store: AddContainerSettingsStore!

    override func setUp() {
        super.setUp()
        userDefaults = UserDefaults(suiteName: #file)
        userDefaults.removePersistentDomain(forName: #file)
        store = AddContainerSettingsStore(userDefaults: userDefaults)
    }

    override func tearDown() {
        userDefaults.removePersistentDomain(forName: #file)
        store = nil
        userDefaults = nil
        super.tearDown()
    }

    func testLoadReturnsDefaultSettingsWhenNothingPersisted() {
        let settings = store.load()

        XCTAssertEqual(
            settings,
            AddContainerSettings(
                spokenGuidanceEnabled: true,
                spokenConfirmationsEnabled: true,
                hapticsEnabled: true,
                microphoneShortcutEnabled: true,
                showReadDetailsAgainButton: true,
                language: .english,
                presetOverrides: [:]
            )
        )

        XCTAssertEqual(store.preset(for: .beef).recommendedStorageMonths, 4)
        XCTAssertEqual(store.preset(for: .fish).recommendedStorageMonths, 4)
        XCTAssertEqual(store.preset(for: .poultry).recommendedStorageMonths, 9)
        XCTAssertEqual(store.preset(for: .pastries).recommendedStorageMonths, 2)
        XCTAssertEqual(store.preset(for: .vegetables).recommendedStorageMonths, 8)
        XCTAssertEqual(store.preset(for: .other).recommendedStorageMonths, 0)
    }

    func testSavePersistsSettingsAndPresetOverrides() {
        let settings = AddContainerSettings(
            spokenGuidanceEnabled: false,
            spokenConfirmationsEnabled: true,
            hapticsEnabled: false,
            microphoneShortcutEnabled: true,
            showReadDetailsAgainButton: false,
            language: .norwegian,
            presetOverrides: [.beef: 6, .pastries: 2]
        )

        store.save(settings)

        let loaded = store.load()

        XCTAssertEqual(loaded, settings)
        XCTAssertEqual(store.preset(for: .beef).recommendedStorageMonths, 6)
        XCTAssertEqual(store.preset(for: .pastries).recommendedStorageMonths, 2)
        XCTAssertEqual(store.preset(for: .fish).recommendedStorageMonths, 4)
    }

    func testSetPresetOverrideCanUpdateAndClearSingleCategory() {
        store.setPresetOverride(6, for: .beef)

        XCTAssertEqual(store.presetOverride(for: .beef), 6)
        XCTAssertEqual(store.preset(for: .beef).recommendedStorageMonths, 6)

        store.setPresetOverride(nil, for: .beef)

        XCTAssertNil(store.presetOverride(for: .beef))
        XCTAssertEqual(store.preset(for: .beef).recommendedStorageMonths, 4)
    }
}
