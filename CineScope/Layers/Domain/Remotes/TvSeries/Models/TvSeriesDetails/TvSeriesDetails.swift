//
//  TvSeriesDetails.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 3/3/25.
//

import Foundation

struct TvSeriesDetails: Decodable {
    let id: Int?
    let name: String?
    let firstAirDate: String?
    let lastAirDate: String?
    let overview: String?
    let posterPath: String?
    let voteAverage: Double?
    let numberOfEpisodes: Int?
    let numberOfSeasons: Int?
    let genres: [TvGenre]?
    
    // Tam boyutlu poster URL'si döndürmek için computed property
    var fullPosterURL: String {
        guard let posterPath else { return "" }
        return "https://image.tmdb.org/t/p/w500\(posterPath)"
    }
    
    // 📌 First Air Date'i sadece yıl olarak döndürme
    var firstAirYear: String {
        guard let firstAirDate = firstAirDate else { return "N/A" }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = dateFormatter.date(from: firstAirDate) {
            let yearFormatter = DateFormatter()
            yearFormatter.dateFormat = "yyyy"
            return yearFormatter.string(from: date)
        }
        
        return "N/A"
    }
    
    // 📌 Last Air Date'i sadece yıl olarak döndürme
    var lastAir: String {
        guard let lastAirDate = lastAirDate else { return "N/A" }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = dateFormatter.date(from: lastAirDate) {
            let yearFormatter = DateFormatter()
            yearFormatter.dateFormat = "yyyy"
            return yearFormatter.string(from: date)
        }
        
        return "-"
    }

    enum CodingKeys: String, CodingKey {
        case id, name, overview, genres
        case firstAirDate = "first_air_date"
        case lastAirDate = "last_air_date"
        case posterPath = "poster_path"
        case voteAverage = "vote_average"
        case numberOfEpisodes = "number_of_episodes"
        case numberOfSeasons = "number_of_seasons"
    }
}

// MARK: - Genre
struct TvGenre: Decodable {
    let id: Int
    let name: String
}
