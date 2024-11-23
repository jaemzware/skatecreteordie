//
//  TestZoomTapAddressAnnotation.swift
//  skatecreteordie
//
//  Created by JAMES K ARASIM on 6/2/16.
//  Copyright © 2016 JAMES K ARASIM. All rights reserved.
//

import XCTest

@available(iOS 13.0, *)
class TestTapAddressAnnotation: TestBase  {
    func testTapAddressAnnotation(){
        let app = XCUIApplication()
        app.otherElements["MarginalWaySkatepark, 1SHanfordSt,Seattle,WA98134"].tap()
        let tabBar = app.tabBars["Tab Bar"]
        tabBar.buttons["details"].tap()
        let image = app.scrollViews.children(matching: .image).element
        image.tap()
        image.tap()
        image.tap()
        tabBar.buttons["list"].tap()
    }
}
