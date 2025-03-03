//
//  TvSeriesCredits.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 3/3/25.
//

import Foundation
import Combine

// MARK: - Protocol Definition
protocol TvSeriesCreditsUseCase {
    func fetchTvSeriesCredits(tvSeriesId: Int) -> AnyPublisher<TvSeriesCredits?, Error>?
}

// MARK: - Implementation
struct TvSeriesCreditsUseCaseImpl: TvSeriesCreditsUseCase {
    private let service: TvSeriesCreditsService

    init(service: TvSeriesCreditsService) {
        self.service = service
    }

    func fetchTvSeriesCredits(tvSeriesId: Int) -> AnyPublisher<TvSeriesCredits?, any Error>? {
        guard let tvSeriesCreditsPublisher = getTvSeriesCredits(api: .getTvSeriesCredits(tvSeriesId: tvSeriesId)) else { return nil }
        return tvSeriesCreditsPublisher.eraseToAnyPublisher()
    }
}


extension TvSeriesCreditsUseCaseImpl {
    func getTvSeriesCredits(api: TvSeriesCreditsApi) -> AnyPublisher<TvSeriesCredits?, any Error>? {
        service.getTvSeriesCredits(api: api)
    }
}
