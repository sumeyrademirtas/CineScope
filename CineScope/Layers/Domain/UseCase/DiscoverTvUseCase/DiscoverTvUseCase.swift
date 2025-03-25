//
//  DiscoverTvUseCase.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 3/25/25.
//

import Foundation
import Combine

// MARK: - Protocol Definition
protocol DiscoverTvUseCase {
    func fetchDiscoveredTvShows(page: Int, genreId: Int?) -> AnyPublisher<DiscoverTvResponse?, Error>?
}

// MARK: - Implementation
struct DiscoverTvUseCaseImpl: DiscoverTvUseCase {
    private let service: DiscoverTvService

    init(service: DiscoverTvService) {
        self.service = service
    }

    func fetchDiscoveredTvShows(page: Int, genreId: Int?) -> AnyPublisher<DiscoverTvResponse?, Error>? {
        guard let publisher = getDiscoveredTvShows(api: .discoverTv(page: page, genreId: genreId)) else {
            return nil
        }
        return publisher.eraseToAnyPublisher()
    }
}

// MARK: - Private API Helper
private extension DiscoverTvUseCaseImpl {
    func getDiscoveredTvShows(api: DiscoverTvApi) -> AnyPublisher<DiscoverTvResponse?, Error>? {
        service.getDiscoveredTvShows(api: api)
    }
}
