//
//  MovieCreditsUseCase.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/21/25.
//
import Foundation
import Combine

// MARK: - Protocol Definition
protocol MovieCreditsUseCase {
    func fetchMovieCredits(movieId: Int) -> AnyPublisher<MovieCredits?, Error>?
}

// MARK: - Implementation
struct MovieCreditsUseCaseImpl: MovieCreditsUseCase {
    private let service: MovieCreditsService

    init(service: MovieCreditsService) {
        self.service = service
    }

    func fetchMovieCredits(movieId: Int) -> AnyPublisher<MovieCredits?, any Error>? {
        guard let movieCreditsPublisher = getMovieCredits(api: .getMovieCredits(movieId: movieId)) else { return nil }
        return movieCreditsPublisher.eraseToAnyPublisher()
    }
}


extension MovieCreditsUseCaseImpl {
    func getMovieCredits(api: MovieCreditsApi) -> AnyPublisher<MovieCredits?, any Error>? {
        service.getMovieCredits(api: api)
    }
}
