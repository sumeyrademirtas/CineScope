//
//  SearchTvSeriesApi.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 3/17/25.
//

import Foundation
import Moya

enum SearchTvSeriesApi {
    case getSearchTvSeriesResults(page: Int, query: String)
}

extension SearchTvSeriesApi: TargetType {
    private var constants: ApiConstants {
        return ApiConstants()
    }
    
    var baseURL: URL {
        return URL(string: constants.apiHost)!
    }
    
    var path: String {
        return "/search/tv"
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Moya.Task {
        switch self {
        case .getSearchTvSeriesResults(page: let page, query: let query):
            var params: [String: Any] = [:]
            params["api_key"] = constants.apiKey
            params["page"] = page
            params["language"] = "en-US"
            params["query"] = query
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        }
    }
    
    var headers: [String: String]? {
        return [
            "Content-Type": "application/json"
        ]
    }
}

