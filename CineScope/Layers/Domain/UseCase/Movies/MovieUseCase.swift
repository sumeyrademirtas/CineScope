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
    func fetchAllMovies() -> AnyPublisher<(MovieResponse?, MovieResponse?, MovieResponse?, MovieResponse?), Error>?
}

struct MovieUseCaseImpl: MovieUseCase {
    private let service: MovieService

    /// Dependency Injection
    init(service: MovieService) {
        self.service = service
    }

    // sira [.popular, .upcoming, .nowPlaying, .topRated]
    func fetchAllMovies() -> AnyPublisher<(MovieResponse?, MovieResponse?, MovieResponse?, MovieResponse?), Error>? {
        if //cagrilarin hepsi basarili olursa kod calismaya devam eder, herhangi biri nil donerse fetchAllMovies nil doner.
            let popularPublisher = getPopularMovies(api: .getPopularMovies(page: 1)),
            let upcomingPublisher = getUpcomingMovies(api: .getUpcomingMovies(page: 1)),
            let nowPlayingPublisher = getNowPlayingMovies(api: .getNowPlayingMovies(page: 1)),
            let topRatedPublisher = getTopRatedMovies(api: .getTopRatedMovies(page: 1))
        {
            // Publishers.Zip4 tum istekler tamamlaninca sonuclari tek bir tuple icinde dondurur.
            return Publishers.Zip4(popularPublisher, upcomingPublisher, nowPlayingPublisher, topRatedPublisher)
            // Eğer map kullanmazsak, Zip4’ün sonucu doğrudan tuple olarak dönmez.
                .map { popular, upcoming, nowPlaying, topRated in
                    (popular, upcoming, nowPlaying, topRated)
                }
                .eraseToAnyPublisher()
        }
        return nil
    }
}

extension MovieUseCaseImpl {
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
