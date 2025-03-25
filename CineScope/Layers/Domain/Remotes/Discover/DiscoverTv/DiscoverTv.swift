//
//  DiscoverTv.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 3/25/25.
//

import Foundation

// MARK: - Ana Discover TV Response
struct DiscoverTvResponse: Codable {
    let page: Int?
    let results: [DiscoverTv]?
    let totalPages: Int?
    let totalResults: Int?
    
    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

// MARK: - Tekil TV Show Modeli
struct DiscoverTv: Codable {
    let adult: Bool?
    let backdropPath: String?
    let genreIDs: [Int]?
    let id: Int?
    let originCountry: [String]?
    let originalLanguage: String?
    let originalName: String?
    let overview: String?
    let popularity: Double?
    let posterPath: String?
    let firstAirDate: String?
    let name: String?
    let voteAverage: Double?
    let voteCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case adult
        case backdropPath = "backdrop_path"
        case genreIDs = "genre_ids"
        case id
        case originCountry = "origin_country"
        case originalLanguage = "original_language"
        case originalName = "original_name"
        case overview
        case popularity
        case posterPath = "poster_path"
        case firstAirDate = "first_air_date"
        case name
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
}
