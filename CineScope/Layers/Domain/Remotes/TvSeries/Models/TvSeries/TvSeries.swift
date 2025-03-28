//
//  TvSeries.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/7/25.
//

import Foundation

// MARK: - Tv Series

struct TvSeries: Decodable {
    let posterPath: String?
    let id: Int
    let name: String

    var fullPosterURL: String? {
        guard let posterPath = posterPath else { return nil }
        return "https://image.tmdb.org/t/p/w500\(posterPath)"
    }

    enum CodingKeys: String, CodingKey {
        case posterPath = "poster_path"
        case id, name
    }
}

// MARK: - TvSeriesResponse

struct TvSeriesResponse: Decodable {
    let results: [TvSeries]
}

enum TvSeriesCategory: String {
    case airingToday = "airing_today"
    case onTheAir = "on_the_air"
    case popular
    case topRated = "top_rated"
    case trending

    static var orderedCategories: [TvSeriesCategory] {
        return [.trending, .airingToday, .onTheAir, .popular, .topRated]
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
        case .trending:
            return ""
        }
    }
}
