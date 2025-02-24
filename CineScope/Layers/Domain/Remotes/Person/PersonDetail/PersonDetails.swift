//
//  PersonDetails.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/24/25.
//

import Foundation

struct PersonDetails: Decodable {
    let id: Int
    let name: String
    let biography: String?
    let birthday: String?
    let profilePath: String?

    enum CodingKeys: String, CodingKey {
        case id, name, biography, birthday
        case profilePath = "profile_path"
    }
    
    var profilePhotoURL: String? {
        guard let profilePath else { return nil }
        return "https://image.tmdb.org/t/p/w500\(profilePath)"
    }
}
