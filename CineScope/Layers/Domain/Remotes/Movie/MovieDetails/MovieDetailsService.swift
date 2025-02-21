//
//  MovieDetailsService.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/15/25.
//

import Combine
import Foundation
import Moya

protocol MovieDetailsService {
    func getMovieDetails(api: MovieDetailsApi) -> AnyPublisher<MovieDetails?, Error>?
}

struct MovieDetailsServiceImpl: MovieDetailsService {
    let provider = BaseMoyaProvider<MovieDetailsApi>(plugins: [NetworkLoggerPlugin(configuration:
        .init(
            formatter: .init(responseData: JSONResponseDataFormatter),
            logOptions: .verbose
        ))]
    )
}

extension MovieDetailsServiceImpl {
    func getMovieDetails(api: MovieDetailsApi) -> AnyPublisher<MovieDetails?, any Error>? {
        return Future { promise in
            provider.request(api) { result in // Burada MovieApi enum inin path ozelligine gore istek yapiyor.
                switch result {
                case .success(let response):
                    do {
                        // JSON verisini decode et ve unwrap yap
                        let decodedResponse = try JSONDecoder().decode(MovieDetails.self, from: response.data)
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
