// DetailsScreen.swift
import XCTest

class DetailsScreen: BaseScreen {
    // Elements
    var parkNameLabel: XCUIElement {
        return app.staticTexts.matching(identifier: "parkNameLabel").element
    }
    
    var locationButton: XCUIElement {
        return app.buttons["locationButton"]
    }
    
    // Tab Bar Navigation
    func tapDetailsTab() {
        app.tabBars["Tab Bar"].buttons["details"].tap()
    }
    
    // Verification
    func isDisplayed() -> Bool {
        return parkNameLabel.exists
    }
}
