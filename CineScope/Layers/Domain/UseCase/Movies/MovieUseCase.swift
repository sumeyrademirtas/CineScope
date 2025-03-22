//
//  MovieUseCase.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 1/30/25.
//

import Combine
import Foundation

// MARK: - Protocol Definition

protocol MovieUseCase {
    func fetchAllMovies() -> AnyPublisher<(MovieResponse?, MovieResponse?, MovieResponse?, MovieResponse?, MovieResponse?), Error>?
}

struct MovieUseCaseImpl: MovieUseCase {
    private let service: MovieService

    init(service: MovieService) {
        self.service = service
    }

    func fetchAllMovies() -> AnyPublisher<(MovieResponse?, MovieResponse?, MovieResponse?, MovieResponse?, MovieResponse?), Error>? {
        if let trendingPublisher = getTrendingMovies(api: .getTrendingMovies(page: 1)),
           let popularPublisher = getPopularMovies(api: .getPopularMovies(page: 1)),
           let upcomingPublisher = getUpcomingMovies(api: .getUpcomingMovies(page: 1)),
           let nowPlayingPublisher = getNowPlayingMovies(api: .getNowPlayingMovies(page: 1)),
           let topRatedPublisher = getTopRatedMovies(api: .getTopRatedMovies(page: 1))
        {
            return Publishers.Zip(
                Publishers.Zip4(trendingPublisher, popularPublisher, upcomingPublisher, nowPlayingPublisher),
                topRatedPublisher
            )
            .map { tuple, topRated in
                let (trending, popular, upcoming, nowPlaying) = tuple
                return (trending, popular, upcoming, nowPlaying, topRated)
            }
            .eraseToAnyPublisher()
        }
        return nil
    }
}

extension MovieUseCaseImpl {
    func getTrendingMovies(api: MovieApi) -> AnyPublisher<MovieResponse?, any Error>? {
        service.getTrendingMovies(api: api)
    }

    func getPopularMovies(api: MovieApi) -> AnyPublisher<MovieResponse?, any Error>? {
        service.getPopularMovies(api: api)
    }

    func getUpcomingMovies(api: MovieApi) -> AnyPublisher<MovieResponse?, any Error>? {
        service.getUpcomingMovies(api: api)
    }

    func getNowPlayingMovies(api: MovieApi) -> AnyPublisher<MovieResponse?, any Error>? {
        service.getNowPlayingMovies(api: api)
    }

    func getTopRatedMovies(api: MovieApi) -> AnyPublisher<MovieResponse?, any Error>? {
        service.getTopRatedMovies(api: api)
    }
}
