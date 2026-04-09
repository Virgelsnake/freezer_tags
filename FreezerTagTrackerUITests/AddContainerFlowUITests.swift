import XCTest

final class AddContainerFlowUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testDetailsToReviewFlowShowsSummary() {
        let app = makeApp()

        app.launch()
        openAddContainer(in: app)
        enterFoodName("Beef stew", in: app)
        app.buttons["addContainer.reviewButton"].tap()

        XCTAssertTrue(app.staticTexts["Review and write"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Beef stew"].waitForExistence(timeout: 2))
    }

    func testGoBackFromReviewKeepsEnteredFoodName() {
        let app = makeApp()

        app.launch()
        openAddContainer(in: app)
        enterFoodName("Fish pie", in: app)
        app.buttons["addContainer.reviewButton"].tap()
        app.buttons["addContainer.goBackAndChangeButton"].tap()

        let foodNameField = app.textFields["addContainer.foodNameField"]
        XCTAssertTrue(foodNameField.waitForExistence(timeout: 2))
        XCTAssertEqual(foodNameField.value as? String, "Fish pie")
    }

    func testSuccessfulWriteShowsSuccessState() {
        let app = makeApp(writeResult: "success")

        app.launch()
        navigateToReview(in: app, foodName: "Vegetable curry")
        app.buttons["addContainer.writeButton"].tap()

        XCTAssertTrue(app.staticTexts["Saved to your container"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["addContainer.doneButton"].exists)
        XCTAssertTrue(app.buttons["addContainer.readDetailsAgainButton"].exists)
    }

    func testFailedWriteShowsFailureState() {
        let app = makeApp(writeResult: "failure")

        app.launch()
        navigateToReview(in: app, foodName: "Pastries")
        app.buttons["addContainer.writeButton"].tap()

        XCTAssertTrue(app.staticTexts["That did not save to the tag"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["addContainer.tryAgainButton"].exists)
        XCTAssertTrue(app.buttons["addContainer.goBackButton"].exists)
    }

    func testSettingsChangesAffectAddFlow() {
        let app = makeApp(writeResult: "success")

        app.launch()
        app.buttons["home.settings"].tap()

        let microphoneToggle = app.switches["Show microphone shortcut"]
        XCTAssertTrue(microphoneToggle.waitForExistence(timeout: 2))
        microphoneToggle.tap()

        let readDetailsToggle = app.switches["Show Read details again button"]
        XCTAssertTrue(readDetailsToggle.exists)
        readDetailsToggle.tap()

        app.navigationBars.buttons["Done"].tap()

        openAddContainer(in: app)
        XCTAssertFalse(app.buttons["addContainer.microphoneButton"].exists)
        enterFoodName("Lentil soup", in: app)
        app.buttons["addContainer.reviewButton"].tap()
        XCTAssertTrue(app.staticTexts["Review and write"].waitForExistence(timeout: 2))

        app.buttons["addContainer.writeButton"].tap()

        XCTAssertTrue(app.staticTexts["Saved to your container"].waitForExistence(timeout: 2))
        XCTAssertFalse(app.buttons["addContainer.readDetailsAgainButton"].exists)
    }

    private func navigateToReview(in app: XCUIApplication, foodName: String) {
        openAddContainer(in: app)
        enterFoodName(foodName, in: app)
        app.buttons["addContainer.reviewButton"].tap()
        XCTAssertTrue(app.staticTexts["Review and write"].waitForExistence(timeout: 2))
    }

    private func openAddContainer(in app: XCUIApplication) {
        let addContainerButton = app.buttons["home.addContainer"]
        XCTAssertTrue(addContainerButton.waitForExistence(timeout: 2))
        addContainerButton.tap()
        XCTAssertTrue(app.textFields["addContainer.foodNameField"].waitForExistence(timeout: 2))
    }

    private func enterFoodName(_ foodName: String, in app: XCUIApplication) {
        let foodNameField = app.textFields["addContainer.foodNameField"]
        XCTAssertTrue(foodNameField.waitForExistence(timeout: 2))
        foodNameField.tap()
        foodNameField.typeText(foodName)
    }

    private func makeApp(writeResult: String = "success") -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment["UITEST_MODE"] = "1"
        app.launchEnvironment["UITEST_RESET_STATE"] = "1"
        app.launchEnvironment["UITEST_TAG_WRITE_RESULT"] = writeResult
        app.launchEnvironment["UITEST_USER_DEFAULTS_SUITE"] = "FreezerTagTrackerUITests.\(name)"
        return app
    }
}
