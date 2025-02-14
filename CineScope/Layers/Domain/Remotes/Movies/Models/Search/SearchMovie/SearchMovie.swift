//
//  Search.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/11/25.
//

import Foundation

// MARK: Search Movie

struct SearchMovie: Decodable {
    let posterPath: String
    let name: String
    

    var fullPosterURL: String {
        let baseURL = "https://image.tmdb.org/t/p/w500" // Resim için temel URL
        return "\(baseURL)\(posterPath)"
    }
    
    enum CodingKeys: String, CodingKey {
        case posterPath = "poster_path"
        case name = "name"
    }
}

// MARK: SearchMovieResponse
struct SearchMovieResponse: Decodable {
    let results: [SearchMovie]
}
