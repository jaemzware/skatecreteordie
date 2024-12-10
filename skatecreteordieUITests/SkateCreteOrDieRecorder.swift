import XCTest

class SkateCreteOrDieRecorder: XCTestCase {
    
    func testRecord() {
        let app = XCUIApplication()
        app.launch()
        //BEGINRECORD
        
        let tabBar = XCUIApplication().tabBars["Tab Bar"]
        tabBar.buttons["list"].tap()
        tabBar.buttons["details"].tap()
                        
        
        
        //ENDRECORD
    }
}
