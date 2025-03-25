//
//  GenreMovieService.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 3/25/25.
//

import Foundation
import Combine
import Moya

// MARK: - Protocol Definition
protocol GenreMovieService {
    func getMovieGenres(api: GenreMovieApi) -> AnyPublisher<GenreMovieResponse?, Error>?
}

// MARK: - Implementation
struct GenreMovieServiceImpl: GenreMovieService {
    let provider = BaseMoyaProvider<GenreMovieApi>(
        plugins: [NetworkLoggerPlugin(configuration:
            .init(
                formatter: .init(responseData: JSONResponseDataFormatter),
                logOptions: .verbose
            ))]
    )
}

// MARK: - Extension
extension GenreMovieServiceImpl {
    func getMovieGenres(api: GenreMovieApi) -> AnyPublisher<GenreMovieResponse?, any Error>? {
        return Future { promise in
            provider.request(api) { result in
                switch result {
                case .success(let response):
                    print("Response data count: \(response.data.count)")
                    if let jsonString = String(data: response.data, encoding: .utf8) {
                        print("Raw API JSON: \(jsonString)")
                    }
                    do {
                        let decodedResponse = try JSONDecoder().decode(GenreMovieResponse.self, from: response.data)
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
