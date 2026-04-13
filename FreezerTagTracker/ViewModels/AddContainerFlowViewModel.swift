import Combine
import Foundation

protocol TagWriting {
    func writeTag(record: ContainerRecord, completion: @escaping (Result<Void, Error>) -> Void)
}

protocol ContainerRecordStoring {
    func save(record: ContainerRecord) throws
}

extension NFCManager: TagWriting {}
extension DataStore: ContainerRecordStoring {}

final class AddContainerFlowViewModel: ObservableObject {
    @Published var draft = AddContainerDraft()
    @Published var step: AddContainerStep = .details
    @Published var validationMessage: String?
    @Published var writeResult: TagWriteResult?
    @Published private var settings: AddContainerSettings

    private let presetProvider: FoodCategoryPresetProviding
    private let settingsStore: AddContainerSettingsProviding
    private let bestQualityDateCalculator: BestQualityDateCalculator
    private let tagWriter: TagWriting
    private let recordStore: ContainerRecordStoring
    private let spokenFeedbackService: SpokenFeedbackServing
    private let accessibilityAnnouncementService: AccessibilityAnnouncementServing
    private let hapticsService: HapticsServing
    private let accessibilityStatusProvider: AccessibilityStatusProviding
    private let refreshSettingsFromStore: Bool
    private var pendingRecord: ContainerRecord?

    init(
        draft: AddContainerDraft = AddContainerDraft(),
        initialSettings: AddContainerSettings? = nil,
        presetProvider: FoodCategoryPresetProviding = AddContainerSettingsStore(),
        settingsStore: AddContainerSettingsProviding = AddContainerSettingsStore(),
        tagWriter: TagWriting = NFCManager.shared,
        recordStore: ContainerRecordStoring = DataStore.shared,
        spokenFeedbackService: SpokenFeedbackServing = SpokenFeedbackService(),
        accessibilityAnnouncementService: AccessibilityAnnouncementServing = AccessibilityAnnouncementService(),
        hapticsService: HapticsServing = HapticsService(),
        accessibilityStatusProvider: AccessibilityStatusProviding = SystemAccessibilityStatusProvider()
    ) {
        let resolvedSettings = initialSettings ?? settingsStore.load()
        self.draft = draft
        self.presetProvider = presetProvider
        self.settingsStore = settingsStore
        self.settings = resolvedSettings
        self.refreshSettingsFromStore = initialSettings == nil
        self.bestQualityDateCalculator = BestQualityDateCalculator(presetProvider: presetProvider)
        self.tagWriter = tagWriter
        self.recordStore = recordStore
        self.spokenFeedbackService = spokenFeedbackService
        self.accessibilityAnnouncementService = accessibilityAnnouncementService
        self.hapticsService = hapticsService
        self.accessibilityStatusProvider = accessibilityStatusProvider
    }

    var availablePresets: [FoodCategoryPreset] {
        presetProvider.presets()
    }

    var canProceedToReview: Bool {
        draft.canProceedToReview
    }

    var showsMicrophoneShortcut: Bool {
        settings.microphoneShortcutEnabled
    }

    var canReplayReviewDetails: Bool {
        settings.spokenGuidanceEnabled && reviewReplayMessage != nil
    }

    var canReplaySuccessDetails: Bool {
        settings.showReadDetailsAgainButton && successReplayMessage != nil
    }

    var currentLanguage: AppLanguage {
        settings.language
    }

    var reviewReplayMessage: String? {
        guard !draft.trimmedFoodName.isEmpty else {
            return nil
        }

        let strings = settings.language.strings

        var components = [
            strings.reviewAndWrite,
            draft.trimmedFoodName,
            strings.frozenSummary(draft.dateFrozen, referenceDate: Date.distantPast)
        ]

        if let bestQualityDate = draft.bestQualityDate {
            components.append(strings.bestQualitySummary(bestQualityDate))
        } else {
            components.append(strings.noBestQualityDateSet)
        }

        let trimmedNotes = draft.notes.trimmingCharacters(in: .whitespacesAndNewlines)

        if !trimmedNotes.isEmpty {
            components.append(strings.notesSummary(trimmedNotes))
        }

        return components.joined(separator: ". ") + "."
    }

    var successReplayMessage: String? {
        guard let record = completedRecord else {
            return nil
        }

        return settings.language.strings.successReplay(
            foodName: record.foodName,
            frozenDate: record.dateFrozen,
            bestBeforeDate: record.bestBeforeDate
        )
    }

    var presetStatusMessage: String? {
        guard draft.foodCategory != nil else {
            return nil
        }

        if draft.isBestQualityDateManuallyEdited {
            return settings.language.strings.dateChangedStatus
        }

        guard draft.bestQualityDate != nil else {
            return nil
        }

        return settings.language.strings.presetDateAddedStatus
    }

    var completedRecord: ContainerRecord? {
        guard case .success(let record) = writeResult else {
            return nil
        }

        return record
    }

    func updateFoodName(_ foodName: String) {
        draft.foodName = foodName

        if !draft.trimmedFoodName.isEmpty, validationMessage == settings.language.strings.foodNameRequiredMessage {
            validationMessage = nil
        }
    }

    func updateDateFrozen(_ date: Date) {
        draft.dateFrozen = date

        guard let category = draft.foodCategory, !draft.isBestQualityDateManuallyEdited else {
            return
        }

        draft.bestQualityDate = bestQualityDateCalculator.suggestedDate(for: category, frozenOn: date)
    }

    func updateBestQualityDate(_ date: Date?) {
        draft.bestQualityDate = date
        draft.isBestQualityDateManuallyEdited = true
    }

    func updateNotes(_ notes: String) {
        draft.notes = String(notes.prefix(200))
    }

    func handleDetailsScreenAppeared() {
        refreshSettings()
        deliverGuidance(settings.language.strings.addContainerGuidance)
    }

    func handleReviewScreenAppeared() {
        refreshSettings()

        guard let reviewReplayMessage else {
            return
        }

        deliverGuidance(reviewReplayMessage)
    }

    func goToReview() {
        refreshSettings()

        guard !draft.trimmedFoodName.isEmpty else {
            validationMessage = settings.language.strings.foodNameRequiredMessage
            step = .details
            playHaptic(.validationError)
            deliverGuidance(settings.language.strings.foodNameRequiredToContinue)
            return
        }

        validationMessage = nil
        step = .review
        playHaptic(.primaryAction)
    }

    func goBackToDetails() {
        validationMessage = nil
        writeResult = nil
        pendingRecord = nil
        step = .details
    }

    func goBackToReview() {
        validationMessage = nil
        writeResult = nil
        pendingRecord = nil
        step = .review
    }

    func writeToTag() {
        refreshSettings()

        guard !draft.trimmedFoodName.isEmpty else {
            validationMessage = settings.language.strings.foodNameRequiredMessage
            step = .details
            return
        }

        validationMessage = nil
        writeResult = nil

        let record = pendingRecord ?? makeRecordFromDraft()
        pendingRecord = record
        step = .writing
        playHaptic(.writeStart)
        deliverGuidance(settings.language.strings.readyToWrite)

        tagWriter.writeTag(record: record) { [weak self] result in
            self?.handleWriteResult(result, for: record)
        }
    }

    func retryWrite() {
        writeToTag()
    }

    func selectPreset(_ category: FoodCategory) {
        refreshSettings()
        draft.foodCategory = category
        draft.isBestQualityDateManuallyEdited = false
        draft.bestQualityDate = bestQualityDateCalculator.suggestedDate(for: category, frozenOn: draft.dateFrozen)
        playHaptic(.presetSelection)
        deliverGuidance(messageForPresetSelection(category))
    }

    func readDetailsAgain() {
        refreshSettings()

        guard canReplaySuccessDetails, let message = successReplayMessage else {
            return
        }

        playHaptic(.replayDetails)
        deliverConfirmation(message)
    }

    func readReviewDetailsAgain() {
        refreshSettings()

        guard canReplayReviewDetails, let reviewReplayMessage else {
            return
        }

        deliverGuidance(reviewReplayMessage)
    }

    func persistCurrentSettings() {
        settingsStore.save(settings)
        refreshSettings()
    }

    private func playHaptic(_ event: HapticsEvent) {
        guard settings.hapticsEnabled else {
            return
        }

        hapticsService.play(event)
    }

    private func deliverGuidance(_ message: String) {
        guard settings.spokenGuidanceEnabled else {
            return
        }

        if accessibilityStatusProvider.isVoiceOverRunning {
            accessibilityAnnouncementService.announce(message, language: settings.language)
        } else {
            spokenFeedbackService.speak(message, language: settings.language)
        }
    }

    private func deliverConfirmation(_ message: String) {
        guard settings.spokenConfirmationsEnabled else {
            return
        }

        if accessibilityStatusProvider.isVoiceOverRunning {
            accessibilityAnnouncementService.announce(message, language: settings.language)
        } else {
            spokenFeedbackService.speak(message, language: settings.language)
        }
    }

    private func refreshSettings() {
        guard refreshSettingsFromStore else {
            return
        }

        settings = settingsStore.load()
    }

    private func messageForPresetSelection(_ category: FoodCategory) -> String {
        settings.language.strings.presetSelected(
            category,
            bestQualityAdded: bestQualityDateCalculator.suggestedDate(for: category, frozenOn: draft.dateFrozen) != nil
        )
    }

    private func makeRecordFromDraft() -> ContainerRecord {
        let trimmedNotes = draft.notes.trimmingCharacters(in: .whitespacesAndNewlines)

        return ContainerRecord(
            tagID: UUID().uuidString,
            foodName: draft.trimmedFoodName,
            foodCategory: draft.foodCategory,
            dateFrozen: draft.dateFrozen,
            notes: trimmedNotes.isEmpty ? nil : trimmedNotes,
            bestBeforeDate: draft.bestQualityDate
        )
    }

    private func handleWriteResult(_ result: Result<Void, Error>, for record: ContainerRecord) {
        let applyResult = { [weak self] in
            guard let self = self else {
                return
            }

            switch result {
            case .success:
                do {
                    try self.recordStore.save(record: record)
                    self.writeResult = .success(record: record)
                    self.pendingRecord = nil
                    self.step = .success
                    self.playHaptic(.writeSuccess)
                    self.deliverConfirmation(self.settings.language.strings.savedTagUpdated)
                } catch {
                    self.writeResult = .failure(message: error.localizedDescription)
                    self.step = .failure
                    self.playHaptic(.writeFailure)
                    self.deliverConfirmation(self.settings.language.strings.tagUpdateFailed)
                }
            case .failure(let error):
                self.writeResult = .failure(message: error.localizedDescription)
                self.step = .failure
                self.playHaptic(.writeFailure)
                self.deliverConfirmation(self.settings.language.strings.tagUpdateFailed)
            }
        }

        if Thread.isMainThread {
            applyResult()
        } else {
            DispatchQueue.main.async(execute: applyResult)
        }
    }

}
