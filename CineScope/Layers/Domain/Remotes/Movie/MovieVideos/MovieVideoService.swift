//
//  MovieVideoService.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/18/25.
//

import Combine
import Foundation
import Moya

protocol MovieVideosService {
    func getMovieVideo(api: MovieVideosApi) -> AnyPublisher<MovieVideosResponse?, Error>?
}

struct MovieVideosServiceImpl: MovieVideosService {
    let provider = BaseMoyaProvider<MovieVideosApi>(
        plugins: [NetworkLoggerPlugin(configuration: .init(
            formatter: .init(responseData: JSONResponseDataFormatter),
            logOptions: .verbose
        ))]
    )
}

extension MovieVideosServiceImpl {
    func getMovieVideo(api: MovieVideosApi) -> AnyPublisher<MovieVideosResponse?, any Error>? {
        return Future { promise in
            provider.request(api) { result in
                switch result {
                case .success(let response):
                    do {
                        // JSON verisini decode et ve unwrap yap
                        let decodedResponse = try JSONDecoder().decode(MovieVideosResponse.self, from: response.data)
                        promise(.success(decodedResponse)) // Başarıyla promise gönder
                    } catch {
                        promise(.failure(error)) // JSON decode hatası
                    }
                case .failure(let moyaError):
                    switch moyaError {
                    case .underlying(let error, _):
                        promise(.failure(error)) // Ağ hatası
                    default:
                        promise(.failure(moyaError)) // Diğer Moya hataları
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
