//
//  MovieVideo.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/18/25.
//

import Foundation

struct MovieVideo: Decodable {
    let id: String
    let key: String
    let site: String
    let type: String
    
    enum CodingKeys: String, CodingKey {
        case id, key, site, type
    }
    
    
    // site: youtube, type: trailer olacak sekilde filtreliyor.
    var youtubeURL: URL? {
        guard site.lowercased() == "youtube", type.lowercased() == "trailer" else { return nil }
        return URL(string: "https://www.youtube.com/watch?v=\(key)")
    }
}


struct MovieVideosResponse: Decodable {
    let results: [MovieVideo]
}

