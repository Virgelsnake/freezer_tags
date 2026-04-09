import SwiftUI

struct AddContainerView: View {
    @ObservedObject var viewModel: ContainerViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        AddContainerFlowView(
            onCancel: { dismiss() },
            onSubmit: saveDraft
        )
        .navigationBarBackButtonHidden(true)
    }

    private func saveDraft(
        _ draft: AddContainerDraft,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        viewModel.saveContainerWithNFC(
            foodName: draft.trimmedFoodName,
            foodCategory: draft.foodCategory,
            dateFrozen: draft.dateFrozen,
            notes: draft.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : draft.notes,
            bestBeforeDate: draft.bestQualityDate
        ) { result in
            switch result {
            case .success:
                dismiss()
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

#Preview {
    NavigationView {
        AddContainerView(viewModel: ContainerViewModel(dataStore: DataStore(inMemory: true)))
    }
}
