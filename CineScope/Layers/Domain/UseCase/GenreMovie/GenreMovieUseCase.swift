//
//  GenreMovieUseCase.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 3/25/25.
//

import Foundation
import Combine

// MARK: - Protocol Definition
protocol GenreMovieUseCase {
    func fetchMovieGenres() -> AnyPublisher<GenreMovieResponse?, Error>?
}

// MARK: - Implementation
struct GenreMovieUseCaseImpl: GenreMovieUseCase {
    private let service: GenreMovieService

    init(service: GenreMovieService) {
        self.service = service
    }

    func fetchMovieGenres() -> AnyPublisher<GenreMovieResponse?, Error>? {
        guard let genrePublisher = getMovieGenres(api: .getMovieGenres) else {
            return nil
        }
        return genrePublisher.eraseToAnyPublisher()
    }
}

// MARK: - Private API Helper
private extension GenreMovieUseCaseImpl {
    func getMovieGenres(api: GenreMovieApi) -> AnyPublisher<GenreMovieResponse?, Error>? {
        service.getMovieGenres(api: api)
    }
}
