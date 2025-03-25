//
//  DiscoverMovieUseCase.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 3/25/25.
//

import Foundation
import Combine

// MARK: - Protocol Definition
protocol DiscoverMovieUseCase {
    func fetchDiscoveredMovies(page: Int, genreId: Int?) -> AnyPublisher<DiscoverMovieResponse?, Error>?
}

// MARK: - Implementation
struct DiscoverMovieUseCaseImpl: DiscoverMovieUseCase {
    private let service: DiscoverMovieService

    init(service: DiscoverMovieService) {
        self.service = service
    }

    func fetchDiscoveredMovies(page: Int, genreId: Int?) -> AnyPublisher<DiscoverMovieResponse?, Error>? {
        guard let publisher = getDiscoveredMovies(api: .discoverMovies(page: page, genreId: genreId)) else {
            return nil
        }
        return publisher.eraseToAnyPublisher()
    }
}

// MARK: - Private API Helper
private extension DiscoverMovieUseCaseImpl {
    func getDiscoveredMovies(api: DiscoverMovieApi) -> AnyPublisher<DiscoverMovieResponse?, Error>? {
        service.getDiscoveredMovies(api: api)
    }
}
