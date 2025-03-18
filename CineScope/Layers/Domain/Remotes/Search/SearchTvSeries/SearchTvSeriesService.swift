//
//  SearchTvSeriesService.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 3/17/25.
//

import Foundation
import Combine
import Moya

protocol SearchTvSeriesService {
    func getSearchTvSeriesResults(api: SearchTvSeriesApi) -> AnyPublisher<SearchTvSeriesResponse?, Error>?
}

struct SearchTvSeriesServiceImpl: SearchTvSeriesService {
    let provider = BaseMoyaProvider<SearchTvSeriesApi>(plugins: [NetworkLoggerPlugin(configuration:
        .init(
            formatter: .init(responseData: JSONResponseDataFormatter),
            logOptions: .verbose
        ))]
    )
}

extension SearchTvSeriesServiceImpl {
    func getSearchTvSeriesResults(api: SearchTvSeriesApi) -> AnyPublisher<SearchTvSeriesResponse?, any Error>? {
        return Future { promise in
            provider.request(api) { result in
                switch result {
                case .success(let response):
                    do {
                        // JSON verisini decode et ve unwrap yap
                        let decodedResponse = try JSONDecoder().decode(SearchTvSeriesResponse.self, from: response.data)
                        promise(.success(decodedResponse)) // Başarıyla promise gönder
                    } catch {
                        promise(.failure(error)) // JSON decode hatası
                    }
                case .failure(let moyaError):
                    switch moyaError {
                    case .underlying(let error, _):
                        print("Underlying error: \(error)")
                        promise(.failure(error)) // Ağ hatası
                    default:
                        print("Moya error: \(moyaError)")
                        promise(.failure(moyaError)) // Diğer Moya hataları
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

