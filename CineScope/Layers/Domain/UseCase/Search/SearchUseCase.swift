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
    func fetchAllSearchResults(query: String) -> AnyPublisher<SearchMovieResponse?, Error>? // FIXME: Ilerleyen zamanlarda Tv icin de response ekleyebilirim aslinda buraya.
}

struct SearchUseCaseImpl: SearchUseCase {
    private let service: SearchMovieService

    init(service: SearchMovieService) {
        self.service = service
    }

    func fetchAllSearchResults(query: String) -> AnyPublisher<SearchMovieResponse?, Error>? {
        // Service'den arama sonuçlarını döndüren publisher'ı alıyoruz.
        guard let moviePublisher = getSearchMovieResults(api: .getSearchMovieResults(page: 1, query: query)) else {
            return nil
        }
        // Publisher'ı doğrudan, tipini soyutlayarak döndürüyoruz.
        return moviePublisher.eraseToAnyPublisher()
    }

}

extension SearchUseCaseImpl {
    func getSearchMovieResults(api: SearchMovieApi) -> AnyPublisher<SearchMovieResponse?, any Error>? {
        service.getSearchMovieResults(api: api)
    }
}





// FIXME: alttaki simdilik boyle dursun. Tv Service ekleyecegimiz zaman ziplicez.
//    func fetchAllSearchResults() -> AnyPublisher<(SearchMovieResponse?), Error>? {
//        if
//            let moviePublisher = getSearchMovieResults(api: .getSearchMovieResults(page: 1))
//        {
//            return Publishers.Zip4(moviePublisher)
//                .map { movie in (movie)
//                }
//                .eraseToAnyPublisher()
//        }
//        return nil
//    }
