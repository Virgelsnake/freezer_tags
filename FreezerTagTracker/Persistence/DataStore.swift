import Foundation
import CoreData

class DataStore {
    static let shared = DataStore()
    
    private let persistentContainer: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    init(inMemory: Bool = false) {
        persistentContainer = NSPersistentContainer(name: "FreezerTagTracker")
        
        if inMemory {
            persistentContainer.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        
        context = persistentContainer.viewContext
        context.automaticallyMergesChangesFromParent = true
    }
    
    func save(record: ContainerRecord) throws {
        print("💾 DataStore: Saving container - foodName: \(record.foodName), tagID: \(record.tagID)")
        
        let fetchRequest: NSFetchRequest<ContainerEntity> = ContainerEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "tagID == %@", record.tagID)
        
        do {
            let results = try context.fetch(fetchRequest)
            if !results.isEmpty {
                print("❌ DataStore: Duplicate tagID found, throwing error")
                throw DataStoreError.duplicateTagID
            }
            
            let entity = ContainerEntity(context: context)
            entity.id = record.id
            entity.tagID = record.tagID
            entity.foodName = record.foodName
            entity.dateFrozen = record.dateFrozen
            entity.notes = record.notes
            entity.bestBeforeDate = record.bestBeforeDate
            entity.isCleared = record.isCleared
            entity.createdAt = record.createdAt
            entity.updatedAt = record.updatedAt
            
            try context.save()
            print("✅ DataStore: Container saved successfully")
        } catch let error as DataStoreError {
            print("❌ DataStore: Save failed with DataStoreError")
            throw error
        } catch {
            print("❌ DataStore: Save failed - \(error.localizedDescription)")
            throw DataStoreError.saveFailed(error)
        }
    }
    
    func fetch(byTagID tagID: String) -> ContainerRecord? {
        print("🗄️ DataStore: Fetching container with tagID: \(tagID)")
        
        let fetchRequest: NSFetchRequest<ContainerEntity> = ContainerEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "tagID == %@", tagID)
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try context.fetch(fetchRequest)
            print("🗄️ DataStore: Found \(results.count) results")
            
            guard let entity = results.first else {
                print("❌ DataStore: No entity found for tagID: \(tagID)")
                return nil
            }
            
            let record = convertToRecord(entity: entity)
            if let record = record {
                print("✅ DataStore: Successfully converted entity to record - \(record.foodName)")
            } else {
                print("❌ DataStore: Failed to convert entity to record")
            }
            return record
        } catch {
            print("❌ DataStore: Fetch error - \(error.localizedDescription)")
            return nil
        }
    }
    
    func fetchAll() -> [ContainerRecord] {
        let fetchRequest: NSFetchRequest<ContainerEntity> = ContainerEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.compactMap { convertToRecord(entity: $0) }
        } catch {
            return []
        }
    }
    
    func update(record: ContainerRecord) throws {
        let fetchRequest: NSFetchRequest<ContainerEntity> = ContainerEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", record.id as CVarArg)
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try context.fetch(fetchRequest)
            guard let entity = results.first else {
                throw DataStoreError.recordNotFound
            }
            
            entity.foodName = record.foodName
            entity.dateFrozen = record.dateFrozen
            entity.notes = record.notes
            entity.bestBeforeDate = record.bestBeforeDate
            entity.isCleared = record.isCleared
            entity.updatedAt = Date()
            
            try context.save()
        } catch let error as DataStoreError {
            throw error
        } catch {
            throw DataStoreError.updateFailed(error)
        }
    }
    
    func delete(record: ContainerRecord) throws {
        let fetchRequest: NSFetchRequest<ContainerEntity> = ContainerEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", record.id as CVarArg)
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try context.fetch(fetchRequest)
            guard let entity = results.first else {
                throw DataStoreError.recordNotFound
            }
            
            context.delete(entity)
            try context.save()
        } catch let error as DataStoreError {
            throw error
        } catch {
            throw DataStoreError.deleteFailed(error)
        }
    }
    
    func clearContainer(tagID: String) throws {
        let fetchRequest: NSFetchRequest<ContainerEntity> = ContainerEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "tagID == %@", tagID)
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try context.fetch(fetchRequest)
            guard let entity = results.first else {
                throw DataStoreError.recordNotFound
            }
            
            entity.isCleared = true
            entity.updatedAt = Date()
            
            try context.save()
        } catch let error as DataStoreError {
            throw error
        } catch {
            throw DataStoreError.updateFailed(error)
        }
    }
    
    private func convertToRecord(entity: ContainerEntity) -> ContainerRecord? {
        guard let id = entity.id,
              let tagID = entity.tagID,
              let foodName = entity.foodName,
              let dateFrozen = entity.dateFrozen,
              let createdAt = entity.createdAt,
              let updatedAt = entity.updatedAt else {
            return nil
        }
        
        return ContainerRecord(
            id: id,
            tagID: tagID,
            foodName: foodName,
            dateFrozen: dateFrozen,
            notes: entity.notes,
            bestBeforeDate: entity.bestBeforeDate,
            isCleared: entity.isCleared,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
