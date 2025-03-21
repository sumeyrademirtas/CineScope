//
//  Search.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/11/25.
//

import Foundation

// MARK: Search Movie

struct SearchMovie: Decodable {
    let posterPath: String?
    let name: String
    let id: Int
    

    var fullPosterURL: String? {
        guard let posterPath = posterPath, !posterPath.isEmpty else { return nil }
        let baseURL = "https://image.tmdb.org/t/p/w500"
        return "\(baseURL)\(posterPath)"
    }
    
    enum CodingKeys: String, CodingKey {
        case posterPath = "poster_path"
        case name = "title"
        case id
    }
}

// MARK: SearchMovieResponse
struct SearchMovieResponse: Decodable {
    let results: [SearchMovie]
}
