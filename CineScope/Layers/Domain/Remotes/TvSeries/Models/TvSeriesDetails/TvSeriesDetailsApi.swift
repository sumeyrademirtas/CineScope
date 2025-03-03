//
//  TvSeriesDetailsApi.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 3/3/25.
//

import Foundation
import Moya

enum TvSeriesDetailsApi {
    case getTvSeriesDetails(tvSeriesId: Int)
}

extension TvSeriesDetailsApi: TargetType {
    
    private var constants: ApiConstants {
        return ApiConstants()
    }
    
    var baseURL: URL {
        return URL(string: constants.apiHost)!
    }
    
    var path: String {
        switch self {
        case .getTvSeriesDetails(let tvSeriesId):
            return "/tv/\(tvSeriesId)"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Moya.Task {
        switch self {
        case .getTvSeriesDetails:
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
