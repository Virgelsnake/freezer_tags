import XCTest
@testable import FreezerTagTracker

final class ContainerViewModelTests: XCTestCase {
    var viewModel: ContainerViewModel!
    var mockDataStore: DataStore!
    
    override func setUpWithError() throws {
        mockDataStore = DataStore(inMemory: true)
        viewModel = ContainerViewModel(dataStore: mockDataStore)
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
        mockDataStore = nil
    }
    
    func testInitialState() throws {
        XCTAssertEqual(viewModel.containers.count, 0)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertNil(viewModel.currentContainer)
    }
    
    func testLoadContainers() throws {
        let record1 = ContainerRecord(
            tagID: "tag-001",
            foodName: "Chicken Soup",
            dateFrozen: Date(),
            notes: nil
        )
        
        let record2 = ContainerRecord(
            tagID: "tag-002",
            foodName: "Beef Stew",
            dateFrozen: Date(),
            notes: nil
        )
        
        try mockDataStore.save(record: record1)
        try mockDataStore.save(record: record2)
        
        viewModel.loadContainers()
        
        XCTAssertEqual(viewModel.containers.count, 2)
    }
    
    func testSaveContainerSuccess() throws {
        let tagID = "test-tag-123"
        let foodName = "Test Food"
        let dateFrozen = Date()
        let notes = "Test notes"
        
        let expectation = self.expectation(description: "Save container")
        
        viewModel.saveContainer(
            tagID: tagID,
            foodName: foodName,
            foodCategory: .preparedMeal,
            dateFrozen: dateFrozen,
            notes: notes
        ) { result in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Expected success but got error: \(error)")
            }
        }
        
        waitForExpectations(timeout: 1.0)
        
        let saved = mockDataStore.fetch(byTagID: tagID)
        XCTAssertNotNil(saved)
        XCTAssertEqual(saved?.foodName, foodName)
        XCTAssertEqual(saved?.foodCategory, .preparedMeal)
        XCTAssertEqual(saved?.notes, notes)
    }
    
    func testSaveContainerWithInvalidData() throws {
        let expectation = self.expectation(description: "Save fails with invalid data")
        
        viewModel.saveContainer(
            tagID: "",
            foodName: "",
            dateFrozen: Date(),
            notes: nil
        ) { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure:
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testFetchContainerByTagID() throws {
        let record = ContainerRecord(
            tagID: "fetch-test",
            foodName: "Fetch Test Food",
            dateFrozen: Date(),
            notes: "Fetch test notes"
        )
        
        try mockDataStore.save(record: record)
        
        let fetched = viewModel.fetchContainer(byTagID: "fetch-test")
        XCTAssertNotNil(fetched)
        XCTAssertEqual(fetched?.foodName, "Fetch Test Food")
    }
    
    func testFetchNonExistentContainer() throws {
        let fetched = viewModel.fetchContainer(byTagID: "non-existent")
        XCTAssertNil(fetched)
    }
    
    func testUpdateContainer() throws {
        var record = ContainerRecord(
            tagID: "update-test",
            foodName: "Original Food",
            dateFrozen: Date(),
            notes: "Original notes"
        )
        
        try mockDataStore.save(record: record)
        
        record.foodName = "Updated Food"
        record.notes = "Updated notes"
        
        let expectation = self.expectation(description: "Update container")
        
        viewModel.updateContainer(record: record) { result in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Expected success but got error: \(error)")
            }
        }
        
        waitForExpectations(timeout: 1.0)
        
        let updated = mockDataStore.fetch(byTagID: "update-test")
        XCTAssertEqual(updated?.foodName, "Updated Food")
        XCTAssertEqual(updated?.notes, "Updated notes")
    }
    
    func testClearContainer() throws {
        let record = ContainerRecord(
            tagID: "clear-test",
            foodName: "To Be Cleared",
            dateFrozen: Date(),
            notes: "Some notes"
        )
        
        try mockDataStore.save(record: record)
        
        let expectation = self.expectation(description: "Clear container")
        
        viewModel.clearContainer(tagID: "clear-test") { result in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Expected success but got error: \(error)")
            }
        }
        
        waitForExpectations(timeout: 1.0)
        
        let cleared = mockDataStore.fetch(byTagID: "clear-test")
        XCTAssertTrue(cleared?.isCleared ?? false)
    }
    
    func testDeleteContainer() throws {
        let record = ContainerRecord(
            tagID: "delete-test",
            foodName: "To Be Deleted",
            dateFrozen: Date(),
            notes: nil
        )
        
        try mockDataStore.save(record: record)
        
        let expectation = self.expectation(description: "Delete container")
        
        viewModel.deleteContainer(record: record) { result in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Expected success but got error: \(error)")
            }
        }
        
        waitForExpectations(timeout: 1.0)
        
        let deleted = mockDataStore.fetch(byTagID: "delete-test")
        XCTAssertNil(deleted)
    }
    
    func testErrorHandling() throws {
        let expectation = self.expectation(description: "Error handling")
        
        viewModel.setError("Test error message")
        
        DispatchQueue.main.async {
            XCTAssertEqual(self.viewModel.errorMessage, "Test error message")
            
            self.viewModel.clearError()
            
            DispatchQueue.main.async {
                XCTAssertNil(self.viewModel.errorMessage)
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testLoadingState() throws {
        let expectation = self.expectation(description: "Loading state")
        
        XCTAssertFalse(viewModel.isLoading)
        
        viewModel.setLoading(true)
        
        DispatchQueue.main.async {
            XCTAssertTrue(self.viewModel.isLoading)
            
            self.viewModel.setLoading(false)
            
            DispatchQueue.main.async {
                XCTAssertFalse(self.viewModel.isLoading)
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1.0)
    }

    func testHandleScanScreenAppearedSpeaksReadyToScanWhenVoiceOverIsOff() {
        let speech = RecordingSpokenFeedbackService()
        let announcements = RecordingAccessibilityAnnouncementService()
        let viewModel = ContainerViewModel(
            dataStore: mockDataStore,
            addContainerSettingsStore: InMemoryAddContainerSettingsStore(),
            spokenFeedbackService: speech,
            accessibilityAnnouncementService: announcements,
            accessibilityStatusProvider: StubAccessibilityStatusProvider(isVoiceOverRunning: false)
        )

        viewModel.handleScanScreenAppeared()

        XCTAssertEqual(speech.messages, [AppLanguage.english.strings.readyToScan])
        XCTAssertEqual(announcements.messages, [])
    }

    func testHandleScanScreenAppearedUsesVoiceOverAnnouncementWhenVoiceOverIsOn() {
        let speech = RecordingSpokenFeedbackService()
        let announcements = RecordingAccessibilityAnnouncementService()
        let viewModel = ContainerViewModel(
            dataStore: mockDataStore,
            addContainerSettingsStore: InMemoryAddContainerSettingsStore(),
            spokenFeedbackService: speech,
            accessibilityAnnouncementService: announcements,
            accessibilityStatusProvider: StubAccessibilityStatusProvider(isVoiceOverRunning: true)
        )

        viewModel.handleScanScreenAppeared()

        XCTAssertEqual(speech.messages, [])
        XCTAssertEqual(announcements.messages, [AppLanguage.english.strings.readyToScan])
    }

    func testHandleScanScreenAppearedRespectsSpokenGuidanceSetting() {
        let speech = RecordingSpokenFeedbackService()
        let announcements = RecordingAccessibilityAnnouncementService()
        let viewModel = ContainerViewModel(
            dataStore: mockDataStore,
            addContainerSettingsStore: InMemoryAddContainerSettingsStore(
                settings: AddContainerSettings(spokenGuidanceEnabled: false)
            ),
            spokenFeedbackService: speech,
            accessibilityAnnouncementService: announcements,
            accessibilityStatusProvider: StubAccessibilityStatusProvider(isVoiceOverRunning: false)
        )

        viewModel.handleScanScreenAppeared()

        XCTAssertEqual(speech.messages, [])
        XCTAssertEqual(announcements.messages, [])
    }
}

private final class InMemoryAddContainerSettingsStore: AddContainerSettingsProviding {
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

private final class RecordingSpokenFeedbackService: SpokenFeedbackServing {
    private(set) var messages: [String] = []

    func speak(_ message: String, language: AppLanguage) {
        messages.append(message)
    }
}

private final class RecordingAccessibilityAnnouncementService: AccessibilityAnnouncementServing {
    private(set) var messages: [String] = []

    func announce(_ message: String, language: AppLanguage) {
        messages.append(message)
    }
}

private struct StubAccessibilityStatusProvider: AccessibilityStatusProviding {
    let isVoiceOverRunning: Bool
}
