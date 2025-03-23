//
//  TvSeriesApi.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/7/25.
//

import Foundation
import Moya

enum TvSeriesApi {
    case getTrendingTvSeries(page: Int)
    case getAiringTodayTvSeries(page: Int)
    case getOnTheAirTvSeries(page: Int)
    case getPopularTvSeries(page: Int)
    case getTopRatedTvSeries(page: Int)
}

extension TvSeriesApi: TargetType {
    private var constants: ApiConstants {
        return ApiConstants()
    }
    
    var baseURL: URL {
        return URL(string: constants.apiHost)!
    }
    
    var path: String {
        switch self {
        case .getTrendingTvSeries(page: let page):
            return "trending/tv/week"
        case .getAiringTodayTvSeries(page: let page):
            return "/tv/airing_today"
        case .getOnTheAirTvSeries(page: let page):
            return "/tv/on_the_air"
        case .getPopularTvSeries(page: let page):
            return "/tv/popular"
        case .getTopRatedTvSeries(page: let page):
            return "/tv/top_rated"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Moya.Task {
        switch self {
        case
            .getTrendingTvSeries(page: let page),
            .getAiringTodayTvSeries(page: let page),
            .getOnTheAirTvSeries(page: let page),
            .getPopularTvSeries(page: let page),
            .getTopRatedTvSeries(page: let page):
            var params: [String: Any] = [:]
            params["api_key"] = constants.apiKey
            params["page"] = page
            params["language"] = "en-US"
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        }
    }
    
    var headers: [String: String]? {
        return [
            "Content-Type": "application/json"
        ]
    }
}
