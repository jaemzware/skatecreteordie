//
//  TapAddressAnnotations.swift
//  skatecreteordie
//
//  Created by JAMES K ARASIM on 4/5/16.
//  Copyright © 2016 JAMES K ARASIM. All rights reserved.
//

import XCTest

@available(iOS 9.0, *)
class ZoomTapAddressAnnotation: TestHelper {
        
    func testZoomTapAddressAnnotation() {
        let app = XCUIApplication()
        
        let mapButton = app.buttons[mapButtonLabel]
        let detailsButton = app.buttons[detailsButtonLabel]
        
        waitFor(mapButton, seconds: defaultWait)
        waitFor(map(), seconds: defaultWait)

        map().pinchWithScale(4.5, velocity: 3)
        
        var unobstructedAddressToTap = XCUIElement()
        
        if let parkPinToTap=constructPinLabelNameFromParkName("Yelm Skatepark"){
            print("PARKPINTOTAP:\(parkPinToTap)")
            printElements()
            
            unobstructedAddressToTap = app.otherElements[parkPinToTap]
            waitFor(unobstructedAddressToTap, seconds: defaultWait)
            
            unobstructedAddressToTap.tap()
            detailsButton.tap()
            
            waitFor(app.textViews["parkAddressAndTerrainTextView"],seconds: defaultWait)
            
            mapButton.tap()
            waitFor(map(),seconds: defaultWait)
        }
        else{
            XCTAssert(false, "TEST ISSUE: COULDNT GET PIN LABEL NAME")
        }
    }
}


