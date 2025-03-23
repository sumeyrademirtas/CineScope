//
//  TvSeriesUseCase.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/10/25.
//

import Combine
import Foundation

// MARK: - Protocol Definition

protocol TvSeriesUseCase {
    func fetchAllTvSeries() -> AnyPublisher<(TvSeriesResponse?, TvSeriesResponse?, TvSeriesResponse?, TvSeriesResponse?, TvSeriesResponse?), Error>?
}

struct TvSeriesUseCaseImpl: TvSeriesUseCase {
    private let service: TvSeriesService
    
    /// Dependency Injection
    init(service: TvSeriesService) {
        self.service = service
    }
    
    func fetchAllTvSeries() -> AnyPublisher<(TvSeriesResponse?, TvSeriesResponse?, TvSeriesResponse?, TvSeriesResponse?, TvSeriesResponse?), Error>? {
        if
            let trendingPublisher = getTrendingTvSeries(api: .getTrendingTvSeries(page: 1)),
            let airingTodayPublisher = getAiringTodayTvSeries(api: .getAiringTodayTvSeries(page: 1)),
            let onTheAirPublisher = getOnTheAirTvSeries(api: .getOnTheAirTvSeries(page: 1)),
            let popularPublisher = getPopularTvSeries(api: .getPopularTvSeries(page: 1)),
            let topRatedPublisher = getTopRatedTvSeries(api: .getTopRatedTvSeries(page: 1))
        {
            return Publishers.Zip(
                Publishers.Zip4(trendingPublisher, airingTodayPublisher, onTheAirPublisher, popularPublisher),
                topRatedPublisher
            )
            .map { tuple, topRated in
                let (trending, airingToday, onTheAir, popular) = tuple
                return (trending, airingToday, onTheAir, popular, topRated)
            }
            .eraseToAnyPublisher()
        }
        return nil
    }
}

extension TvSeriesUseCaseImpl {
    func getTrendingTvSeries(api: TvSeriesApi) -> AnyPublisher<TvSeriesResponse?, any Error>? {
        service.getTrendingTvSeries(api: api)
    }
    
    func getAiringTodayTvSeries(api: TvSeriesApi) -> AnyPublisher<TvSeriesResponse?, any Error>? {
        service.getAiringToday(api: api)
    }
    
    func getOnTheAirTvSeries(api: TvSeriesApi) -> AnyPublisher<TvSeriesResponse?, any Error>? {
        service.getOnTheAirTvSeries(api: api)
    }
    
    func getPopularTvSeries(api: TvSeriesApi) -> AnyPublisher<TvSeriesResponse?, any Error>? {
        service.getPopularTvSeries(api: api)
    }
    
    func getTopRatedTvSeries(api: TvSeriesApi) -> AnyPublisher<TvSeriesResponse?, any Error>? {
        service.getTopRatedTvSeries(api: api)
    }
}
