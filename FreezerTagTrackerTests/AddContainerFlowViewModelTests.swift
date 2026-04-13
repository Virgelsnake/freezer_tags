import XCTest
@testable import FreezerTagTracker

final class AddContainerFlowViewModelTests: XCTestCase {
    func testWriteToTagStartsWritingAndBuildsRecordFromDraft() throws {
        let calendar = Calendar(identifier: .gregorian)
        let dateFrozen = calendar.date(from: DateComponents(year: 2026, month: 4, day: 9))!
        let bestQualityDate = calendar.date(from: DateComponents(year: 2026, month: 8, day: 9))!
        let writer = RecordingTagWriter()
        let store = RecordingRecordStore()
        let viewModel = makeViewModel(
            draft: AddContainerDraft(
                foodName: "  Beef stew  ",
                foodCategory: .beef,
                dateFrozen: dateFrozen,
                bestQualityDate: bestQualityDate,
                notes: "  Family dinner leftovers  "
            ),
            tagWriter: writer,
            recordStore: store
        )

        viewModel.goToReview()
        viewModel.writeToTag()

        XCTAssertEqual(viewModel.step, .writing)
        XCTAssertNil(viewModel.writeResult)
        XCTAssertEqual(store.savedRecords.count, 0)

        let writtenRecord = try XCTUnwrap(writer.writtenRecords.first)
        XCTAssertEqual(writtenRecord.foodName, "Beef stew")
        XCTAssertEqual(writtenRecord.foodCategory, .beef)
        XCTAssertEqual(writtenRecord.dateFrozen, dateFrozen)
        XCTAssertEqual(writtenRecord.bestBeforeDate, bestQualityDate)
        XCTAssertEqual(writtenRecord.notes, "Family dinner leftovers")
    }

    func testWriteToTagSuccessPersistsRecordAndShowsSuccessState() throws {
        let writer = RecordingTagWriter(results: [.success(())])
        let store = RecordingRecordStore()
        let viewModel = makeViewModel(
            draft: AddContainerDraft(foodName: "Chicken soup"),
            tagWriter: writer,
            recordStore: store
        )

        viewModel.goToReview()
        viewModel.writeToTag()

        XCTAssertEqual(viewModel.step, .success)
        XCTAssertEqual(store.savedRecords.count, 1)
        XCTAssertEqual(store.savedRecords.first, writer.writtenRecords.first)

        let resultRecord = try XCTUnwrap(viewModel.completedRecord)
        XCTAssertEqual(viewModel.writeResult, .success(record: resultRecord))
    }

    func testWriteToTagFailureShowsFailureStateWithoutSavingAndPreservesDraft() {
        let writer = RecordingTagWriter(results: [.failure(NFCError.writeFailed)])
        let store = RecordingRecordStore()
        let originalDraft = AddContainerDraft(
            foodName: "Fish pie",
            foodCategory: .fish,
            notes: "Use the blue lid"
        )
        let viewModel = makeViewModel(
            draft: originalDraft,
            tagWriter: writer,
            recordStore: store
        )

        viewModel.goToReview()
        viewModel.writeToTag()

        XCTAssertEqual(viewModel.step, .failure)
        XCTAssertEqual(viewModel.writeResult, .failure(message: NFCError.writeFailed.localizedDescription))
        XCTAssertEqual(store.savedRecords.count, 0)
        XCTAssertEqual(viewModel.draft, originalDraft)
    }

    func testRetryWriteFromFailureStartsAnotherAttemptWithoutReenteringDraft() {
        let writer = RecordingTagWriter(results: [.failure(NFCError.writeFailed), .success(())])
        let store = RecordingRecordStore()
        let viewModel = makeViewModel(
            draft: AddContainerDraft(foodName: "Vegetable curry"),
            tagWriter: writer,
            recordStore: store
        )

        viewModel.goToReview()
        viewModel.writeToTag()

        XCTAssertEqual(viewModel.step, .failure)

        viewModel.retryWrite()

        XCTAssertEqual(writer.writtenRecords.count, 2)
        XCTAssertEqual(writer.writtenRecords[0].tagID, writer.writtenRecords[1].tagID)
        XCTAssertEqual(viewModel.step, .success)
        XCTAssertEqual(store.savedRecords.count, 1)
    }

    func testGoBackFromFailureReturnsToReviewAndClearsFailureResult() {
        let writer = RecordingTagWriter(results: [.failure(NFCError.writeFailed)])
        let store = RecordingRecordStore()
        let viewModel = makeViewModel(
            draft: AddContainerDraft(foodName: "Pastries"),
            tagWriter: writer,
            recordStore: store
        )

        viewModel.goToReview()
        viewModel.writeToTag()
        viewModel.goBackToReview()

        XCTAssertEqual(viewModel.step, .review)
        XCTAssertNil(viewModel.writeResult)
    }

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

    func testPresetStatusMessageIsNilWithoutSelection() {
        let viewModel = AddContainerFlowViewModel()

        XCTAssertNil(viewModel.presetStatusMessage)
    }

    func testPresetStatusMessageUsesApprovedCopyAfterPresetSelection() {
        let viewModel = AddContainerFlowViewModel()

        viewModel.selectPreset(.beef)

        XCTAssertEqual(viewModel.presetStatusMessage, "Best-quality date added from USDA guidance.")
    }

    func testPresetStatusMessageChangesAfterManualDateEdit() {
        let calendar = Calendar(identifier: .gregorian)
        let manualDate = calendar.date(from: DateComponents(year: 2026, month: 12, day: 25))!
        let viewModel = AddContainerFlowViewModel()

        viewModel.selectPreset(.poultry)
        viewModel.updateBestQualityDate(manualDate)

        XCTAssertEqual(viewModel.presetStatusMessage, "Date changed")
    }

    func testSelectPresetSpeaksGuidanceAndPlaysSelectionHapticWhenVoiceOverIsOff() {
        let speech = RecordingSpokenFeedbackService()
        let announcements = RecordingAccessibilityAnnouncementService()
        let haptics = RecordingHapticsService()
        let settingsStore = InMemoryAddContainerSettingsStore()
        let viewModel = makeViewModel(
            draft: AddContainerDraft(),
            tagWriter: RecordingTagWriter(),
            recordStore: RecordingRecordStore(),
            settingsStore: settingsStore,
            spokenFeedbackService: speech,
            accessibilityAnnouncementService: announcements,
            hapticsService: haptics,
            accessibilityStatusProvider: StubAccessibilityStatusProvider(isVoiceOverRunning: false)
        )

        viewModel.selectPreset(.beef)

        XCTAssertEqual(speech.messages, ["Beef selected. Best-quality date added."])
        XCTAssertEqual(announcements.messages, [])
        XCTAssertEqual(haptics.events, [.presetSelection])
    }

    func testHandleDetailsScreenAppearedUsesVoiceOverAnnouncementWithoutCustomSpeech() {
        let speech = RecordingSpokenFeedbackService()
        let announcements = RecordingAccessibilityAnnouncementService()
        let viewModel = makeViewModel(
            draft: AddContainerDraft(),
            tagWriter: RecordingTagWriter(),
            recordStore: RecordingRecordStore(),
            spokenFeedbackService: speech,
            accessibilityAnnouncementService: announcements,
            accessibilityStatusProvider: StubAccessibilityStatusProvider(isVoiceOverRunning: true)
        )

        viewModel.handleDetailsScreenAppeared()

        XCTAssertEqual(speech.messages, [])
        XCTAssertEqual(announcements.messages, ["Add a container. Tell us what you are freezing."])
    }

    func testHandleDetailsScreenAppearedRefreshesSettingsDependentUiState() {
        let settingsStore = InMemoryAddContainerSettingsStore()
        let viewModel = makeViewModel(
            draft: AddContainerDraft(),
            tagWriter: RecordingTagWriter(),
            recordStore: RecordingRecordStore(),
            settingsStore: settingsStore
        )

        XCTAssertTrue(viewModel.showsMicrophoneShortcut)

        settingsStore.save(
            AddContainerSettings(
                spokenGuidanceEnabled: true,
                spokenConfirmationsEnabled: true,
                hapticsEnabled: true,
                microphoneShortcutEnabled: false,
                showReadDetailsAgainButton: true
            )
        )

        viewModel.handleDetailsScreenAppeared()

        XCTAssertFalse(viewModel.showsMicrophoneShortcut)
    }

    func testHandleDetailsScreenAppearedKeepsInjectedSettingsSnapshot() {
        let settingsStore = InMemoryAddContainerSettingsStore(
            settings: AddContainerSettings(
                spokenGuidanceEnabled: true,
                spokenConfirmationsEnabled: true,
                hapticsEnabled: true,
                microphoneShortcutEnabled: true,
                showReadDetailsAgainButton: true
            )
        )
        let injectedSettings = AddContainerSettings(
            spokenGuidanceEnabled: true,
            spokenConfirmationsEnabled: true,
            hapticsEnabled: true,
            microphoneShortcutEnabled: false,
            showReadDetailsAgainButton: false
        )
        let viewModel = makeViewModel(
            draft: AddContainerDraft(),
            initialSettings: injectedSettings,
            tagWriter: RecordingTagWriter(),
            recordStore: RecordingRecordStore(),
            settingsStore: settingsStore
        )

        viewModel.handleDetailsScreenAppeared()

        XCTAssertFalse(viewModel.showsMicrophoneShortcut)
        XCTAssertFalse(viewModel.canReplaySuccessDetails)
    }

    func testGoToReviewAdvancesToReviewAndPlaysPrimaryAction() {
        let speech = RecordingSpokenFeedbackService()
        let haptics = RecordingHapticsService()
        let viewModel = makeViewModel(
            draft: AddContainerDraft(foodName: "Chicken soup"),
            tagWriter: RecordingTagWriter(),
            recordStore: RecordingRecordStore(),
            spokenFeedbackService: speech,
            hapticsService: haptics
        )

        viewModel.goToReview()

        XCTAssertEqual(viewModel.step, .review)
        XCTAssertEqual(speech.messages, [])
        XCTAssertEqual(haptics.events, [.primaryAction])
    }

    func testReviewReplayMessageIncludesDatesWhenBestQualityDateExists() {
        let calendar = Calendar(identifier: .gregorian)
        let dateFrozen = calendar.date(from: DateComponents(year: 2026, month: 4, day: 9))!
        let bestQualityDate = calendar.date(from: DateComponents(year: 2026, month: 8, day: 9))!
        let viewModel = makeViewModel(
            draft: AddContainerDraft(
                foodName: "Beef curry",
                dateFrozen: dateFrozen,
                bestQualityDate: bestQualityDate
            ),
            tagWriter: RecordingTagWriter(),
            recordStore: RecordingRecordStore()
        )

        XCTAssertEqual(
            viewModel.reviewReplayMessage,
            "Review and write. Beef curry. Frozen 9 Apr 2026. Best quality by 9 Aug 2026."
        )
    }

    func testReviewReplayMessageUsesMissingDateCopyWhenBestQualityDateIsNotSet() {
        let calendar = Calendar(identifier: .gregorian)
        let dateFrozen = calendar.date(from: DateComponents(year: 2026, month: 4, day: 9))!
        let viewModel = makeViewModel(
            draft: AddContainerDraft(
                foodName: "Beef curry",
                dateFrozen: dateFrozen
            ),
            tagWriter: RecordingTagWriter(),
            recordStore: RecordingRecordStore()
        )

        XCTAssertEqual(
            viewModel.reviewReplayMessage,
            "Review and write. Beef curry. Frozen 9 Apr 2026. No best-quality date set."
        )
    }

    func testReviewReplayMessageAppendsNotesWhenPresent() {
        let calendar = Calendar(identifier: .gregorian)
        let dateFrozen = calendar.date(from: DateComponents(year: 2026, month: 4, day: 9))!
        let viewModel = makeViewModel(
            draft: AddContainerDraft(
                foodName: "Beef curry",
                dateFrozen: dateFrozen,
                notes: "Use first"
            ),
            tagWriter: RecordingTagWriter(),
            recordStore: RecordingRecordStore()
        )

        XCTAssertEqual(
            viewModel.reviewReplayMessage,
            "Review and write. Beef curry. Frozen 9 Apr 2026. No best-quality date set. Notes: Use first."
        )
    }

    func testReviewReplayMessageOmitsNotesWhenBlank() {
        let calendar = Calendar(identifier: .gregorian)
        let dateFrozen = calendar.date(from: DateComponents(year: 2026, month: 4, day: 9))!
        let viewModel = makeViewModel(
            draft: AddContainerDraft(
                foodName: "Beef curry",
                dateFrozen: dateFrozen,
                notes: "   "
            ),
            tagWriter: RecordingTagWriter(),
            recordStore: RecordingRecordStore()
        )

        XCTAssertEqual(
            viewModel.reviewReplayMessage,
            "Review and write. Beef curry. Frozen 9 Apr 2026. No best-quality date set."
        )
    }

    func testHandleReviewScreenAppearedSpeaksReviewSummaryWhenGuidanceIsEnabled() {
        let calendar = Calendar(identifier: .gregorian)
        let dateFrozen = calendar.date(from: DateComponents(year: 2026, month: 4, day: 10))!
        let speech = RecordingSpokenFeedbackService()
        let viewModel = makeViewModel(
            draft: AddContainerDraft(foodName: "Chicken soup", dateFrozen: dateFrozen),
            tagWriter: RecordingTagWriter(),
            recordStore: RecordingRecordStore(),
            spokenFeedbackService: speech
        )

        viewModel.goToReview()
        viewModel.handleReviewScreenAppeared()

        XCTAssertEqual(speech.messages, ["Review and write. Chicken soup. Frozen 10 Apr 2026. No best-quality date set."])
    }

    func testHandleReviewScreenAppearedDoesNotSpeakWhenGuidanceIsDisabled() {
        let speech = RecordingSpokenFeedbackService()
        let settingsStore = InMemoryAddContainerSettingsStore(
            settings: AddContainerSettings(spokenGuidanceEnabled: false)
        )
        let viewModel = makeViewModel(
            draft: AddContainerDraft(foodName: "Chicken soup"),
            tagWriter: RecordingTagWriter(),
            recordStore: RecordingRecordStore(),
            settingsStore: settingsStore,
            spokenFeedbackService: speech
        )

        viewModel.goToReview()
        viewModel.handleReviewScreenAppeared()

        XCTAssertEqual(speech.messages, [])
        XCTAssertFalse(viewModel.canReplayReviewDetails)
    }

    func testHandleReviewScreenAppearedUsesVoiceOverAnnouncementWithoutCustomSpeech() {
        let calendar = Calendar(identifier: .gregorian)
        let dateFrozen = calendar.date(from: DateComponents(year: 2026, month: 4, day: 10))!
        let speech = RecordingSpokenFeedbackService()
        let announcements = RecordingAccessibilityAnnouncementService()
        let viewModel = makeViewModel(
            draft: AddContainerDraft(foodName: "Chicken soup", dateFrozen: dateFrozen),
            tagWriter: RecordingTagWriter(),
            recordStore: RecordingRecordStore(),
            spokenFeedbackService: speech,
            accessibilityAnnouncementService: announcements,
            accessibilityStatusProvider: StubAccessibilityStatusProvider(isVoiceOverRunning: true)
        )

        viewModel.goToReview()
        viewModel.handleReviewScreenAppeared()

        XCTAssertEqual(speech.messages, [])
        XCTAssertEqual(announcements.messages, ["Review and write. Chicken soup. Frozen 10 Apr 2026. No best-quality date set."])
    }

    func testReadReviewDetailsAgainSpeaksReviewSummary() throws {
        let speech = RecordingSpokenFeedbackService()
        let viewModel = makeViewModel(
            draft: AddContainerDraft(foodName: "Chicken soup"),
            tagWriter: RecordingTagWriter(),
            recordStore: RecordingRecordStore(),
            spokenFeedbackService: speech
        )

        viewModel.goToReview()
        speech.messages.removeAll()

        viewModel.readReviewDetailsAgain()

        XCTAssertEqual(speech.messages, [try XCTUnwrap(viewModel.reviewReplayMessage)])
    }

    func testReadReviewDetailsAgainRespectsSpokenGuidanceSetting() {
        let speech = RecordingSpokenFeedbackService()
        let settingsStore = InMemoryAddContainerSettingsStore(
            settings: AddContainerSettings(spokenGuidanceEnabled: false)
        )
        let viewModel = makeViewModel(
            draft: AddContainerDraft(foodName: "Chicken soup"),
            tagWriter: RecordingTagWriter(),
            recordStore: RecordingRecordStore(),
            settingsStore: settingsStore,
            spokenFeedbackService: speech
        )

        viewModel.goToReview()
        viewModel.readReviewDetailsAgain()

        XCTAssertEqual(speech.messages, [])
        XCTAssertFalse(viewModel.canReplayReviewDetails)
    }

    func testWriteSuccessSpeaksShortConfirmationBuildsReplaySummaryAndPlaysSuccessHaptic() {
        let speech = RecordingSpokenFeedbackService()
        let haptics = RecordingHapticsService()
        let writer = RecordingTagWriter(results: [.success(())])
        let store = RecordingRecordStore()
        let calendar = Calendar(identifier: .gregorian)
        let dateFrozen = calendar.date(from: DateComponents(year: 2026, month: 4, day: 9))!
        let bestQualityDate = calendar.date(from: DateComponents(year: 2026, month: 8, day: 9))!
        let viewModel = makeViewModel(
            draft: AddContainerDraft(
                foodName: "Beef stew",
                foodCategory: .beef,
                dateFrozen: dateFrozen,
                bestQualityDate: bestQualityDate
            ),
            tagWriter: writer,
            recordStore: store,
            spokenFeedbackService: speech,
            hapticsService: haptics
        )

        viewModel.goToReview()
        speech.messages.removeAll()
        haptics.events.removeAll()

        viewModel.writeToTag()

        XCTAssertEqual(viewModel.step, .success)
        XCTAssertEqual(speech.messages, ["Ready to write. Hold your iPhone near the tag.", "Saved. Tag updated."])
        XCTAssertEqual(haptics.events, [.writeStart, .writeSuccess])
        XCTAssertTrue(viewModel.canReplaySuccessDetails)
        XCTAssertTrue(viewModel.successReplayMessage?.contains("Beef stew") == true)
        XCTAssertTrue(viewModel.successReplayMessage?.contains("Tag updated successfully.") == true)
    }

    func testReadDetailsAgainSpeaksSavedSummaryAndPlaysReplayHaptic() throws {
        let speech = RecordingSpokenFeedbackService()
        let haptics = RecordingHapticsService()
        let writer = RecordingTagWriter(results: [.success(())])
        let store = RecordingRecordStore()
        let viewModel = makeViewModel(
            draft: AddContainerDraft(foodName: "Vegetable curry"),
            tagWriter: writer,
            recordStore: store,
            spokenFeedbackService: speech,
            hapticsService: haptics
        )

        viewModel.goToReview()
        viewModel.writeToTag()
        speech.messages.removeAll()
        haptics.events.removeAll()

        viewModel.readDetailsAgain()

        XCTAssertEqual(haptics.events, [.replayDetails])
        XCTAssertEqual(speech.messages, [try XCTUnwrap(viewModel.successReplayMessage)])
    }

    func testReadDetailsAgainRespectsSettingsToggle() {
        let speech = RecordingSpokenFeedbackService()
        let haptics = RecordingHapticsService()
        let writer = RecordingTagWriter(results: [.success(())])
        let store = RecordingRecordStore()
        let settingsStore = InMemoryAddContainerSettingsStore(
            settings: AddContainerSettings(showReadDetailsAgainButton: false)
        )
        let viewModel = makeViewModel(
            draft: AddContainerDraft(foodName: "Pastries"),
            tagWriter: writer,
            recordStore: store,
            settingsStore: settingsStore,
            spokenFeedbackService: speech,
            hapticsService: haptics
        )

        viewModel.goToReview()
        viewModel.writeToTag()
        speech.messages.removeAll()
        haptics.events.removeAll()
        viewModel.readDetailsAgain()

        XCTAssertFalse(viewModel.canReplaySuccessDetails)
        XCTAssertEqual(speech.messages, [])
        XCTAssertEqual(haptics.events, [])
    }

    func testWriteToTagSkipsGuidanceAndHapticsWhenSettingsDisableThem() {
        let speech = RecordingSpokenFeedbackService()
        let announcements = RecordingAccessibilityAnnouncementService()
        let haptics = RecordingHapticsService()
        let writer = RecordingTagWriter(results: [.success(())])
        let settingsStore = InMemoryAddContainerSettingsStore(
            settings: AddContainerSettings(
                spokenGuidanceEnabled: false,
                spokenConfirmationsEnabled: false,
                hapticsEnabled: false
            )
        )
        let viewModel = makeViewModel(
            draft: AddContainerDraft(foodName: "Lentil soup"),
            tagWriter: writer,
            recordStore: RecordingRecordStore(),
            settingsStore: settingsStore,
            spokenFeedbackService: speech,
            accessibilityAnnouncementService: announcements,
            hapticsService: haptics
        )

        viewModel.goToReview()
        viewModel.writeToTag()

        XCTAssertEqual(viewModel.step, .success)
        XCTAssertEqual(speech.messages, [])
        XCTAssertEqual(announcements.messages, [])
        XCTAssertEqual(haptics.events, [])
    }

    private func makeViewModel(
        draft: AddContainerDraft,
        initialSettings: AddContainerSettings? = nil,
        tagWriter: RecordingTagWriter,
        recordStore: RecordingRecordStore,
        settingsStore: InMemoryAddContainerSettingsStore = InMemoryAddContainerSettingsStore(),
        spokenFeedbackService: RecordingSpokenFeedbackService = RecordingSpokenFeedbackService(),
        accessibilityAnnouncementService: RecordingAccessibilityAnnouncementService = RecordingAccessibilityAnnouncementService(),
        hapticsService: RecordingHapticsService = RecordingHapticsService(),
        accessibilityStatusProvider: StubAccessibilityStatusProvider = StubAccessibilityStatusProvider(isVoiceOverRunning: false)
    ) -> AddContainerFlowViewModel {
        AddContainerFlowViewModel(
            draft: draft,
            initialSettings: initialSettings,
            presetProvider: settingsStore,
            settingsStore: settingsStore,
            tagWriter: tagWriter,
            recordStore: recordStore,
            spokenFeedbackService: spokenFeedbackService,
            accessibilityAnnouncementService: accessibilityAnnouncementService,
            hapticsService: hapticsService,
            accessibilityStatusProvider: accessibilityStatusProvider
        )
    }
}

private final class RecordingTagWriter: TagWriting {
    private(set) var writtenRecords: [ContainerRecord] = []
    var results: [Result<Void, Error>]

    init(results: [Result<Void, Error>] = []) {
        self.results = results
    }

    func writeTag(record: ContainerRecord, completion: @escaping (Result<Void, Error>) -> Void) {
        writtenRecords.append(record)

        guard !results.isEmpty else {
            return
        }

        completion(results.removeFirst())
    }
}

private final class RecordingRecordStore: ContainerRecordStoring {
    private(set) var savedRecords: [ContainerRecord] = []

    func save(record: ContainerRecord) throws {
        savedRecords.append(record)
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
    var messages: [String] = []

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

private final class RecordingHapticsService: HapticsServing {
    var events: [HapticsEvent] = []

    func play(_ event: HapticsEvent) {
        events.append(event)
    }
}

private struct StubAccessibilityStatusProvider: AccessibilityStatusProviding {
    let isVoiceOverRunning: Bool
}
