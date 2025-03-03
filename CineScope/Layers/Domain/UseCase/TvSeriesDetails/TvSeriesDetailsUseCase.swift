//
//  TvSeriesDetailsApi.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 3/3/25.
//

import Foundation
import Combine

// MARK: - Protocol Definition

protocol TvSeriesDetailsUseCase {
    func fetchTvSeriesDetails(tvSeriesId: Int) -> AnyPublisher<TvSeriesDetails?, Error>?
}

struct TvSeriesDetailsUseCaseImpl: TvSeriesDetailsUseCase {
    
    private let service: TvSeriesDetailsService
    
    init(service: TvSeriesDetailsService) {
        self.service = service
    }
    
    func fetchTvSeriesDetails(tvSeriesId: Int) -> AnyPublisher<TvSeriesDetails?, any Error>? {
        guard let tvSeriesDetailsPublisher = getTvSeriesDetails(api: .getTvSeriesDetails(tvSeriesId: tvSeriesId)) else { return nil }
        return tvSeriesDetailsPublisher.eraseToAnyPublisher()
    }
}


extension TvSeriesDetailsUseCaseImpl {
    func getTvSeriesDetails(api: TvSeriesDetailsApi) -> AnyPublisher<TvSeriesDetails?, any Error>? {
        service.getTvSeriesDetails(api: api)
    }
}
