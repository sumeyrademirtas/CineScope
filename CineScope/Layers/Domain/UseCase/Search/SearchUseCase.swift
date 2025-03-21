//
//  SearchUseCase.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/11/25.
//

import Combine
import Foundation

// MARK: - Protocol Definition

protocol SearchUseCase {
    func fetchAllSearchResults(query: String) -> AnyPublisher<(SearchMovieResponse?, SearchTvSeriesResponse?), Error>?
}

struct SearchUseCaseImpl: SearchUseCase {
    private let movieService: SearchMovieService
    private let tvSeriesService: SearchTvSeriesService

    init(movieService: SearchMovieService, tvSeriesService: SearchTvSeriesService) {
        self.movieService = movieService
        self.tvSeriesService = tvSeriesService
    }

    func fetchAllSearchResults(query: String) -> AnyPublisher<(SearchMovieResponse?, SearchTvSeriesResponse?), Error>? {
        guard let moviePublisher = getSearchMovieResults(api: .getSearchMovieResults(page: 1, query: query)),
              let tvSeriesPublisher = getSearchTvSeriesResults(api: .getSearchTvSeriesResults(page: 1, query: query))
        else { return nil }
        
        // tvSeriesPublisher'dan hata alınırsa, nil döndüren bir publisher oluşturuyoruz.
        let safeTvSeriesPublisher = tvSeriesPublisher.catch { _ in
            Just(nil).setFailureType(to: Error.self)
        }
        
        return Publishers.Zip(moviePublisher, safeTvSeriesPublisher)
            .map { movieResponse, tvSeriesResponse in
                return (movieResponse, tvSeriesResponse)
            }
            .eraseToAnyPublisher()
    }
}

extension SearchUseCaseImpl {
    func getSearchMovieResults(api: SearchMovieApi) -> AnyPublisher<SearchMovieResponse?, any Error>? {
        movieService.getSearchMovieResults(api: api)
    }
    
    func getSearchTvSeriesResults(api: SearchTvSeriesApi) -> AnyPublisher<SearchTvSeriesResponse?, any Error>? {
        tvSeriesService.getSearchTvSeriesResults(api: api)
    }
}
