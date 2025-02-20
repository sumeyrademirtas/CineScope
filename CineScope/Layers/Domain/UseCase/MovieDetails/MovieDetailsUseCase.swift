//
//  MovieDetailsUseCase.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/16/25.
//

import Foundation
import Combine

// MARK: - Protocol Definition
protocol MovieDetailsUseCase {
    func fetchMovieDetails(movieId: Int) -> AnyPublisher<MovieDetails?, Error>?
    func fetchMovieVideos(movieId: Int) -> AnyPublisher<MovieVideo?, Error>? // 🎬 Yeni method

}

struct MovieDetailsUseCaseImpl: MovieDetailsUseCase {

    
    private let service: MovieDetailsService
//    private let videoService: MovieVideosService // 🎬 Yeni servis

    
    init(service: MovieDetailsService/*, videoService: MovieVideosService*/) {
        self.service = service
//        self.videoService = videoService

    }
    
    func fetchMovieDetails(movieId: Int) -> AnyPublisher<MovieDetails?, any Error>? {
        guard let movieDetailsPublisher = getMovieDetails(api: .getMovieDetails(movieId: movieId)) else { return nil }
        return movieDetailsPublisher.eraseToAnyPublisher()
    }
    
//    func fetchMovieVideos(movieId: Int) -> AnyPublisher<MovieVideo?, Error>? {
//        print("🎬 UseCase -> Fetch Movie Videos API çağrıldı! movieId: \(movieId)")
//
//        return videoService.getMovieVideo(api: .getMovieVideos(movieId: movieId))?
//            .compactMap { $0?.results.first { $0.youtubeURL != nil }
//            } // 🔥 Model'deki `youtubeURL`'i kullan
//        
//            .eraseToAnyPublisher()
//    }
    
}


extension MovieDetailsUseCaseImpl {
    func getMovieDetails(api: MovieDetailsApi) -> AnyPublisher<MovieDetails?, any Error>? {
        service.getMovieDetails(api: api)
    }
    
//    func getMovieVideos(api: MovieVideosApi) -> AnyPublisher<MovieVideosResponse?, any Error>? {
//        videoService.getMovieVideo(api: api) 
//    }
}
