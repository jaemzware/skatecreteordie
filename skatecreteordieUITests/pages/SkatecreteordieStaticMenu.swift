//
//  Static.swift
//  skatecreteordieUITests
//
//  Created by JAMES K ARASIM on 11/9/19.
//  Copyright © 2019 JAMES K ARASIM. All rights reserved.
//

import Foundation
import XCTest

//use enum to store page objects
enum SkatecreteordieStaticMenu: String {
    case mapButton = "map"
    case detailsButton = "details"
    case listButton = "list"
    
    var element: XCUIElement {

        switch self {
        case .mapButton, .detailsButton, .listButton:
                return XCUIApplication().tabBars.buttons[self.rawValue]
        }
    }
}
