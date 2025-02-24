//
//  PersonDetailsService.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/24/25.
//

import Foundation
import Combine
import Moya

protocol PersonDetailsService {
    func getPersonDetails(api: PersonDetailsApi) -> AnyPublisher<PersonDetails?, Error>?
}

struct PersonDetailsServiceImpl: PersonDetailsService {
    let provider = BaseMoyaProvider<PersonDetailsApi>(plugins: [NetworkLoggerPlugin(configuration:
        .init(
            formatter: .init(responseData: JSONResponseDataFormatter),
            logOptions: .verbose
        ))]
    )
}

extension PersonDetailsServiceImpl {
    func getPersonDetails(api: PersonDetailsApi) -> AnyPublisher<PersonDetails?, any Error>? {
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
                        let decodedResponse = try JSONDecoder().decode(PersonDetails.self, from: response.data)
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
