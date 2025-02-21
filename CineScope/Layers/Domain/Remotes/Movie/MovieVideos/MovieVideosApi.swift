//
//  MovieVideosApi.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/18/25.
//

import Foundation
import Moya

enum MovieVideosApi {
    case getMovieVideos(movieId: Int) // Fragmanları çekecek case
}

extension MovieVideosApi: TargetType {
    
    private var constants: ApiConstants {
        return ApiConstants()
    }
    
    var baseURL: URL {
        return URL(string: constants.apiHost)!
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var path: String {
        switch self {
        case .getMovieVideos(let movieId):
            return "/movie/\(movieId)/videos"
        }
    }
    
    
    var task: Moya.Task {
        switch self {
        case .getMovieVideos:
            var params: [String: Any] = [:]
            params["api_key"] = constants.apiKey
            params["language"] = "en-US"
            return .requestParameters(parameters: params,
                encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
}
