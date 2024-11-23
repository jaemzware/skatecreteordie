//
//  TestTabBar.swift
//  skatecreteordieUITests
//
//  Created by JAMES KENNETH ARASIM on 3/14/22.
//  Copyright © 2022 JAMES K ARASIM. All rights reserved.
//

import Foundation

import XCTest

@available(iOS 13.0, *)
class TestTabBar: TestBase {
    func testTabBar() {
        let tabBar = XCUIApplication().tabBars["Tab Bar"]
        tabBar.buttons["details"].tap()
        tabBar.buttons["list"].tap()
        tabBar.buttons["map"].tap()
    }
}
