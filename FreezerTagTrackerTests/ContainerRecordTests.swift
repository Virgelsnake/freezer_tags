import XCTest
@testable import FreezerTagTracker

final class ContainerRecordTests: XCTestCase {
    
    func testModelInitializationWithValidData() throws {
        let tagID = "test-tag-123"
        let foodName = "Chicken Soup"
        let dateFrozen = Date()
        let notes = "Contains vegetables"
        
        let record = ContainerRecord(
            tagID: tagID,
            foodName: foodName,
            dateFrozen: dateFrozen,
            notes: notes
        )
        
        XCTAssertNotNil(record.id)
        XCTAssertEqual(record.tagID, tagID)
        XCTAssertEqual(record.foodName, foodName)
        XCTAssertEqual(record.dateFrozen, dateFrozen)
        XCTAssertEqual(record.notes, notes)
        XCTAssertFalse(record.isCleared)
        XCTAssertNotNil(record.createdAt)
        XCTAssertNotNil(record.updatedAt)
    }
    
    func testModelInitializationWithoutNotes() throws {
        let tagID = "test-tag-456"
        let foodName = "Beef Stew"
        let dateFrozen = Date()
        
        let record = ContainerRecord(
            tagID: tagID,
            foodName: foodName,
            dateFrozen: dateFrozen,
            notes: nil
        )
        
        XCTAssertNotNil(record.id)
        XCTAssertEqual(record.tagID, tagID)
        XCTAssertEqual(record.foodName, foodName)
        XCTAssertEqual(record.dateFrozen, dateFrozen)
        XCTAssertNil(record.notes)
        XCTAssertFalse(record.isCleared)
    }
    
    func testRequiredFieldValidation() throws {
        let tagID = ""
        let foodName = ""
        let dateFrozen = Date()
        
        let record = ContainerRecord(
            tagID: tagID,
            foodName: foodName,
            dateFrozen: dateFrozen,
            notes: nil
        )
        
        XCTAssertFalse(record.isValid)
    }
    
    func testValidRecordWithRequiredFields() throws {
        let tagID = "valid-tag"
        let foodName = "Valid Food"
        let dateFrozen = Date()
        
        let record = ContainerRecord(
            tagID: tagID,
            foodName: foodName,
            dateFrozen: dateFrozen,
            notes: nil
        )
        
        XCTAssertTrue(record.isValid)
    }
    
    func testNotesCharacterLimit() throws {
        let tagID = "test-tag"
        let foodName = "Test Food"
        let dateFrozen = Date()
        let longNotes = String(repeating: "a", count: 250)
        
        let record = ContainerRecord(
            tagID: tagID,
            foodName: foodName,
            dateFrozen: dateFrozen,
            notes: longNotes
        )
        
        XCTAssertFalse(record.isValid)
    }
    
    func testNotesWithinCharacterLimit() throws {
        let tagID = "test-tag"
        let foodName = "Test Food"
        let dateFrozen = Date()
        let validNotes = String(repeating: "a", count: 200)
        
        let record = ContainerRecord(
            tagID: tagID,
            foodName: foodName,
            dateFrozen: dateFrozen,
            notes: validNotes
        )
        
        XCTAssertTrue(record.isValid)
    }
    
    func testDateFormatting() throws {
        let tagID = "test-tag"
        let foodName = "Test Food"
        let calendar = Calendar.current
        let components = DateComponents(year: 2026, month: 1, day: 15)
        let dateFrozen = calendar.date(from: components)!
        
        let record = ContainerRecord(
            tagID: tagID,
            foodName: foodName,
            dateFrozen: dateFrozen,
            notes: nil
        )
        
        let formatted = record.formattedDateFrozen
        XCTAssertTrue(formatted.contains("Jan") || formatted.contains("1"))
        XCTAssertTrue(formatted.contains("15"))
        XCTAssertTrue(formatted.contains("2026"))
    }
    
    func testDaysFrozenCalculation() throws {
        let tagID = "test-tag"
        let foodName = "Test Food"
        let calendar = Calendar.current
        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: Date())!
        
        let record = ContainerRecord(
            tagID: tagID,
            foodName: foodName,
            dateFrozen: threeDaysAgo,
            notes: nil
        )
        
        XCTAssertEqual(record.daysFrozen, 3)
    }
    
    func testUniqueIDGeneration() throws {
        let tagID = "test-tag"
        let foodName = "Test Food"
        let dateFrozen = Date()
        
        let record1 = ContainerRecord(
            tagID: tagID,
            foodName: foodName,
            dateFrozen: dateFrozen,
            notes: nil
        )
        
        let record2 = ContainerRecord(
            tagID: tagID,
            foodName: foodName,
            dateFrozen: dateFrozen,
            notes: nil
        )
        
        XCTAssertNotEqual(record1.id, record2.id)
    }
    
    func testCodableConformance() throws {
        let tagID = "test-tag"
        let foodName = "Test Food"
        let dateFrozen = Date()
        let notes = "Test notes"
        
        let record = ContainerRecord(
            tagID: tagID,
            foodName: foodName,
            dateFrozen: dateFrozen,
            notes: notes
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(record)
        
        let decoder = JSONDecoder()
        let decodedRecord = try decoder.decode(ContainerRecord.self, from: data)
        
        XCTAssertEqual(record.id, decodedRecord.id)
        XCTAssertEqual(record.tagID, decodedRecord.tagID)
        XCTAssertEqual(record.foodName, decodedRecord.foodName)
        XCTAssertEqual(record.notes, decodedRecord.notes)
        XCTAssertEqual(record.isCleared, decodedRecord.isCleared)
    }
    
    func testHashableConformance() throws {
        let tagID = "test-tag"
        let foodName = "Test Food"
        let dateFrozen = Date()
        
        let record1 = ContainerRecord(
            tagID: tagID,
            foodName: foodName,
            dateFrozen: dateFrozen,
            notes: nil
        )
        
        let record2 = ContainerRecord(
            tagID: tagID,
            foodName: foodName,
            dateFrozen: dateFrozen,
            notes: nil
        )
        
        var set = Set<ContainerRecord>()
        set.insert(record1)
        set.insert(record2)
        
        XCTAssertEqual(set.count, 2)
    }
    
    // MARK: - Best Before Date Tests
    
    func testModelInitializationWithBestBeforeDate() throws {
        let tagID = "test-tag-123"
        let foodName = "Chicken Soup"
        let dateFrozen = Date()
        let calendar = Calendar.current
        let bestBeforeDate = calendar.date(byAdding: .day, value: 30, to: Date())!
        
        let record = ContainerRecord(
            tagID: tagID,
            foodName: foodName,
            dateFrozen: dateFrozen,
            notes: nil,
            bestBeforeDate: bestBeforeDate
        )
        
        XCTAssertNotNil(record.bestBeforeDate)
        XCTAssertEqual(record.bestBeforeDate, bestBeforeDate)
    }
    
    func testModelInitializationWithoutBestBeforeDate() throws {
        let tagID = "test-tag-456"
        let foodName = "Beef Stew"
        let dateFrozen = Date()
        
        let record = ContainerRecord(
            tagID: tagID,
            foodName: foodName,
            dateFrozen: dateFrozen,
            notes: nil,
            bestBeforeDate: nil
        )
        
        XCTAssertNil(record.bestBeforeDate)
    }
    
    func testBestBeforeDateFormatting() throws {
        let tagID = "test-tag"
        let foodName = "Test Food"
        let dateFrozen = Date()
        let calendar = Calendar.current
        let components = DateComponents(year: 2026, month: 2, day: 15)
        let bestBeforeDate = calendar.date(from: components)!
        
        let record = ContainerRecord(
            tagID: tagID,
            foodName: foodName,
            dateFrozen: dateFrozen,
            notes: nil,
            bestBeforeDate: bestBeforeDate
        )
        
        let formatted = record.formattedBestBeforeDate
        XCTAssertNotNil(formatted)
        XCTAssertTrue(formatted!.contains("Feb") || formatted!.contains("2"))
        XCTAssertTrue(formatted!.contains("15"))
        XCTAssertTrue(formatted!.contains("2026"))
    }
    
    func testBestBeforeDateFormattingWhenNil() throws {
        let tagID = "test-tag"
        let foodName = "Test Food"
        let dateFrozen = Date()
        
        let record = ContainerRecord(
            tagID: tagID,
            foodName: foodName,
            dateFrozen: dateFrozen,
            notes: nil,
            bestBeforeDate: nil
        )
        
        XCTAssertNil(record.formattedBestBeforeDate)
    }
    
    func testBestBeforeStatusFresh() throws {
        let tagID = "test-tag"
        let foodName = "Test Food"
        let dateFrozen = Date()
        let calendar = Calendar.current
        let futureDate = calendar.date(byAdding: .day, value: 30, to: Date())!
        
        let record = ContainerRecord(
            tagID: tagID,
            foodName: foodName,
            dateFrozen: dateFrozen,
            notes: nil,
            bestBeforeDate: futureDate
        )
        
        XCTAssertEqual(record.bestBeforeStatus, .fresh)
    }
    
    func testBestBeforeStatusApproaching() throws {
        let tagID = "test-tag"
        let foodName = "Test Food"
        let dateFrozen = Date()
        let calendar = Calendar.current
        let approachingDate = calendar.date(byAdding: .day, value: 5, to: Date())!
        
        let record = ContainerRecord(
            tagID: tagID,
            foodName: foodName,
            dateFrozen: dateFrozen,
            notes: nil,
            bestBeforeDate: approachingDate
        )
        
        XCTAssertEqual(record.bestBeforeStatus, .approaching)
    }
    
    func testBestBeforeStatusExpired() throws {
        let tagID = "test-tag"
        let foodName = "Test Food"
        let dateFrozen = Date()
        let calendar = Calendar.current
        let pastDate = calendar.date(byAdding: .day, value: -5, to: Date())!
        
        let record = ContainerRecord(
            tagID: tagID,
            foodName: foodName,
            dateFrozen: dateFrozen,
            notes: nil,
            bestBeforeDate: pastDate
        )
        
        XCTAssertEqual(record.bestBeforeStatus, .expired)
    }
    
    func testBestBeforeStatusNoneWhenNil() throws {
        let tagID = "test-tag"
        let foodName = "Test Food"
        let dateFrozen = Date()
        
        let record = ContainerRecord(
            tagID: tagID,
            foodName: foodName,
            dateFrozen: dateFrozen,
            notes: nil,
            bestBeforeDate: nil
        )
        
        XCTAssertEqual(record.bestBeforeStatus, .none)
    }
    
    func testBestBeforeStatusExactlySevenDaysAway() throws {
        let tagID = "test-tag"
        let foodName = "Test Food"
        let dateFrozen = Date()
        let calendar = Calendar.current
        let sevenDaysAway = calendar.date(byAdding: .day, value: 7, to: Date())!
        
        let record = ContainerRecord(
            tagID: tagID,
            foodName: foodName,
            dateFrozen: dateFrozen,
            notes: nil,
            bestBeforeDate: sevenDaysAway
        )
        
        XCTAssertEqual(record.bestBeforeStatus, .approaching)
    }
    
    func testDaysUntilBestBeforeCalculation() throws {
        let tagID = "test-tag"
        let foodName = "Test Food"
        let dateFrozen = Date()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let futureDate = calendar.date(byAdding: .day, value: 10, to: today)!
        
        let record = ContainerRecord(
            tagID: tagID,
            foodName: foodName,
            dateFrozen: dateFrozen,
            notes: nil,
            bestBeforeDate: futureDate
        )
        
        XCTAssertEqual(record.daysUntilBestBefore, 10)
    }
    
    func testDaysUntilBestBeforeNegativeWhenExpired() throws {
        let tagID = "test-tag"
        let foodName = "Test Food"
        let dateFrozen = Date()
        let calendar = Calendar.current
        let pastDate = calendar.date(byAdding: .day, value: -3, to: Date())!
        
        let record = ContainerRecord(
            tagID: tagID,
            foodName: foodName,
            dateFrozen: dateFrozen,
            notes: nil,
            bestBeforeDate: pastDate
        )
        
        XCTAssertEqual(record.daysUntilBestBefore, -3)
    }
    
    func testDaysUntilBestBeforeNilWhenNoDate() throws {
        let tagID = "test-tag"
        let foodName = "Test Food"
        let dateFrozen = Date()
        
        let record = ContainerRecord(
            tagID: tagID,
            foodName: foodName,
            dateFrozen: dateFrozen,
            notes: nil,
            bestBeforeDate: nil
        )
        
        XCTAssertNil(record.daysUntilBestBefore)
    }
    
    func testCodableConformanceWithBestBeforeDate() throws {
        let tagID = "test-tag"
        let foodName = "Test Food"
        let dateFrozen = Date()
        let bestBeforeDate = Date()
        
        let record = ContainerRecord(
            tagID: tagID,
            foodName: foodName,
            dateFrozen: dateFrozen,
            notes: nil,
            bestBeforeDate: bestBeforeDate
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(record)
        
        let decoder = JSONDecoder()
        let decodedRecord = try decoder.decode(ContainerRecord.self, from: data)
        
        XCTAssertEqual(record.bestBeforeDate, decodedRecord.bestBeforeDate)
    }
}
