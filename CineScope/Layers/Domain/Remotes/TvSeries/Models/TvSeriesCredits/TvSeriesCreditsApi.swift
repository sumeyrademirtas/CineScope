//
//  TvSeriesCreditsApi.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 3/3/25.
//

import Foundation
import Moya

enum TvSeriesCreditsApi {
    case getTvSeriesCredits(tvSeriesId: Int)
}

extension TvSeriesCreditsApi: TargetType {
    
    private var constants: ApiConstants {
        return ApiConstants()
    }
    
    var baseURL: URL {
        return URL(string: constants.apiHost)!

    }
    
    var path: String {
        switch self {
        case .getTvSeriesCredits(let tvSeriesId):
            return "/tv/\(tvSeriesId)/credits"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Moya.Task {
        switch self {
        case .getTvSeriesCredits:
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
