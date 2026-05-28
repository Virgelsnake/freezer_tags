import XCTest
@testable import FreezerTagTracker

final class GS1EvidenceTests: XCTestCase {
    func testValidationWarnsButDoesNotBlockMissingRecommendedFields() {
        let record = GS1ProductItemRecord(productName: "Frozen soup")

        let warnings = record.validationWarnings

        XCTAssertFalse(warnings.contains { $0.id == "missing_product_name" })
        XCTAssertTrue(warnings.contains { $0.id == "missing_batch_or_lot" })
        XCTAssertTrue(warnings.contains { $0.id == "missing_expiry_or_use_by_date" })
    }

    func testValidationFlagsMalformedGTIN() {
        let record = GS1ProductItemRecord(
            gtin: "12345",
            productName: "Frozen soup",
            batchOrLot: "LOT-1",
            expiryOrUseByDate: "2026-12-31",
            storageInstruction: "Keep frozen"
        )

        XCTAssertTrue(record.validationWarnings.contains { $0.id == "malformed_gtin" })
    }

    func testGTINCheckDigitValidation() {
        XCTAssertTrue(GS1EvidenceValidator.isValidGTIN("05012345678900"))
        XCTAssertFalse(GS1EvidenceValidator.isValidGTIN("05012345678901"))
    }

    func testCheckEventRequiresNoteAndCopiesSnapshotFields() throws {
        let record = GS1ProductItemRecord(
            gtin: "05012345678900",
            productName: "Demo frozen meal",
            batchOrLot: "LOT-2026-05",
            serialOrItemID: "ITEM-1",
            expiryOrUseByDate: "2026-12-31",
            storageInstruction: "Keep frozen"
        )
        let tagLink = GS1EvidenceService.makeSimulatorTagLink(
            record: record,
            operatorName: "Alex"
        )

        XCTAssertThrowsError(try GS1EvidenceService.makeCheckEvent(
            record: record,
            tagLink: tagLink,
            checkNote: " ",
            checkStatus: .noteOnly,
            operatorName: "Alex",
            deviceLabel: "iPhone demo",
            locationNote: ""
        ))

        let event = try GS1EvidenceService.makeCheckEvent(
            record: record,
            tagLink: tagLink,
            checkNote: "Visual check complete",
            checkStatus: .pass,
            operatorName: "Alex",
            deviceLabel: "iPhone demo",
            locationNote: "Freezer bay 1"
        )

        XCTAssertEqual(event.gtin, "05012345678900")
        XCTAssertEqual(event.batchOrLot, "LOT-2026-05")
        XCTAssertEqual(event.serialOrItemID, "ITEM-1")
        XCTAssertEqual(event.checkNote, "Visual check complete")
        XCTAssertEqual(event.proofLimitVersion, GS1EvidenceProofLimit.version)
        XCTAssertFalse(event.payloadHash.isEmpty)
        XCTAssertFalse(event.eventHash.isEmpty)
    }

    func testCSVExportIncludesProofLimitAndWarnings() throws {
        let record = GS1ProductItemRecord(productName: "Demo frozen meal")
        let tagLink = GS1EvidenceService.makeSimulatorTagLink(
            record: record,
            operatorName: "Alex"
        )
        let event = try GS1EvidenceService.makeCheckEvent(
            record: record,
            tagLink: tagLink,
            checkNote: "Label present",
            checkStatus: .noteOnly,
            operatorName: "Alex",
            deviceLabel: "iPhone demo",
            locationNote: ""
        )

        let csv = GS1EvidenceExportGenerator.makeCSV(events: [event])

        XCTAssertTrue(csv.contains("proof_limit_version"))
        XCTAssertTrue(csv.contains(GS1EvidenceProofLimit.version))
        XCTAssertTrue(csv.contains("It does not prove the food itself was safe"))
        XCTAssertTrue(csv.contains("Batch/lot is recommended"))
    }

    func testJSONExportIncludesEventFields() throws {
        let record = GS1EvidenceService.makeDemoRecord()
        let tagLink = GS1EvidenceService.makeSimulatorTagLink(
            record: record,
            operatorName: "Alex"
        )
        let event = try GS1EvidenceService.makeCheckEvent(
            record: record,
            tagLink: tagLink,
            checkNote: "Temperature check recorded elsewhere",
            checkStatus: .pass,
            operatorName: "Alex",
            deviceLabel: "iPhone demo",
            locationNote: "Dispatch freezer"
        )

        let json = try GS1EvidenceExportGenerator.makeJSON(events: [event])

        XCTAssertTrue(json.contains("\"productName\" : \"Demo frozen meal\""))
        XCTAssertTrue(json.contains("\"proofLimitVersion\" : \"\(GS1EvidenceProofLimit.version)\""))
        XCTAssertTrue(json.contains("\"checkNote\" : \"Temperature check recorded elsewhere\""))
    }

    func testProofLimitWordingAvoidsComplianceOverclaim() {
        let text = GS1EvidenceProofLimit.text

        XCTAssertTrue(text.contains("does not prove the food itself was safe"))
        XCTAssertTrue(text.contains("tag was never moved"))
        XCTAssertTrue(text.contains("legal or GS1 compliance requirement"))
    }
}
