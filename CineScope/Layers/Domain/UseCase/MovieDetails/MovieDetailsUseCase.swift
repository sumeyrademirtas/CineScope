//
//  MovieDetailsUseCase.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/16/25.
//

import Combine
import Foundation

// MARK: - Protocol Definition

protocol MovieDetailsUseCase {
    func fetchMovieDetails(movieId: Int) -> AnyPublisher<MovieDetails?, Error>?
}

struct MovieDetailsUseCaseImpl: MovieDetailsUseCase {
    private let service: MovieDetailsService

    init(service: MovieDetailsService) {
        self.service = service
    }

    func fetchMovieDetails(movieId: Int) -> AnyPublisher<MovieDetails?, any Error>? {
        guard let movieDetailsPublisher = getMovieDetails(api: .getMovieDetails(movieId: movieId)) else { return nil }
        return movieDetailsPublisher.eraseToAnyPublisher()
    }
}

extension MovieDetailsUseCaseImpl {
    func getMovieDetails(api: MovieDetailsApi) -> AnyPublisher<MovieDetails?, any Error>? {
        service.getMovieDetails(api: api)
    }
}
