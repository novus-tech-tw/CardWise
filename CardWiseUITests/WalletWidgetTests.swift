import XCTest

final class WalletWidgetTests: XCTestCase {
    @MainActor
    func testUnusedCreditWidgetOpensRecordedCredit() throws {
        continueAfterFailure = false
        let app = launchWallet()
        enterPartialCreditUsage(in: app)
        XCUIDevice.shared.press(.home)
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let icon = springboard.icons["CardWise"].firstMatch
        XCTAssertTrue(icon.waitForExistence(timeout: 10))
        attachScreenshot(springboard, name: "Home before widget installation")
        // The disposable simulator's lower Home grid is empty. Holding it avoids
        // the app-icon preview process, which can stall SpringBoard animation waits.
        springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.7)).press(forDuration: 1.5)
        let edit = springboard.buttons["Edit"]
        XCTAssertTrue(edit.waitForExistence(timeout: 10), springboard.debugDescription)
        edit.tap()
        springboard.buttons["Add Widget"].tap()
        let search = springboard.searchFields["Search Widgets"]
        XCTAssertTrue(search.waitForExistence(timeout: 10), springboard.debugDescription)
        search.tap()
        search.typeText("CardWise")
        let gallery = springboard.collectionViews["add-sheet-collection-view"]
        let cardwise = gallery.descendants(matching: .any).matching(NSPredicate(format: "label == %@", "CardWise")).firstMatch
        let ready = XCTNSPredicateExpectation(predicate: NSPredicate(format: "isHittable == true"), object: cardwise)
        let result = XCTWaiter.wait(for: [ready], timeout: 45)
        attachScreenshot(springboard, name: "Widget gallery listing")
        XCTAssertEqual(result, .completed, springboard.debugDescription)
        cardwise.tap()
        var attempts = 0
        while !springboard.staticTexts["Unused Statement Credits"].exists && attempts < 17 {
            springboard.swipeLeft()
            attempts += 1
        }
        attachScreenshot(springboard, name: "Unused credits gallery")
        XCTAssertTrue(springboard.staticTexts["Unused Statement Credits"].exists, springboard.debugDescription)
        springboard.swipeLeft()
        attachScreenshot(springboard, name: "Unused credits medium")
        springboard.swipeLeft()
        attachScreenshot(springboard, name: "Unused credits large")
        springboard.swipeRight()
        springboard.swipeRight()
        let addWidget = springboard.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Add Widget")).firstMatch
        XCTAssertTrue(addWidget.exists)
        addWidget.tap()
        let done = springboard.buttons["Done"]
        if done.waitForExistence(timeout: 5) { done.tap() }
        attachScreenshot(springboard, name: "Installed unused credits")
        let widget = springboard.descendants(matching: .any).matching(
            NSPredicate(format: "label == %@ AND value CONTAINS %@", "CardWise", "Widget")
        ).firstMatch
        XCTAssertTrue(widget.waitForExistence(timeout: 10), springboard.debugDescription)
        widget.tap()
        XCTAssertTrue(app.staticTexts["Unused Credits"].waitForExistence(timeout: 10), app.debugDescription)
        let amount = app.textFields["Used amount for DoorDash credit"]
        XCTAssertTrue(amount.waitForExistence(timeout: 5))
        XCTAssertEqual(amount.value as? String, "3.5")
    }

    @MainActor
    private func launchWallet() -> XCUIApplication {
        let app = XCUIApplication(bundleIdentifier: "studio.tmj.cardwise")
        app.launchEnvironment["XCTestConfigurationFilePath"] = "CardWiseSmoke"
        app.launchArguments = ["-hasCompletedOnboarding", "YES", "-lastSeenVersion", "1.0.6"]
        app.launch()
        XCTAssertTrue(app.buttons["What are you buying?"].waitForExistence(timeout: 15))
        let credit = app.buttons["Update DoorDash credit for Chase Sapphire Preferred"]
        if !credit.exists {
            app.buttons["My Cards"].tap()
            app.buttons["Add Your First Card"].tap()
            let card = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Chase Sapphire Preferred,")).firstMatch
            XCTAssertTrue(card.waitForExistence(timeout: 5))
            card.tap()
            app.buttons["Add Card"].tap()
            app.buttons["Home"].tap()
        }
        return app
    }

    @MainActor
    private func enterPartialCreditUsage(in app: XCUIApplication) {
        let credit = app.buttons["Update DoorDash credit for Chase Sapphire Preferred"]
        XCTAssertTrue(credit.waitForExistence(timeout: 10), app.debugDescription)
        credit.tap()
        let amount = app.textFields["Used amount for DoorDash credit"]
        var scrolls = 0
        while !amount.isHittable && scrolls < 6 {
            app.swipeUp()
            scrolls += 1
        }
        XCTAssertTrue(amount.isHittable)
        amount.tap()
        amount.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 8))
        amount.typeText("3.5")
        let remaining = app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "$6.50 left")).firstMatch
        XCTAssertTrue(remaining.waitForExistence(timeout: 5))
        app.buttons["Save"].tap()
        XCTAssertTrue(app.staticTexts["$6.50"].waitForExistence(timeout: 5))
    }

    @MainActor
    private func attachScreenshot(_ app: XCUIApplication, name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
