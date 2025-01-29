//
//  TmdbService.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 1/29/25.
//

import Combine
import Foundation
import Moya

protocol TmdbService {
    func getPopularMovies(api: TmdbApi) -> AnyPublisher<MovieResponse?, Error>?
    func getUpcomingMovies(api: TmdbApi) -> AnyPublisher<MovieResponse?, Error>?
    func getNowPlayingMovies(api: TmdbApi) -> AnyPublisher<MovieResponse?, Error>?
    func getTopRatedMovies(api: TmdbApi) -> AnyPublisher<MovieResponse?, Error>?
}

struct TmdbServiceImpl: TmdbService {
    // BaseMoyaProvider kullanilarak Tmdb Api istekleri yonetiliyor.
    // NetworkLoggerPlugin ile HTTP istek ve yanitlari loglaniyor(console)
    // formatter ile JSON yanitlari okunabilir hale geliyor.
    // logOptions: .verbose istek ve yanitlari ayrintili olarak logluyor. verbose yerine baska secenekler de var.
    let provider = BaseMoyaProvider<TmdbApi>(
        plugins: [NetworkLoggerPlugin(configuration: .init(
            formatter: .init(responseData: JSONResponseDataFormatter),
            logOptions: .verbose
        ))]
    )
}

extension TmdbServiceImpl {
    func getPopularMovies(api: TmdbApi) -> AnyPublisher<MovieResponse?, any Error>? {
        return Future { promise in
            provider.request(api) { result in // Burada TmdbApi enum inin path ozelligine gore istek yapiyor.
                switch result {
                case .success(let response):
                    do {
                        // JSON verisini decode et ve unwrap yap
                        let decodedResponse = try JSONDecoder().decode(MovieResponse.self, from: response.data)
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

    func getUpcomingMovies(api: TmdbApi) -> AnyPublisher<MovieResponse?, any Error>? {
        return Future { promise in
            provider.request(api) { result in
                switch result {
                case .success(let response):
                    do {
                        // JSON verisini decode et ve unwrap yap
                        let decodedResponse = try JSONDecoder().decode(MovieResponse.self, from: response.data)
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

    func getNowPlayingMovies(api: TmdbApi) -> AnyPublisher<MovieResponse?, any Error>? {
        return Future { promise in
            provider.request(api) { result in
                switch result {
                case .success(let response):
                    do {
                        // JSON verisini decode et ve unwrap yap
                        let decodedResponse = try JSONDecoder().decode(MovieResponse.self, from: response.data)
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

    func getTopRatedMovies(api: TmdbApi) -> AnyPublisher<MovieResponse?, any Error>? {
        return Future { promise in
            provider.request(api) { result in
                switch result {
                case .success(let response):
                    do {
                        // JSON verisini decode et ve unwrap yap
                        let decodedResponse = try JSONDecoder().decode(MovieResponse.self, from: response.data)
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
