//
//  ApiConstants.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 1/29/25.
//

import Foundation

// Bu constantslari Edit Scheme > Run > Arguments icinde sakliyorum.
// ProcessInfo.processInfo.environment ile okuyorum.

struct ApiConstants {
    let apiKey: String
    let apiHost: String

    init() {
        guard let apiKey = ProcessInfo.processInfo.environment["API_KEY"] else {
            fatalError("API_KEY not found in Environment Variables")
        }
        guard let apiHost = ProcessInfo.processInfo.environment["API_HOST"] else {
            fatalError("API_HOST not found in Environment Variables")
        }
        self.apiKey = apiKey
        self.apiHost = apiHost
    }
}
