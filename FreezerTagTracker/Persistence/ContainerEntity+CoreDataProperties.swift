import Foundation
import CoreData

extension ContainerEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ContainerEntity> {
        return NSFetchRequest<ContainerEntity>(entityName: "ContainerEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var tagID: String?
    @NSManaged public var foodName: String?
    @NSManaged public var dateFrozen: Date?
    @NSManaged public var notes: String?
    @NSManaged public var isCleared: Bool
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
}

extension ContainerEntity: Identifiable {
    
}
