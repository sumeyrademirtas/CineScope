//
//  TvSeriesVideo.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 3/4/25.
//

import Foundation

struct TvSeriesVideo: Decodable {
    let id: String
    let key: String
    let site: String
    let type: String
    
    enum CodingKeys: String, CodingKey {
        case id, key, site, type
    }
    
    // ✅ Eğer video YouTube ve Trailer ise URL oluşturur
    var youtubeURL: URL? {
        guard site.lowercased() == "youtube", type.lowercased() == "trailer" else { return nil }
        return URL(string: "https://www.youtube.com/watch?v=\(key)")
    }
}

struct TvSeriesVideosResponse: Decodable {
    let id: Int
    let results: [TvSeriesVideo]
    
    var bestTrailer: TvSeriesVideo? {
        return results.first { $0.site.lowercased() == "youtube" && $0.type.lowercased() == "trailer" }
    }
}
