//
//  ConfigurationManager.swift
//  skatecreteordie
//
//  Copyright 2016-2024 jaemzware llc
//  Licensed under the Apache License, Version 2.0
//
import Foundation

enum ConfigurationError: Error {
    case missingConfiguration
    case invalidConfigurationFile
    case missingKey(String)
}

class ConfigurationManager {
    static let shared = ConfigurationManager()
    private let configuration: [String: Any]
    
    private init() {
        guard let path = Bundle.main.path(forResource: "Configuration", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any] else {
            fatalError("Configuration.plist not found")
        }
        self.configuration = dict
    }
    
    var parkDataBaseURL: String {
        guard let endpoints = configuration["APIEndpoints"] as? [String: Any],
              let url = endpoints["ParkDataBaseURL"] as? String else {
            fatalError("Park Data URL not configured")
        }
        return url
    }
    
    var parkImagesBaseURL: String {
        guard let endpoints = configuration["APIEndpoints"] as? [String: Any],
              let url = endpoints["ParkImagesBaseURL"] as? String else {
            fatalError("Park Images URL not configured")
        }
        return url
    }
    
    var environment: String {
        guard let env = configuration["Environment"] as? String else {
            return "development"
        }
        return env
    }
    
}
