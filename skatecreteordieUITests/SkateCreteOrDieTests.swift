// SkatecreteDieTests.swift
import XCTest

class SkateCreteOrDieTests: XCTestCase {
    let app = XCUIApplication()
    var mapScreen: MapScreen!
    var detailsScreen: DetailsScreen!
    var listScreen: ListScreen!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app.launch()
        
        // Initialize screens
        mapScreen = MapScreen(app: app)
        detailsScreen = DetailsScreen(app: app)
        listScreen = ListScreen(app: app)
    }

    func testTabNavigation() {
        // Test Map Screen
        mapScreen.tapMapTab()
        XCTAssertTrue(mapScreen.isDisplayed(), "Map screen should be displayed")
        XCTAssertTrue(mapScreen.resetButton.exists, "Reset button should be visible on map screen")
        
        // Test Details Screen
        detailsScreen.tapDetailsTab()
        XCTAssertTrue(detailsScreen.isDisplayed(), "Details screen should be displayed")
        XCTAssertTrue(detailsScreen.locationButton.exists, "Location button should be visible on details screen")
        
        // Test List Screen
        listScreen.tapListTab()
        XCTAssertTrue(listScreen.isDisplayed(), "List screen should be displayed")
        XCTAssertTrue(listScreen.parkListTableView.exists, "Park list table should be visible on list screen")
    }
//    
//    func testPrintElements() {
//        let app = XCUIApplication()
//        app.launch()
//        print(app.debugDescription)
//    }
}
