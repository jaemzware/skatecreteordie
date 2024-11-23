//
//  TestHelper.swift
//  skatecreteordie
//
//  Created by JAMES K ARASIM on 3/31/16.
//  Copyright © 2016 JAMES K ARASIM. All rights reserved.
//

import XCTest

let defaultWait:Double = 15.0

extension String {
    func contains(_ find: String) -> Bool{
        return self.range(of: find) != nil
    }
}

extension XCUIElement {
    func scrollToElement(element: XCUIElement) {
        while !element.visible() {
            swipeUp()
        }
    }

    func visible() -> Bool {
        guard self.exists && !self.frame.isEmpty else { return false }
        return XCUIApplication().windows.element(boundBy: 0).frame.contains(self.frame)
    }
}

@available(iOS 9.0, *)
class TestBase: XCTestCase {
    
    var app = XCUIApplication()
    
    var mapButtonLabel = "map"
    var detailsButtonLabel = "details"
    var listingButtonLabel = "listing"
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app.launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    //UTILITY CONTENT
    func waitFor(_ element:XCUIElement, seconds waitSeconds:Double) {
        let _ = element.waitForExistence(timeout: waitSeconds)
    }
    
    //PAGE OBJECT CONTENT
    func webview() -> XCUIElement{
        let map = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 1).children(matching: .other).element.children(matching: .other).element
        return map
    }
    
    func map() -> XCUIElement{
        let map =  app.maps.element(boundBy: 0)
        return map
    }
}

