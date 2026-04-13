import Foundation

struct AppLaunchConfiguration {
    let makeSettingsViewModel: () -> SettingsViewModel

    private let dataStore: DataStore
    private let settingsStore: AddContainerSettingsProviding
    private let addContainerTagWriter: TagWriting?

    func makeContainerViewModel() -> ContainerViewModel {
        ContainerViewModel(
            dataStore: dataStore,
            addContainerTagWriter: addContainerTagWriter,
            addContainerSettingsStore: settingsStore
        )
    }

    static var current: AppLaunchConfiguration {
        let environment = ProcessInfo.processInfo.environment
        let suiteName = environment["UITEST_USER_DEFAULTS_SUITE"]
        let userDefaults = suiteName.flatMap(UserDefaults.init(suiteName:)) ?? .standard

        if let suiteName, environment["UITEST_RESET_STATE"] == "1" {
            userDefaults.removePersistentDomain(forName: suiteName)
        }

        let settingsStore = AddContainerSettingsStore(userDefaults: userDefaults)
        let dataStore = environment["UITEST_MODE"] == "1" ? DataStore(inMemory: true) : .shared
        let addContainerTagWriter = environment["UITEST_TAG_WRITE_RESULT"].map(LaunchEnvironmentTagWriter.init(modeName:))

        return AppLaunchConfiguration(
            makeSettingsViewModel: { SettingsViewModel(settingsStore: settingsStore) },
            dataStore: dataStore,
            settingsStore: settingsStore,
            addContainerTagWriter: addContainerTagWriter
        )
    }
}

private final class LaunchEnvironmentTagWriter: TagWriting {
    private let mode: Mode

    init(modeName: String) {
        mode = Mode(rawValue: modeName) ?? .success
    }

    func writeTag(record: ContainerRecord, completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.main.async {
            switch self.mode {
            case .success:
                completion(.success(()))
            case .failure:
                completion(.failure(NFCError.writeFailed))
            }
        }
    }

    private enum Mode: String {
        case success
        case failure
    }
}
