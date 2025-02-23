//
//  MovieVideoUseCase.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/23/25.
//

import Foundation
import Combine

// MARK: - Protocol Definition
protocol MovieVideoUseCase {
    func fetchMovieVideos(movieId: Int) -> AnyPublisher<MovieVideo?, Error>?
}

struct MovieVideoUseCaseImpl: MovieVideoUseCase {
    
    private let service: MovieVideosService
    
    init(service: MovieVideosService) {
        self.service = service
    }
    
    func fetchMovieVideos(movieId: Int) -> AnyPublisher<MovieVideo?, any Error>? {
        guard let movieVideosPublisher = getMovieVideos(api: .getMovieVideos(movieId: movieId)) else { return nil }
        return movieVideosPublisher.map { response in response?.bestTrailer }.eraseToAnyPublisher()
    }
}


extension MovieVideoUseCaseImpl {
    func getMovieVideos(api: MovieVideosApi) -> AnyPublisher<MovieVideosResponse?, Error>? {
        service.getMovieVideo(api: api)
    }
}

