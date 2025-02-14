//
//  SearchApi.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/11/25.
//

import Foundation
import Moya

enum SearchMovieApi {
    case getSearchMovieResults(page: Int, query: String) //FIXME: bunu simdilik enum olarak birakiyorum. belki ilerleyen zamanlarda searchmovie ve searchtv yi birlestiririm. Mahsuna bir sorcam
}

extension SearchMovieApi: TargetType {
    private var constants: ApiConstants {
        return ApiConstants()
    }
    
    var baseURL: URL {
        return URL(string: constants.apiHost)!
    }
    
    var path: String {
        return "/search/movie"
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Moya.Task {
        switch self {
        case .getSearchMovieResults(page: let page, query: let query):
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
