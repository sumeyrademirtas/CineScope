//
//  SearchTvSeries.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 3/17/25.
//

import Foundation

// MARK: Search Tv Series

struct SearchTvSeries: Decodable {
    let posterPath: String?
    let name: String
    
    var fullPosterURL: String? {
        guard let posterPath = posterPath, !posterPath.isEmpty else { return nil }
        let baseURL = "https://image.tmdb.org/t/p/w500"
        return "\(baseURL)\(posterPath)"
    }
    
    enum CodingKeys: String, CodingKey {
        case posterPath = "poster_path"
        case name
    }
}

// MARK: SearchMovieResponse
struct SearchTvSeriesResponse: Decodable {
    let results: [SearchTvSeries]
}
