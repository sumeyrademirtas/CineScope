//
//  Movie.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 1/29/25.
//

import Foundation

// MARK: - Movie
struct Movie: Decodable {
    let posterPath: String  // su anlik isim sadece posterpath ile.
    // daha sonra eklemeler yapacagim.
    
    var fullPosterURL: String {
        let baseURL = "https://image.tmdb.org/t/p/w500" // Resim için temel URL
        return "\(baseURL)\(posterPath)"
    }
    
    enum CodingKeys: String, CodingKey {
        case posterPath = "poster_path"
    }
}


// MARK: - MoviesResponse
struct MoviesResponse: Decodable {
    let results: [Movie]
}


enum MovieCategory: String {    // MARK: - Mahsuna sor. MovieCategory yerine baska bir sekilde daha temiz yapabilir miydik? Bu cok mu sacma olmus?
    case nowPlaying = "now_playing"
    case topRated = "top_rated"
    case popular = "popular"
    case upcoming = "upcoming"
    
    static var orderedCategories: [MovieCategory] {
        return [.popular, .upcoming, .nowPlaying, .topRated]
    }
    
    
    var displayName: String { // Burayi header title icin yaptim.
            switch self {
            case .nowPlaying:
                return "Now Playing"
            case .popular:
                return "Popular Movies"
            case .topRated:
                return "Top Rated"
            case .upcoming:
                return "Upcoming"
            }
        }
}
