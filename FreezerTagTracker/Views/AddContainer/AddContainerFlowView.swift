import SwiftUI

struct AddContainerFlowView: View {
    @StateObject private var viewModel: AddContainerFlowViewModel

    let onCancel: () -> Void
    let onComplete: () -> Void

    init(
        viewModel: AddContainerFlowViewModel = AddContainerFlowViewModel(),
        onCancel: @escaping () -> Void,
        onComplete: @escaping () -> Void
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onCancel = onCancel
        self.onComplete = onComplete
    }

    var body: some View {
        Group {
            switch viewModel.step {
            case .details:
                AddContainerDetailsView(viewModel: viewModel, onCancel: onCancel)
            case .review:
                AddContainerReviewView(
                    draft: viewModel.draft,
                    isSubmitting: false,
                    onWrite: viewModel.writeToTag,
                    onGoBack: viewModel.goBackToDetails
                )
            case .writing:
                TagWritingView()
            case .success, .failure:
                if let writeResult = viewModel.writeResult {
                    TagWriteResultView(
                        result: writeResult,
                        canReadDetailsAgain: viewModel.canReplaySuccessDetails,
                        onReadDetailsAgain: viewModel.readDetailsAgain,
                        onDone: onComplete,
                        onTryAgain: viewModel.retryWrite,
                        onGoBack: viewModel.goBackToReview
                    )
                } else {
                    ProgressView()
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        AddContainerFlowView(onCancel: {}, onComplete: {})
    }
}
