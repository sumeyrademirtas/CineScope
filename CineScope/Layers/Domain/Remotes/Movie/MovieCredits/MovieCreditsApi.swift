//
//  MovieCreditsApi.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/21/25.
//

import Foundation
import Moya

enum MovieCreditsApi {
    case getMovieCredits(movieId: Int)
}

extension MovieCreditsApi: TargetType {
    
    private var constants: ApiConstants {
        return ApiConstants()
    }
    
    var baseURL: URL {
        return URL(string: constants.apiHost)!
    }
    
    var path: String {
        switch self {
        case .getMovieCredits(let movieId):
            return "/movie/\(movieId)/credits"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Moya.Task {
        switch self {
        case .getMovieCredits:
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

}
