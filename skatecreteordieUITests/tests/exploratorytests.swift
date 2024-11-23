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
class TestAllMapButtons: TestBase {
    func testAllMapButtons(){
        let tabBar = app.tabBars["Tab Bar"]
        tabBar.buttons["map"].tap()
        app.buttons["resetbutton"].tap()
        app.buttons["pinbutton"].tap()
        app.buttons["copybutton"].tap()
    }
}
