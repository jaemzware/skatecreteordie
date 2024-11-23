//
//  WwwParkListingPage.swift
//  skatecreteordieUITests
//
//  Created by JAMES K ARASIM on 11/10/19.
//  Copyright © 2019 JAMES K ARASIM. All rights reserved.
//

import Foundation
import XCTest

//use enum to store page objects
enum WwwParkListingPage: String {
    case aberdeenSkateparkLink = "Aberdeen Skatepark"
    case abenraaSkateparkLink = "Abenraa Skatepark"
    case areaDropDown
    case pickerWheel
    case doneButton = "Done"
    case videosLabel = "VIDEOS"
    case chatAliasField = "alias"
    case chatMessageField = "message"
    
    var element: XCUIElement {

        switch self {
        case .aberdeenSkateparkLink, .abenraaSkateparkLink, .videosLabel:
                return XCUIApplication().staticTexts[self.rawValue]
            case .areaDropDown:
                return XCUIApplication().otherElements["WASHINGTON"]
            case .pickerWheel:
                return XCUIApplication().pickerWheels["WASHINGTON"]
            case .doneButton:
                return XCUIApplication().toolbars.buttons[self.rawValue]
            case .chatAliasField, .chatMessageField:
                return XCUIApplication().textFields[self.rawValue]
        }
    }
}
