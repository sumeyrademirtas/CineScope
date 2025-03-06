//
//  ApiConstants.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 1/29/25.
//

import Foundation

struct ApiConstants {
    let apiKey: String
    let apiHost: String

    init() {
        guard let path = Bundle.main.path(forResource: "config", ofType: "plist"),
              let dictionary = NSDictionary(contentsOfFile: path) else {
            fatalError("Config.plist not found")
        }

        guard let apiKey = dictionary["API_KEY"] as? String else {
            fatalError("API_KEY not found in Config.plist")
        }

        guard let apiHost = dictionary["API_HOST"] as? String else {
            fatalError("API_HOST not found in Config.plist")
        }

        self.apiKey = apiKey
        self.apiHost = apiHost
    }
}
