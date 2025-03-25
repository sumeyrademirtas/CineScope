//
//  DiscoverMovieApi.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 3/25/25.
//

import Foundation
import Moya

enum DiscoverMovieApi {
    case discoverMovies(page: Int, genreId: Int?)
}

extension DiscoverMovieApi: TargetType {

    private var constants: ApiConstants {
        return ApiConstants()
    }

    var baseURL: URL {
        return URL(string: constants.apiHost)!
    }

    var path: String {
        return "/discover/movie"
    }

    var method: Moya.Method {
        return .get
    }

    var task: Moya.Task {
        switch self {
        case .discoverMovies(let page, let genreId):
            var params: [String: Any] = [
                "include_adult": false,
                "include_video": false,
                "language": "en-US",
                "page": page,
                "sort_by": "popularity.desc"
            ]

            if let genreId = genreId {
                params["with_genres"] = genreId
            }

            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        }
    }

    var headers: [String: String]? {
        return [
            "Content-Type": "application/json"
        ]
    }
}
