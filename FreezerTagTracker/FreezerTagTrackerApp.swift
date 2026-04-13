import SwiftUI

@main
struct FreezerTagTrackerApp: App {
    private let launchConfiguration: AppLaunchConfiguration
    @StateObject private var settingsViewModel: SettingsViewModel

    init() {
        let configuration = AppLaunchConfiguration.current
        launchConfiguration = configuration
        _settingsViewModel = StateObject(wrappedValue: configuration.makeSettingsViewModel())
    }

    var body: some Scene {
        WindowGroup {
            HomeView(
                viewModel: launchConfiguration.makeContainerViewModel(),
                settingsViewModel: settingsViewModel
            )
            .environmentObject(settingsViewModel)
            .environment(\.locale, settingsViewModel.locale)
        }
    }
}
