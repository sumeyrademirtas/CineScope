//
//  TvSeriesCredits.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 3/3/25.
//

import Foundation

// MARK: - TvSeriesCredits
struct TvSeriesCredits: Decodable {
    let id: Int
    let cast: [TvSeriesCast]

    enum CodingKeys: String, CodingKey {
        case id, cast
    }
}

// MARK: - TvSeriesCast (Her bir oyuncu için)
struct TvSeriesCast: Decodable {
    let id: Int?
    let name: String?
    let profilePath: String?
    let castID: Int?
    let character, creditID: String?
    
    var profilePathURL: String {
        guard let profilePath else { return "" }
        return "https://image.tmdb.org/t/p/w500\(profilePath)"
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case profilePath = "profile_path"
        case castID = "cast_id"
        case character
        case creditID = "credit_id"
    }
}
