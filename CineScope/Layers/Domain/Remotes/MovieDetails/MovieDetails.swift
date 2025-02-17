//
//  MovieDetails.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/15/25.
//

import Foundation

// MARK: - Movie Details

struct MovieDetails: Decodable {
    let id: Int
    let title: String
    let overview: String
    let releaseDate: String
    let runtime: Int?
    let voteAverage: Double
    let posterPath: String?
    let backdropPath: String?
    let genres: [Genre]?
    let originCountry: [String]?
    let originalLanguage: String?
    let video: Bool?
    
    // Tam boyutlu poster URL'si döndürmek için computed property
    var fullPosterURL: String {
        guard let posterPath else { return "" }
        return "https://image.tmdb.org/t/p/w500\(posterPath)"
    }
    
    var backgropPathURL: String {
        guard let backdropPath else { return "" }
        return "https://image.tmdb.org/t/p/w500\(backdropPath)"
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title, overview, genres, runtime, video
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case originCountry = "origin_country"
        case originalLanguage = "original_language"
    }
}

// MARK: - Genre
struct Genre: Decodable {
    let id: Int
    let name: String
}
