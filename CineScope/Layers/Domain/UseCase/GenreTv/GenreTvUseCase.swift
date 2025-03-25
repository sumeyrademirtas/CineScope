//
//  GenreTvUseCase.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 3/25/25.
//

import Foundation
import Combine

// MARK: - Protocol Definition
protocol GenreTvUseCase {
    func fetchTvGenres() -> AnyPublisher<GenreTvResponse?, Error>?
}

// MARK: - Implementation
struct GenreTvUseCaseImpl: GenreTvUseCase {
    private let service: GenreTvService

    init(service: GenreTvService) {
        self.service = service
    }

    func fetchTvGenres() -> AnyPublisher<GenreTvResponse?, Error>? {
        guard let genrePublisher = getTvGenres(api: .getTvGenres) else {
            return nil
        }
        return genrePublisher.eraseToAnyPublisher()
    }
}

// MARK: - Private API Helper
private extension GenreTvUseCaseImpl {
    func getTvGenres(api: GenreTvApi) -> AnyPublisher<GenreTvResponse?, Error>? {
        service.getTvGenres(api: api)
    }
}
