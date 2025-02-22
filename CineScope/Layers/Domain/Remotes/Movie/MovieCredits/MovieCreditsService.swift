//
//  MovieCreditsService.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/21/25.
//

import Combine
import Foundation
import Moya

protocol MovieCreditsService {
    func getMovieCredits(api: MovieCreditsApi) -> AnyPublisher<MovieCredits?, Error>?
}

struct MovieCreditsServiceImpl: MovieCreditsService {
    let provider = BaseMoyaProvider<MovieCreditsApi>(plugins: [NetworkLoggerPlugin(configuration:
        .init(
            formatter: .init(responseData: JSONResponseDataFormatter),
            logOptions: .verbose
        ))]
    )
}

extension MovieCreditsServiceImpl {
    func getMovieCredits(api: MovieCreditsApi) -> AnyPublisher<MovieCredits?, any Error>? {
        return Future { promise in
            provider.request(api) { result in
                switch result {
                case .success(let response):
                    print("Response data count: \(response.data.count)")
                    if let jsonString = String(data: response.data, encoding: .utf8) {
                        print("Raw API JSON: \(jsonString)")
                    }
                    do {
                        // JSON verisini decode et ve unwrap yap
                        let decodedResponse = try JSONDecoder().decode(MovieCredits.self, from: response.data)
                        print("API returned \(decodedResponse.cast.count) cast members")
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
