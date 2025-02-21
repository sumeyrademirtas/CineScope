//
//  MovieCredits.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/21/25.
//

import Foundation

// MARK: - MovieCredits 
struct MovieCredits: Decodable {
    let id: Int
    let cast: [Cast]  // 🎬 Oyuncuları içeren dizi

    enum CodingKeys: String, CodingKey {
        case id, cast
    }
}

// MARK: - Cast (Her bir oyuncu için)
struct Cast: Decodable {
    let adult: Bool?
    let gender, id: Int?
    let knownForDepartment, name, originalName: String?
    let popularity: Double?
    let profilePath: String?
    let castID: Int?
    let character, creditID: String?
    let order: Int?
    
    var profilePathURL: String {
        guard let profilePath else { return "" }
        return "https://image.tmdb.org/t/p/w500\(profilePath)"
    }

    enum CodingKeys: String, CodingKey {
        case adult, gender, id
        case knownForDepartment = "known_for_department"
        case name
        case originalName = "original_name"
        case popularity
        case profilePath = "profile_path"
        case castID = "cast_id"
        case character
        case creditID = "credit_id"
        case order
    }
}
