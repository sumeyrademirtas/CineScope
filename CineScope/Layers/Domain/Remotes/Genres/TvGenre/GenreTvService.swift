//
//  GenreTvService.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 3/25/25.
//

import Foundation
import Combine
import Moya

// MARK: - Protocol Definition
protocol GenreTvService {
    func getTvGenres(api: GenreTvApi) -> AnyPublisher<GenreTvResponse?, Error>?
}

// MARK: - Implementation
struct GenreTvServiceImpl: GenreTvService {
    let provider = BaseMoyaProvider<GenreTvApi>(
        plugins: [NetworkLoggerPlugin(configuration:
            .init(
                formatter: .init(responseData: JSONResponseDataFormatter),
                logOptions: .verbose
            ))]
    )
}

// MARK: - Extension
extension GenreTvServiceImpl {
    func getTvGenres(api: GenreTvApi) -> AnyPublisher<GenreTvResponse?, any Error>? {
        return Future { promise in
            provider.request(api) { result in
                switch result {
                case .success(let response):
                    print("Response data count: \(response.data.count)")
                    if let jsonString = String(data: response.data, encoding: .utf8) {
                        print("Raw API JSON: \(jsonString)")
                    }
                    do {
                        let decodedResponse = try JSONDecoder().decode(GenreTvResponse.self, from: response.data)
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
