//
//  GenreMovie.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 3/25/25.
//

import Foundation

// MARK: - Genre Listesi Ana Model
struct GenreMovieResponse: Codable {
    let genres: [GenreMovie]
}

// MARK: - Tekil Genre Modeli
struct GenreMovie: Codable {
    let id: Int
    let name: String
}
