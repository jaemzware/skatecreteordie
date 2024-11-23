//
//  SkatePark.swift
//  skatecreteordie
//
//  Created by JAMES K ARASIM on 3/26/16.
//  Copyright 2016-2024 jaemzware llc
//  Licensed under the Apache License, Version 2.0
//
import Foundation

class SkatePark: NSObject {
    var name:String? = "";
    var address:String? = "";
    var id:String? = "";
    var builder:String? = "";
    var sqft:String? = "";
    var lights:String? = "";
    var covered:String? = "";
    var url:String? = "";
    var elements:String? = "";
    var pinimage:String? = "";
    var photos:[String]? = "".components(separatedBy: " ");
    var latitude:String? = "";
    var longitude:String? = "";
    var group:String? = "";
    
    static let imageHostUrl:String = ConfigurationManager.shared.parkImagesBaseURL
    
    init(name:String,
         address:String,
         id:String,
         builder:String,
         sqft:String,
         lights:String,
         covered:String,
         url:String,
         elements:String,
         pinimage:String,
         photos:[String],
         latitude:String,
         longitude:String,
         group:String)
    {
        self.name = name
        self.address = address
        self.id = id
        self.builder = builder
        self.sqft = sqft
        self.lights = lights
        self.covered = covered
        self.url = url
        self.elements = elements
        self.pinimage = pinimage
        self.photos = photos
        self.latitude = latitude
        self.longitude = longitude
        self.group = group
    }
}
