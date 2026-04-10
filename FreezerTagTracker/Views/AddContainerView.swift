import SwiftUI

struct AddContainerView: View {
    @ObservedObject var viewModel: ContainerViewModel
    let settingsSnapshot: AddContainerSettings?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        AddContainerFlowView(
            viewModel: viewModel.makeAddContainerFlowViewModel(initialSettings: settingsSnapshot),
            onCancel: { dismiss() },
            onComplete: finishFlow
        )
        .navigationBarBackButtonHidden(true)
    }

    private func finishFlow() {
        viewModel.loadContainers()
        dismiss()
    }
}

#Preview {
    NavigationView {
        AddContainerView(
            viewModel: ContainerViewModel(dataStore: DataStore(inMemory: true)),
            settingsSnapshot: nil
        )
    }
}
