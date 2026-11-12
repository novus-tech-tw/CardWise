import XCTest
import Vision

final class WalletWidgetTests: XCTestCase {
    @MainActor
    func testOfferBrowserSearchCardFilterAndHistory() throws {
        continueAfterFailure = false
        let app = launchWallet()
        app.buttons["Offers"].tap()
        XCTAssertTrue(app.navigationBars["Your Offers"].waitForExistence(timeout: 10))
        app.buttons["Chase Sapphire Preferred"].firstMatch.tap()
        app.buttons["Add an offer"].tap()
        let merchant = app.textFields["Merchant"]
        XCTAssertTrue(merchant.waitForExistence(timeout: 5))
        merchant.tap()
        merchant.typeText("Acceptance Café")
        app.textFields["Offer description"].tap()
        app.textFields["Offer description"].typeText("Save on a purchase")
        let reward = app.textFields["Cash Back ($)"]
        reward.tap()
        reward.typeText("20")
        app.buttons["Save"].tap()
        XCTAssertTrue(app.navigationBars["Merchant Offers"].waitForExistence(timeout: 5))
        app.navigationBars["Merchant Offers"].buttons.firstMatch.tap()
        let current = app.staticTexts["1 current offer"]
        XCTAssertTrue(current.waitForExistence(timeout: 5), app.debugDescription)
        let search = app.searchFields.firstMatch
        XCTAssertTrue(search.waitForExistence(timeout: 5), app.debugDescription)
        search.tap()
        search.typeText("no match")
        XCTAssertTrue(app.staticTexts["No offers match your search."].waitForExistence(timeout: 5))
        search.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 8))
        search.typeText("cafe")
        XCTAssertTrue(app.staticTexts["Acceptance Café"].waitForExistence(timeout: 5))
        app.buttons["Close"].tap()
        app.buttons["offer-card-filter"].tap()
        app.buttons["Chase Sapphire Preferred"].firstMatch.tap()
        XCTAssertTrue(app.buttons["offer-card-filter"].label.contains("Chase Sapphire Preferred"))
        XCTAssertTrue(current.waitForExistence(timeout: 5))
        assertRepeatedOfferWidgetLink(in: app)
        let used = app.switches["I received the offer savings"].switches.firstMatch
        for _ in 0..<5 {
            if used.exists, used.isHittable, used.frame.maxY < app.frame.maxY - 100 { break }
            app.swipeUp()
        }
        XCTAssertTrue(used.isHittable)
        used.tap()
        XCTAssertEqual(used.value as? String, "1")
        let received = app.textFields["Savings Received ($)"]
        XCTAssertTrue(received.waitForExistence(timeout: 5))
        for _ in 0..<5 where !received.isHittable { app.swipeUp() }
        received.tap()
        received.typeText("4.50")
        app.buttons["Save"].tap()
        XCTAssertTrue(app.navigationBars["Merchant Offers"].waitForExistence(timeout: 5))
        app.navigationBars["Merchant Offers"].buttons.firstMatch.tap()
        XCTAssertTrue(app.staticTexts["0 current offers"].waitForExistence(timeout: 5))
        app.buttons["offer-status-filter"].tap()
        app.buttons["Used"].tap()
        XCTAssertTrue(app.staticTexts["1 used offer"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Used · savings recorded by you"].exists)
        attachScreenshot(app, name: "Offer browser used history")
        app.terminate()
    }

    @MainActor
    private func assertRepeatedOfferWidgetLink(in app: XCUIApplication) {
        let springboard = installWalletWidget(titled: "Saved Offers", text: "Acceptance Café")
        widget(containing: "Acceptance Café", in: springboard).tap()
        XCTAssertTrue(app.navigationBars["Edit Offer"].waitForExistence(timeout: 30), app.debugDescription)
        XCTAssertEqual(app.textFields["Merchant"].value as? String, "Acceptance Café")
        app.buttons["Cancel"].tap()
        app.navigationBars["Merchant Offers"].buttons.firstMatch.tap()
        XCTAssertTrue(app.navigationBars["Your Offers"].firstMatch.waitForExistence(timeout: 5))
        // Tap the same installed widget while its offers sheet remains open.
        XCUIDevice.shared.press(.home)
        waitForVisibleText("Acceptance Café", in: springboard)
        widget(containing: "Acceptance Café", in: springboard).tap()
        XCTAssertTrue(app.navigationBars["Edit Offer"].waitForExistence(timeout: 30), app.debugDescription)
        XCTAssertEqual(app.textFields["Merchant"].value as? String, "Acceptance Café")
        attachScreenshot(app, name: "Repeated offer widget link opens the same record")
    }

    @MainActor
    func testUnusedCreditWidgetOpensRecordedCredit() throws {
        continueAfterFailure = false
        let app = launchWallet()
        enterPartialCreditUsage(in: app)
        let springboard = installWalletWidget(titled: "Unused Statement Credits", text: "6.50")
        widget(containing: "6.50", in: springboard).tap()
        XCTAssertTrue(app.staticTexts["Unused Credits"].waitForExistence(timeout: 10), app.debugDescription)
        let amount = app.textFields["Used amount for DoorDash credit"]
        XCTAssertTrue(amount.waitForExistence(timeout: 5))
        XCTAssertEqual(amount.value as? String, "3.5")
    }

    @MainActor
    private func installWalletWidget(titled title: String, text: String) -> XCUIApplication {
        XCUIDevice.shared.press(.home)
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let icon = springboard.icons["CardWise"].firstMatch
        XCTAssertTrue(icon.waitForExistence(timeout: 10))
        attachScreenshot(springboard, name: "Home before installing " + title)
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
        while !springboard.staticTexts[title].exists && attempts < 17 {
            springboard.swipeLeft()
            attempts += 1
        }
        waitForVisibleText(text, in: springboard)
        attachScreenshot(springboard, name: title + " small")
        XCTAssertTrue(springboard.staticTexts[title].exists, springboard.debugDescription)
        springboard.swipeLeft()
        waitForVisibleText(text, in: springboard)
        attachScreenshot(springboard, name: title + " medium")
        springboard.swipeLeft()
        waitForVisibleText(text, in: springboard)
        attachScreenshot(springboard, name: title + " large")
        springboard.swipeRight()
        springboard.swipeRight()
        let addWidget = springboard.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Add Widget")).firstMatch
        XCTAssertTrue(addWidget.exists)
        addWidget.tap()
        let done = springboard.buttons["Done"]
        if done.waitForExistence(timeout: 5) { done.tap() }
        waitForVisibleText(text, in: springboard)
        attachScreenshot(springboard, name: "Installed " + title)
        return springboard
    }

    @MainActor
    private func widget(containing text: String, in springboard: XCUIApplication) -> XCUIElement {
        let widgets = springboard.descendants(matching: .any).matching(
            NSPredicate(format: "label == %@ AND value CONTAINS %@", "CardWise", "Widget")
        ).allElementsBoundByIndex
        let point = visibleTextPoint(text, in: springboard)
        let match = widgets.first { widget in point.map { widget.frame.contains($0) } ?? false }
        XCTAssertNotNil(match, "An installed CardWise widget must contain the rendered text: \(text)")
        return match ?? springboard.otherElements["Missing rendered widget"]
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
    private func visibleTextPoint(_ text: String, in app: XCUIApplication) -> CGPoint? {
        guard let image = app.screenshot().image.cgImage else { return nil }
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["en-US"]
        do {
            try VNImageRequestHandler(cgImage: image, options: [:]).perform([request])
        } catch {
            return nil
        }
        guard let observation = request.results?.first(where: {
            $0.topCandidates(1).first?.string.localizedStandardContains(text) == true
        }) else { return nil }
        let box = observation.boundingBox
        return CGPoint(x: app.frame.minX + box.midX * app.frame.width,
                       y: app.frame.minY + (1 - box.midY) * app.frame.height)
    }

    @MainActor
    private func waitForVisibleText(_ text: String, in app: XCUIApplication) {
        let rendered = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in
            self.visibleTextPoint(text, in: app) != nil
        }, object: nil)
        XCTAssertEqual(XCTWaiter.wait(for: [rendered], timeout: 30), .completed,
                       "The widget must render \(text) before its screenshot is accepted.")
    }

    @MainActor
    private func attachScreenshot(_ app: XCUIApplication, name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
