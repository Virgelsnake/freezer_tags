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

    var reviewReplayMessage: String? {
        guard !draft.trimmedFoodName.isEmpty else {
            return nil
        }

        var components = [
            "Review and write",
            draft.trimmedFoodName,
            "Frozen \(Self.replayDateFormatter.string(from: draft.dateFrozen))"
        ]

        if let bestQualityDate = draft.bestQualityDate {
            components.append("Best quality by \(Self.replayDateFormatter.string(from: bestQualityDate))")
        } else {
            components.append("No best-quality date set")
        }

        let trimmedNotes = draft.notes.trimmingCharacters(in: .whitespacesAndNewlines)

        if !trimmedNotes.isEmpty {
            components.append("Notes: \(trimmedNotes)")
        }

        return components.joined(separator: ". ") + "."
    }

    var successReplayMessage: String? {
        guard let record = completedRecord else {
            return nil
        }

        let frozenDate = Self.replayDateFormatter.string(from: record.dateFrozen)

        if let bestBeforeDate = record.bestBeforeDate {
            return "\(record.foodName). Frozen \(frozenDate). Best quality by \(Self.replayDateFormatter.string(from: bestBeforeDate)). Tag updated successfully."
        }

        return "\(record.foodName). Frozen \(frozenDate). No best-quality date saved. Tag updated successfully."
    }

    var presetStatusMessage: String? {
        guard draft.foodCategory != nil else {
            return nil
        }

        if draft.isBestQualityDateManuallyEdited {
            return "Date changed"
        }

        guard draft.bestQualityDate != nil else {
            return nil
        }

        return "Best-quality date added from USDA guidance."
    }

    var completedRecord: ContainerRecord? {
        guard case .success(let record) = writeResult else {
            return nil
        }

        return record
    }

    func updateFoodName(_ foodName: String) {
        draft.foodName = foodName

        if !draft.trimmedFoodName.isEmpty, validationMessage == "Food name is required." {
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
        deliverGuidance("Add a container. Tell us what you are freezing.")
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
            validationMessage = "Food name is required."
            step = .details
            playHaptic(.validationError)
            deliverGuidance("Food name is required before you can continue.")
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
            validationMessage = "Food name is required."
            step = .details
            return
        }

        validationMessage = nil
        writeResult = nil

        let record = pendingRecord ?? makeRecordFromDraft()
        pendingRecord = record
        step = .writing
        playHaptic(.writeStart)
        deliverGuidance("Ready to write. Hold your iPhone near the tag.")

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
            accessibilityAnnouncementService.announce(message)
        } else {
            spokenFeedbackService.speak(message)
        }
    }

    private func deliverConfirmation(_ message: String) {
        guard settings.spokenConfirmationsEnabled else {
            return
        }

        if accessibilityStatusProvider.isVoiceOverRunning {
            accessibilityAnnouncementService.announce(message)
        } else {
            spokenFeedbackService.speak(message)
        }
    }

    private func refreshSettings() {
        guard refreshSettingsFromStore else {
            return
        }

        settings = settingsStore.load()
    }

    private func messageForPresetSelection(_ category: FoodCategory) -> String {
        guard bestQualityDateCalculator.suggestedDate(for: category, frozenOn: draft.dateFrozen) != nil else {
            return "\(category.displayName) selected. No best-quality date added."
        }

        return "\(category.displayName) selected. Best-quality date added."
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
                    self.deliverConfirmation("Saved. Tag updated.")
                } catch {
                    self.writeResult = .failure(message: error.localizedDescription)
                    self.step = .failure
                    self.playHaptic(.writeFailure)
                    self.deliverConfirmation("The tag was not updated. Try holding your phone a little closer and keep it still.")
                }
            case .failure(let error):
                self.writeResult = .failure(message: error.localizedDescription)
                self.step = .failure
                self.playHaptic(.writeFailure)
                self.deliverConfirmation("The tag was not updated. Try holding your phone a little closer and keep it still.")
            }
        }

        if Thread.isMainThread {
            applyResult()
        } else {
            DispatchQueue.main.async(execute: applyResult)
        }
    }

    private static let replayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}
