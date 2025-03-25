//
//  DiscoverTvApi.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 3/25/25.
//

import Foundation
import Moya

enum DiscoverTvApi {
    case discoverTv(page: Int, genreId: Int?)
}

extension DiscoverTvApi: TargetType {

    private var constants: ApiConstants {
        return ApiConstants()
    }

    var baseURL: URL {
        return URL(string: constants.apiHost)!
    }

    var path: String {
        return "/discover/tv"
    }

    var method: Moya.Method {
        return .get
    }

    var task: Moya.Task {
        switch self {
        case .discoverTv(let page, let genreId):
            var params: [String: Any] = [
                "include_adult": false,
                "include_null_first_air_dates": false,
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
