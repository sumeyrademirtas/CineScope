//
//  DiscoverMovieService.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 3/25/25.
//

import Foundation
import Combine
import Moya

// MARK: - Protocol Definition
protocol DiscoverMovieService {
    func getDiscoveredMovies(api: DiscoverMovieApi) -> AnyPublisher<DiscoverMovieResponse?, Error>?
}

// MARK: - Implementation
struct DiscoverMovieServiceImpl: DiscoverMovieService {
    let provider = BaseMoyaProvider<DiscoverMovieApi>(
        plugins: [NetworkLoggerPlugin(configuration:
            .init(
                formatter: .init(responseData: JSONResponseDataFormatter),
                logOptions: .verbose
            ))]
    )
}

// MARK: - Extension
extension DiscoverMovieServiceImpl {
    func getDiscoveredMovies(api: DiscoverMovieApi) -> AnyPublisher<DiscoverMovieResponse?, any Error>? {
        return Future { promise in
            provider.request(api) { result in
                switch result {
                case .success(let response):
                    print("Response data count: \(response.data.count)")
                    if let jsonString = String(data: response.data, encoding: .utf8) {
                        print("Raw API JSON: \(jsonString)")
                    }
                    do {
                        let decodedResponse = try JSONDecoder().decode(DiscoverMovieResponse.self, from: response.data)
                        promise(.success(decodedResponse))
                    } catch {
                        print("Decoding error: \(error)")
                        promise(.failure(error))
                    }
                case .failure(let moyaError):
                    switch moyaError {
                    case .underlying(let error, _):
                        print("Underlying error: \(error)")
                        promise(.failure(error))
                    default:
                        print("Moya error: \(moyaError)")
                        promise(.failure(moyaError))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
