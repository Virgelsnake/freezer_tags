import Foundation

enum TagWriteResult: Equatable {
    case success(record: ContainerRecord)
    case failure(message: String)
}
