//
//  GenreTvApi.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 3/25/25.
//

import Foundation
import Moya

enum GenreTvApi {
    case getTvGenres
}

extension GenreTvApi: TargetType {
    
    private var constants: ApiConstants {
        return ApiConstants()
    }
    
    var baseURL: URL {
        return URL(string: constants.apiHost)!
    }
    
    var path: String {
        switch self {
        case .getTvGenres:
            return "/genre/tv/list"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Moya.Task {
        var params: [String: Any] = [:]
        params["api_key"] = constants.apiKey
        params["language"] = "en-US"
        return .requestParameters(parameters: params, encoding: URLEncoding.default)
    }
    
    var headers: [String: String]? {
        return [
            "Content-Type": "application/json"
        ]
    }
}
