//
//  TestCenterLocationButton.swift
//  skatecreteordieUITests
//
//  Created by JAMES KENNETH ARASIM on 3/10/22.
//  Copyright © 2022 JAMES K ARASIM. All rights reserved.
//

import Foundation

import XCTest

@available(iOS 13.0, *)
class TestCenterLocationButton: TestBase {

    func testCenterLocationButton() {
        
        let app = XCUIApplication()
        let pinbutton = app.buttons["pinbutton"]
        pinbutton.tap()        
    }
}
