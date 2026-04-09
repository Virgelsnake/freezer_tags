import SwiftUI

@main
struct FreezerTagTrackerApp: App {
    private let launchConfiguration = AppLaunchConfiguration.current

    var body: some Scene {
        WindowGroup {
            HomeView(
                viewModel: launchConfiguration.makeContainerViewModel(),
                settingsViewModelFactory: launchConfiguration.makeSettingsViewModel
            )
        }
    }
}
