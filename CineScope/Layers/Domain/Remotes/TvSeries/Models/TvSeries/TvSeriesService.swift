//
//  TvSeriesService.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/7/25.
//

import Combine
import Foundation
import Moya

protocol TvSeriesService {
    func getTrendingTvSeries(api: TvSeriesApi) -> AnyPublisher<TvSeriesResponse?, Error>?
    func getAiringToday(api: TvSeriesApi) -> AnyPublisher<TvSeriesResponse?, Error>?
    func getOnTheAirTvSeries(api: TvSeriesApi) -> AnyPublisher<TvSeriesResponse?, Error>?
    func getPopularTvSeries(api: TvSeriesApi) -> AnyPublisher<TvSeriesResponse?, Error>?
    func getTopRatedTvSeries(api: TvSeriesApi) -> AnyPublisher<TvSeriesResponse?, Error>?
}

struct TvSeriesServiceImpl: TvSeriesService {
    // BaseMoyaProvider kullanilarak TvSeriesApi istekleri yonetiliyor.
    // NetworkLoggerPlugin ile HTTP istek ve yanitlari loglaniyor(console)
    // formatter ile JSON yanitlari okunabilir hale geliyor.
    // logOptions: .verbose istek ve yanitlari ayrintili olarak logluyor.
    let provider = MoyaProvider<TvSeriesApi>(
        plugins: [NetworkLoggerPlugin(configuration: .init(formatter: .init(responseData: JSONResponseDataFormatter), logOptions: .verbose))]
    )
}

extension TvSeriesServiceImpl {
    func getTrendingTvSeries(api: TvSeriesApi) -> AnyPublisher<TvSeriesResponse?, any Error>? {
        return Future { promise in
            provider.request(api) { result in // Burada TvSeriesApi enum inin path ozelligine gore istek yapiyor.
                switch result {
                case .success(let response):
                    do {
                        // JSON verisini decode et ve unwrap yap
                        let decodedResponse = try JSONDecoder().decode(TvSeriesResponse.self, from: response.data)
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

    func getAiringToday(api: TvSeriesApi) -> AnyPublisher<TvSeriesResponse?, any Error>? {
        return Future { promise in
            provider.request(api) { result in // Burada TvSeriesApi enum inin path ozelligine gore istek yapiyor.
                switch result {
                case .success(let response):
                    do {
                        // JSON verisini decode et ve unwrap yap
                        let decodedResponse = try JSONDecoder().decode(TvSeriesResponse.self, from: response.data)
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

    func getOnTheAirTvSeries(api: TvSeriesApi) -> AnyPublisher<TvSeriesResponse?, any Error>? {
        return Future { promise in
            provider.request(api) { result in
                switch result {
                case .success(let response):
                    do {
                        let decodedResponse = try JSONDecoder().decode(TvSeriesResponse.self, from: response.data)
                        promise(.success(decodedResponse))
                    } catch {
                        promise(.failure(error))
                    }
                case .failure(let moyaError):
                    switch moyaError {
                    case .underlying(let error, _):
                        promise(.failure(error))
                    default:
                        promise(.failure(moyaError))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func getPopularTvSeries(api: TvSeriesApi) -> AnyPublisher<TvSeriesResponse?, any Error>? {
        return Future { promise in
            provider.request(api) { result in
                switch result {
                case .success(let response):
                    do {
                        let decodedResponse = try JSONDecoder().decode(TvSeriesResponse.self, from: response.data)
                        promise(.success(decodedResponse))
                    } catch {
                        promise(.failure(error))
                    }
                case .failure(let moyaError):
                    switch moyaError {
                    case .underlying(let error, _):
                        promise(.failure(error))
                    default:
                        promise(.failure(moyaError))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func getTopRatedTvSeries(api: TvSeriesApi) -> AnyPublisher<TvSeriesResponse?, any Error>? {
        return Future { promise in
            provider.request(api) { result in
                switch result {
                case .success(let response):
                    do {
                        let decodedResponse = try JSONDecoder().decode(TvSeriesResponse.self, from: response.data)
                        promise(.success(decodedResponse))
                    } catch {
                        promise(.failure(error))
                    }
                case .failure(let moyaError):
                    switch moyaError {
                    case .underlying(let error, _):
                        promise(.failure(error))
                    default:
                        promise(.failure(moyaError))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
