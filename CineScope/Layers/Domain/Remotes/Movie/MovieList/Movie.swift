//
//  Movie.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 1/29/25.
//

import Foundation

// MARK: - Movie

struct Movie: Decodable {
    let posterPath: String?
    let id: Int
    let title: String

    var fullPosterURL: String? {
        guard let posterPath = posterPath else { return nil }
        return "https://image.tmdb.org/t/p/w500\(posterPath)"
    }

    enum CodingKeys: String, CodingKey {
        case posterPath = "poster_path"
        case id, title
    }
}

// MARK: - MoviesResponse

struct MovieResponse: Decodable {
    let results: [Movie]
}

enum MovieCategory: String {
    case nowPlaying = "now_playing"
    case topRated = "top_rated"
    case popular
    case upcoming
    case trending

    static var orderedCategories: [MovieCategory] {
        return [.trending, .popular, .upcoming, .nowPlaying, .topRated]
    }

    var displayName: String { // header title
        switch self {
        case .nowPlaying:
            return "Now Playing"
        case .popular:
            return "Popular Movies"
        case .topRated:
            return "Top Rated"
        case .upcoming:
            return "Upcoming"
        case .trending:
            return ""
        }
    }
}
