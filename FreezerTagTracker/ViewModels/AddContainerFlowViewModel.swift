import Combine
import Foundation

final class AddContainerFlowViewModel: ObservableObject {
    @Published var draft = AddContainerDraft()
    @Published var step: AddContainerStep = .details
    @Published var validationMessage: String?
    @Published var writeResult: TagWriteResult?

    private let presetProvider: FoodCategoryPresetProviding
    private let bestQualityDateCalculator: BestQualityDateCalculator

    init(
        draft: AddContainerDraft = AddContainerDraft(),
        presetProvider: FoodCategoryPresetProviding = AddContainerSettingsStore()
    ) {
        self.draft = draft
        self.presetProvider = presetProvider
        self.bestQualityDateCalculator = BestQualityDateCalculator(presetProvider: presetProvider)
    }

    var availablePresets: [FoodCategoryPreset] {
        presetProvider.presets()
    }

    var canProceedToReview: Bool {
        draft.canProceedToReview
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

    func goToReview() {
        guard !draft.trimmedFoodName.isEmpty else {
            validationMessage = "Food name is required."
            step = .details
            return
        }

        validationMessage = nil
        step = .review
    }

    func goBackToDetails() {
        validationMessage = nil
        step = .details
    }

    func selectPreset(_ category: FoodCategory) {
        draft.foodCategory = category
        draft.isBestQualityDateManuallyEdited = false
        draft.bestQualityDate = bestQualityDateCalculator.suggestedDate(for: category, frozenOn: draft.dateFrozen)
    }
}
