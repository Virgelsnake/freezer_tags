import SwiftUI

struct AddContainerFlowView: View {
    @StateObject private var viewModel: AddContainerFlowViewModel
    @State private var isSubmitting = false
    @State private var errorMessage: String?

    let onCancel: () -> Void
    let onSubmit: (AddContainerDraft, @escaping (Result<Void, Error>) -> Void) -> Void

    init(
        viewModel: AddContainerFlowViewModel = AddContainerFlowViewModel(),
        onCancel: @escaping () -> Void,
        onSubmit: @escaping (AddContainerDraft, @escaping (Result<Void, Error>) -> Void) -> Void
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onCancel = onCancel
        self.onSubmit = onSubmit
    }

    var body: some View {
        Group {
            switch viewModel.step {
            case .details:
                AddContainerDetailsView(viewModel: viewModel, onCancel: onCancel)
            case .review, .writing, .success, .failure:
                AddContainerReviewView(
                    draft: viewModel.draft,
                    isSubmitting: isSubmitting,
                    onWrite: submitDraft,
                    onGoBack: viewModel.goBackToDetails
                )
            }
        }
        .alert("Could not write to tag", isPresented: Binding(
            get: { errorMessage != nil },
            set: { newValue in
                if !newValue {
                    errorMessage = nil
                }
            }
        )) {
            Button("OK", role: .cancel) {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private func submitDraft() {
        guard !isSubmitting else {
            return
        }

        isSubmitting = true
        onSubmit(viewModel.draft) { result in
            DispatchQueue.main.async {
                isSubmitting = false

                if case .failure(let error) = result {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        AddContainerFlowView(onCancel: {}, onSubmit: { _, completion in
            completion(.success(()))
        })
    }
}
