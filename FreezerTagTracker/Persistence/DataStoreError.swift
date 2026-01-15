import Foundation

enum DataStoreError: Error, LocalizedError {
    case duplicateTagID
    case recordNotFound
    case saveFailed(Error)
    case fetchFailed(Error)
    case updateFailed(Error)
    case deleteFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .duplicateTagID:
            return "A container with this tag ID already exists"
        case .recordNotFound:
            return "Container record not found"
        case .saveFailed(let error):
            return "Failed to save container: \(error.localizedDescription)"
        case .fetchFailed(let error):
            return "Failed to fetch container: \(error.localizedDescription)"
        case .updateFailed(let error):
            return "Failed to update container: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "Failed to delete container: \(error.localizedDescription)"
        }
    }
}
