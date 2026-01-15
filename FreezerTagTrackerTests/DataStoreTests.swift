import XCTest
import CoreData
@testable import FreezerTagTracker

final class DataStoreTests: XCTestCase {
    var dataStore: DataStore!
    
    override func setUpWithError() throws {
        dataStore = DataStore(inMemory: true)
    }
    
    override func tearDownWithError() throws {
        dataStore = nil
    }
    
    func testSaveNewContainerRecord() throws {
        let record = ContainerRecord(
            tagID: "test-tag-001",
            foodName: "Chicken Soup",
            dateFrozen: Date(),
            notes: "Test notes"
        )
        
        try dataStore.save(record: record)
        
        let fetched = dataStore.fetch(byTagID: "test-tag-001")
        XCTAssertNotNil(fetched)
        XCTAssertEqual(fetched?.tagID, "test-tag-001")
        XCTAssertEqual(fetched?.foodName, "Chicken Soup")
        XCTAssertEqual(fetched?.notes, "Test notes")
    }
    
    func testFetchContainerByTagID() throws {
        let record1 = ContainerRecord(
            tagID: "tag-001",
            foodName: "Beef Stew",
            dateFrozen: Date(),
            notes: nil
        )
        
        let record2 = ContainerRecord(
            tagID: "tag-002",
            foodName: "Chicken Soup",
            dateFrozen: Date(),
            notes: nil
        )
        
        try dataStore.save(record: record1)
        try dataStore.save(record: record2)
        
        let fetched = dataStore.fetch(byTagID: "tag-001")
        XCTAssertNotNil(fetched)
        XCTAssertEqual(fetched?.foodName, "Beef Stew")
        XCTAssertEqual(fetched?.tagID, "tag-001")
    }
    
    func testFetchAllContainers() throws {
        let record1 = ContainerRecord(
            tagID: "tag-001",
            foodName: "Beef Stew",
            dateFrozen: Date(),
            notes: nil
        )
        
        let record2 = ContainerRecord(
            tagID: "tag-002",
            foodName: "Chicken Soup",
            dateFrozen: Date(),
            notes: nil
        )
        
        let record3 = ContainerRecord(
            tagID: "tag-003",
            foodName: "Vegetable Curry",
            dateFrozen: Date(),
            notes: nil
        )
        
        try dataStore.save(record: record1)
        try dataStore.save(record: record2)
        try dataStore.save(record: record3)
        
        let allRecords = dataStore.fetchAll()
        XCTAssertEqual(allRecords.count, 3)
    }
    
    func testUpdateExistingContainer() throws {
        var record = ContainerRecord(
            tagID: "tag-update",
            foodName: "Original Food",
            dateFrozen: Date(),
            notes: "Original notes"
        )
        
        try dataStore.save(record: record)
        
        record.foodName = "Updated Food"
        record.notes = "Updated notes"
        
        try dataStore.update(record: record)
        
        let fetched = dataStore.fetch(byTagID: "tag-update")
        XCTAssertEqual(fetched?.foodName, "Updated Food")
        XCTAssertEqual(fetched?.notes, "Updated notes")
    }
    
    func testDeleteContainer() throws {
        let record = ContainerRecord(
            tagID: "tag-delete",
            foodName: "To Be Deleted",
            dateFrozen: Date(),
            notes: nil
        )
        
        try dataStore.save(record: record)
        
        let fetchedBefore = dataStore.fetch(byTagID: "tag-delete")
        XCTAssertNotNil(fetchedBefore)
        
        try dataStore.delete(record: record)
        
        let fetchedAfter = dataStore.fetch(byTagID: "tag-delete")
        XCTAssertNil(fetchedAfter)
    }
    
    func testClearContainer() throws {
        let record = ContainerRecord(
            tagID: "tag-clear",
            foodName: "To Be Cleared",
            dateFrozen: Date(),
            notes: "Some notes"
        )
        
        try dataStore.save(record: record)
        
        try dataStore.clearContainer(tagID: "tag-clear")
        
        let fetched = dataStore.fetch(byTagID: "tag-clear")
        XCTAssertNotNil(fetched)
        XCTAssertTrue(fetched?.isCleared ?? false)
    }
    
    func testHandleDuplicateTagIDs() throws {
        let record1 = ContainerRecord(
            tagID: "duplicate-tag",
            foodName: "First Record",
            dateFrozen: Date(),
            notes: nil
        )
        
        try dataStore.save(record: record1)
        
        let record2 = ContainerRecord(
            tagID: "duplicate-tag",
            foodName: "Second Record",
            dateFrozen: Date(),
            notes: nil
        )
        
        XCTAssertThrowsError(try dataStore.save(record: record2)) { error in
            XCTAssertTrue(error is DataStoreError)
            if let dataStoreError = error as? DataStoreError {
                switch dataStoreError {
                case .duplicateTagID:
                    break
                default:
                    XCTFail("Expected duplicateTagID error")
                }
            }
        }
    }
    
    func testHandleNonExistentRecord() throws {
        let fetched = dataStore.fetch(byTagID: "non-existent-tag")
        XCTAssertNil(fetched)
    }
    
    func testUpdateNonExistentRecord() throws {
        let record = ContainerRecord(
            tagID: "non-existent",
            foodName: "Does Not Exist",
            dateFrozen: Date(),
            notes: nil
        )
        
        XCTAssertThrowsError(try dataStore.update(record: record)) { error in
            XCTAssertTrue(error is DataStoreError)
            if let dataStoreError = error as? DataStoreError {
                switch dataStoreError {
                case .recordNotFound:
                    break
                default:
                    XCTFail("Expected recordNotFound error")
                }
            }
        }
    }
    
    func testDeleteNonExistentRecord() throws {
        let record = ContainerRecord(
            tagID: "non-existent",
            foodName: "Does Not Exist",
            dateFrozen: Date(),
            notes: nil
        )
        
        XCTAssertThrowsError(try dataStore.delete(record: record)) { error in
            XCTAssertTrue(error is DataStoreError)
        }
    }
    
    func testFetchAllReturnsEmptyArrayWhenNoRecords() throws {
        let allRecords = dataStore.fetchAll()
        XCTAssertEqual(allRecords.count, 0)
    }
}
