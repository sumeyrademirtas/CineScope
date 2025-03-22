//
//  TmdbService.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 1/29/25.
//

import Combine
import Foundation
import Moya

protocol MovieService {
    func getTrendingMovies(api: MovieApi) -> AnyPublisher<MovieResponse?, Error>?
    func getPopularMovies(api: MovieApi) -> AnyPublisher<MovieResponse?, Error>?
    func getUpcomingMovies(api: MovieApi) -> AnyPublisher<MovieResponse?, Error>?
    func getNowPlayingMovies(api: MovieApi) -> AnyPublisher<MovieResponse?, Error>?
    func getTopRatedMovies(api: MovieApi) -> AnyPublisher<MovieResponse?, Error>?
}

struct MovieServiceImpl: MovieService {
    // BaseMoyaProvider kullanilarak MovieApi istekleri yonetiliyor.
    // NetworkLoggerPlugin ile HTTP istek ve yanitlari loglaniyor(console)
    // formatter ile JSON yanitlari okunabilir hale geliyor.
    // logOptions: .verbose istek ve yanitlari ayrintili olarak logluyor. verbose yerine baska secenekler de var.
    let provider = BaseMoyaProvider<MovieApi>(
        plugins: [NetworkLoggerPlugin(configuration: .init(
            formatter: .init(responseData: JSONResponseDataFormatter),
            logOptions: .verbose
        ))]
    )
}

extension MovieServiceImpl {
    
    func getTrendingMovies(api: MovieApi) -> AnyPublisher<MovieResponse?, any Error>? {
        return Future { promise in
            provider.request(api) { result in // Burada MovieApi enum inin path ozelligine gore istek yapiyor.
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
    
    
    func getPopularMovies(api: MovieApi) -> AnyPublisher<MovieResponse?, any Error>? {
        return Future { promise in
            provider.request(api) { result in // Burada MovieApi enum inin path ozelligine gore istek yapiyor.
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

    func getUpcomingMovies(api: MovieApi) -> AnyPublisher<MovieResponse?, any Error>? {
        return Future { promise in
            provider.request(api) { result in
                switch result {
                case .success(let response):
                    do {
                        let decodedResponse = try JSONDecoder().decode(MovieResponse.self, from: response.data)
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

    func getNowPlayingMovies(api: MovieApi) -> AnyPublisher<MovieResponse?, any Error>? {
        return Future { promise in
            provider.request(api) { result in
                switch result {
                case .success(let response):
                    do {
                        let decodedResponse = try JSONDecoder().decode(MovieResponse.self, from: response.data)
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

    func getTopRatedMovies(api: MovieApi) -> AnyPublisher<MovieResponse?, any Error>? {
        return Future { promise in
            provider.request(api) { result in
                switch result {
                case .success(let response):
                    do {
                        let decodedResponse = try JSONDecoder().decode(MovieResponse.self, from: response.data)
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
