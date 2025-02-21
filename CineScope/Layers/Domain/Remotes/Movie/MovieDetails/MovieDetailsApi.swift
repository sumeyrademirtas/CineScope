//
//  MovieDetailsApi.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/15/25.
//

import Foundation
import Moya

enum MovieDetailsApi {
    case getMovieDetails(movieId: Int)
}

extension MovieDetailsApi: TargetType {
    var baseURL: URL {
        return URL(string: constants.apiHost)!
    }
    
    var path: String {
        switch self {
        case .getMovieDetails(let movieId):
            return "/movie/\(movieId)"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Moya.Task {
        switch self {
        case .getMovieDetails(movieId: let movieId):
            var params: [String: Any] = [:]
            params["api_key"] = constants.apiKey
            params["language"] = "en-US"
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return [
            "Content-Type": "application/json"
        ]
    }
    
    private var constants: ApiConstants {
        return ApiConstants()
    }
}
