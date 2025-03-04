//
//  TvSeriesVideoUseCase.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 3/4/25.
//

import Foundation
import Combine

// MARK: - Protocol Definition
protocol TvSeriesVideoUseCase {
    func fetchTvSeriesVideos(tvSeriesId: Int) -> AnyPublisher<TvSeriesVideo?, Error>?
}

struct TvSeriesVideoUseCaseImpl: TvSeriesVideoUseCase {

    
    private let service: TvSeriesVideoService
    
    init(service: TvSeriesVideoService) {
        self.service = service
    }
    
    func fetchTvSeriesVideos(tvSeriesId: Int) -> AnyPublisher<TvSeriesVideo?, any Error>? {
        guard let tvSeriesVideosPublisher = getTvSeriesVideos(api: .getTvSeriesVideos(tvSeriesId: tvSeriesId)) else { return nil }
        return tvSeriesVideosPublisher.map { response in response?.bestTrailer }.eraseToAnyPublisher()
    }
}


extension TvSeriesVideoUseCaseImpl {
    func getTvSeriesVideos(api: TvSeriesVideoApi) -> AnyPublisher<TvSeriesVideosResponse?, Error>? {
        service.getTvSeriesVideos(api: api)
    }
}
