//
//  TvSeriesVideoApi.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 3/4/25.
//

import Foundation
import Moya

enum TvSeriesVideoApi {
    case getTvSeriesVideos(tvSeriesId: Int)
}


extension TvSeriesVideoApi: TargetType {
    
    private var constants: ApiConstants {
        return ApiConstants()
    }
    
    var baseURL: URL {
        return URL(string: constants.apiHost)!
    }
    
    var path: String {
        switch self {
        case .getTvSeriesVideos(let tvSeriesId):
            return "/tv/\(tvSeriesId)/videos"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Moya.Task {
        switch self {
        case .getTvSeriesVideos:
            var params: [String: Any] = [:]
            params["api_key"] = constants.apiKey
            params["language"] = "en-US"
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
    
    
}
