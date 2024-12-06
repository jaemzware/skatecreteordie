// ListScreen.swift
import XCTest

class ListScreen: BaseScreen {
    // Elements
    var parkListTableView: XCUIElement {
        return app.tables.firstMatch
    }
    
    // Tab Bar Navigation
    func tapListTab() {
        app.tabBars["Tab Bar"].buttons["list"].tap()
    }
    
    // Verification
    func isDisplayed() -> Bool {
        return parkListTableView.exists
    }
}
