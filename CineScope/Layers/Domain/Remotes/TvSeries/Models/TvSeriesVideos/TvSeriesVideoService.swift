//
//  TvSeriesVideoService.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 3/4/25.
//

import Foundation
import Combine
import Moya

protocol TvSeriesVideoService {
    func getTvSeriesVideos(api: TvSeriesVideoApi) -> AnyPublisher<TvSeriesVideosResponse?, Error>?
}


struct TvSeriesVideoServiceImpl: TvSeriesVideoService {
    
    let provider = BaseMoyaProvider<TvSeriesVideoApi>(
        plugins: [NetworkLoggerPlugin(configuration: .init(
            formatter: .init(responseData: JSONResponseDataFormatter),
            logOptions: .verbose
        ))]
    )
}


extension TvSeriesVideoServiceImpl {
    func getTvSeriesVideos(api: TvSeriesVideoApi) -> AnyPublisher<TvSeriesVideosResponse?, any Error>? {
        return Future { promise in
            provider.request(api) { result in
                switch result {
                case .success(let response):
                    do {
                        // JSON verisini decode et ve unwrap yap
                        let decodedResponse = try JSONDecoder().decode(TvSeriesVideosResponse.self, from: response.data)
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
