//
//  GenreTv.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 3/25/25.
//

import Foundation

// MARK: - TV Genre Listesi Ana Model
struct GenreTvResponse: Codable {
    let genres: [GenreTv]
}

// MARK: - Tekil TV Genre Modeli
struct GenreTv: Codable {
    let id: Int
    let name: String
}
