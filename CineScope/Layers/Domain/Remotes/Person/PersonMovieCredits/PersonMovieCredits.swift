//
//  PersonMovieCredits.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/24/25.
//

import Foundation

// Ana model
struct PersonMovieCreditsResponse: Codable {
    let cast: [PersonMovieCredits]
}

// Filmde oynayan oyuncuların modeli
struct PersonMovieCredits: Codable {
    let id: Int
    let posterPath: String
    
    var fullPosterURL: String {
        let baseURL = "https://image.tmdb.org/t/p/w500" // Resim için temel URL
        return "\(baseURL)\(posterPath)"
    }

    enum CodingKeys: String, CodingKey {
        case id
        case posterPath = "poster_path"
    }
}
