// MapScreen.swift
import XCTest

class MapScreen: BaseScreen {
    // Elements
    var mapView: XCUIElement {
        return app.maps["map"]
    }
    
    var resetButton: XCUIElement {
        return app.buttons["resetbutton"]
    }
    
    var milesLabel: XCUIElement {
        return app.staticTexts["mileslabel"]
    }
    
    // Tab Bar Navigation
    func tapMapTab() {
        app.tabBars["Tab Bar"].buttons["map"].tap()
    }
    
    // Verification
    func isDisplayed() -> Bool {
        return mapView.exists
    }
}
