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
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            cancelFlowButton
                        }
                    }
            case .review:
                AddContainerReviewView(
                    draft: viewModel.draft,
                    language: viewModel.currentLanguage,
                    isSubmitting: false,
                    canReadDetailsAgain: viewModel.canReplayReviewDetails,
                    onReadDetailsAgain: viewModel.readReviewDetailsAgain,
                    onWrite: viewModel.writeToTag,
                    onGoBack: viewModel.goBackToDetails,
                    onAppear: viewModel.handleReviewScreenAppeared
                )
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        cancelFlowButton
                    }
                }
            case .writing:
                TagWritingView(language: viewModel.currentLanguage)
            case .success:
                if let writeResult = viewModel.writeResult {
                    TagWriteResultView(
                        language: viewModel.currentLanguage,
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
            case .failure:
                if let writeResult = viewModel.writeResult {
                    TagWriteResultView(
                        language: viewModel.currentLanguage,
                        result: writeResult,
                        canReadDetailsAgain: viewModel.canReplaySuccessDetails,
                        onReadDetailsAgain: viewModel.readDetailsAgain,
                        onDone: onComplete,
                        onTryAgain: viewModel.retryWrite,
                        onGoBack: viewModel.goBackToReview
                    )
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            cancelFlowButton
                        }
                    }
                } else {
                    ProgressView()
                }
            }
        }
    }

    private var cancelFlowButton: some View {
        Button(viewModel.currentLanguage.strings.cancel, action: onCancel)
            .accessibilityHint(viewModel.currentLanguage.strings.cancelFlowHint)
            .accessibilityIdentifier("addContainer.cancelFlowButton")
    }
}

#Preview {
    NavigationView {
        AddContainerFlowView(onCancel: {}, onComplete: {})
    }
    .environmentObject(SettingsViewModel())
}
