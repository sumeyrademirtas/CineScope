//
//  SearchService.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/11/25.
//

import Combine
import Foundation
import Moya

protocol SearchMovieService { //FIXME: Movie ve Tv Servicelerini birlestirsem mi
    func getSearchMovieResults(api: SearchMovieApi) -> AnyPublisher<SearchMovieResponse?, Error>?
}

struct SearchMovieServiceImpl: SearchMovieService {
    let provider = BaseMoyaProvider<SearchMovieApi>(plugins: [NetworkLoggerPlugin(configuration:
        .init(
            formatter: .init(responseData: JSONResponseDataFormatter),
            logOptions: .verbose
        ))]
    )
}

extension SearchMovieServiceImpl {
    func getSearchMovieResults(api: SearchMovieApi) -> AnyPublisher<SearchMovieResponse?, any Error>? {
        return Future { promise in
            provider.request(api) { result in // Burada MovieApi enum inin path ozelligine gore istek yapiyor.
                switch result {
                case .success(let response):
                    do {
                        // JSON verisini decode et ve unwrap yap
                        let decodedResponse = try JSONDecoder().decode(SearchMovieResponse.self, from: response.data)
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
