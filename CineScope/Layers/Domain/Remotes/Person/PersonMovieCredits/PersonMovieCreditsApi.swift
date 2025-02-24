//
//  PersonMovieCreditsApi.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/24/25.
//

import Foundation
import Moya

enum PersonMovieCreditsApi {
    case getPersonMovieCredits(personId: Int)
}

extension PersonMovieCreditsApi: TargetType {
    
    private var constants: ApiConstants {
        return ApiConstants()
    }
    
    var baseURL: URL {
        return URL(string: constants.apiHost)!
    }
    
    var path: String {
        switch self {
        case .getPersonMovieCredits(let personId):
            return "/person/\(personId)/movie_credits"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Moya.Task {
        switch self {
        case .getPersonMovieCredits:
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
