//
//  TvSeriesUseCase.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/10/25.
//

import Foundation
import Combine

// MARK: - Protocol Definition
protocol TvSeriesUseCase {
    func fetchAllTvSeries() -> AnyPublisher<(TvSeriesResponse?, TvSeriesResponse?, TvSeriesResponse?, TvSeriesResponse?), Error>?
}

struct TvSeriesUseCaseImpl: TvSeriesUseCase {
    private let service: TvSeriesService
    
    ///Dependency Injection
    init(service: TvSeriesService) {
        self.service = service
    }
    
    // sira [.airingToday, .onTheAir, .popular, .topRated]
    func fetchAllTvSeries() -> AnyPublisher<(TvSeriesResponse?, TvSeriesResponse?, TvSeriesResponse?, TvSeriesResponse?), Error>? {
        if
            let airingTodayPublisher = getAiringTodayTvSeries(api: .getPopularTvSeries(page: 1)),
            let onTheAirPublisher = getOnTheAirTvSeries(api: .getOnTheAirTvSeries(page: 1)),
            let popularPublisher = getPopularTvSeries(api: .getPopularTvSeries(page: 1)),
            let topRatedPublisher = getTopRatedTvSeries(api: .getTopRatedTvSeries(page: 1))
        {
            return Publishers.Zip4(airingTodayPublisher, onTheAirPublisher, popularPublisher, topRatedPublisher)
                .map { airing, onTheAir, popular, topRated in (airing, onTheAir, popular, topRated)
                }
                .eraseToAnyPublisher()
        }
        return nil
            
    }
}


extension TvSeriesUseCaseImpl {
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
