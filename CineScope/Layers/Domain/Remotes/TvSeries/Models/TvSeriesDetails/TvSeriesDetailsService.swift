//
//  TvSeriesDetailsService.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 3/3/25.
//

import Foundation
import Combine
import Moya

protocol TvSeriesDetailsService {
    func getTvSeriesDetails(api: TvSeriesDetailsApi) -> AnyPublisher<TvSeriesDetails?, Error>?
}

struct TvSeriesDetailsServiceImpl: TvSeriesDetailsService {
    
    let provider = BaseMoyaProvider<TvSeriesDetailsApi>(plugins: [NetworkLoggerPlugin(configuration:
        .init(
            formatter: .init(responseData: JSONResponseDataFormatter),
            logOptions: .verbose
        ))]
    )
}

extension TvSeriesDetailsServiceImpl {
    func getTvSeriesDetails(api: TvSeriesDetailsApi) -> AnyPublisher<TvSeriesDetails?, any Error>? {
        return Future { promise in
            provider.request(api) { result in 
                switch result {
                case .success(let response):
                    do {
                        // JSON verisini decode et ve unwrap yap
                        let decodedResponse = try JSONDecoder().decode(TvSeriesDetails.self, from: response.data)
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
