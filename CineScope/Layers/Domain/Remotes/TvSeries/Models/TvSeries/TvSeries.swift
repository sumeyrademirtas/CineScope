//
//  TvSeries.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/7/25.
//

import Foundation

// MARK: - Tv Series
struct TvSeries: Decodable {
    let posterPath: String
    
    var fullPosterURL: String {
        let baseUrl = "https://image.tmdb.org/t/p/w500"
        return "\(baseUrl)\(posterPath)"
    }
    
    enum CodingKeys: String, CodingKey {
        case posterPath = "poster_path"
    }
}


// MARK: - TvSeriesResponse
struct TvSeriesResponse: Decodable {
    let results: [TvSeries]
}

enum TvSeriesCategory: String {
    case airingToday = "airing_today"
    case onTheAir = "on_the_air"
    case popular = "popular"
    case topRated = "top_rated"
    
    static var orderedCategories: [TvSeriesCategory] {
        return [.airingToday, .onTheAir, .popular, .topRated]
    }
    
    var displayName: String {
        switch self {
        case .airingToday:
            return "Airing Today"
        case .onTheAir:
            return "On The Air"
        case .popular:
            return "Popular"
        case .topRated:
            return "Top Rated"
        }
    }
}

