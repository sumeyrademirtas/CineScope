//
//  MovieDetailsVM.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/16/25.
//

import Combine
import Foundation

// MARK: - Protocol Definition

protocol MovieDetailsVM {
    func activityHandler(input: AnyPublisher<MovieDetailsVMImpl.MovieDetailsVMInput, Never>) -> AnyPublisher<MovieDetailsVMImpl.MovieDetailsVMOutput, Never>
}

final class MovieDetailsVMImpl: MovieDetailsVM {
    // Combine properties
    private let output = PassthroughSubject<MovieDetailsVMOutput, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    // UseCases
    private var movieDetailsUseCase: MovieDetailsUseCase?
    private var movieCreditsUseCase: MovieCreditsUseCase?
    private var movieVideosUseCase: MovieVideoUseCase?

    init(movieDetailsUseCase: MovieDetailsUseCase, movieCreditsUseCase: MovieCreditsUseCase, movieVideosUseCase: MovieVideoUseCase) {
        self.movieDetailsUseCase = movieDetailsUseCase
        self.movieCreditsUseCase = movieCreditsUseCase
        self.movieVideosUseCase = movieVideosUseCase
    }
    
    // Data storage
    private var movieDetails: MovieDetails?
    private var movieCredits: MovieCredits?
    private var movieVideos: MovieVideosResponse?
    private var bestTrailer: MovieVideo?
}

// MARK: - Events

extension MovieDetailsVMImpl {
    enum MovieDetailsVMInput {
        case fetchMovieDetails(movieId: Int)
        case fetchMovieCredits(movieId: Int)
        case fetchMovieVideos(movieId: Int)
    }
    
    enum MovieDetailsVMOutput {
        case isLoading(Bool)
        case dataSource(section: [SectionType])
        case errorOccurred(String)
    }
    
    enum SectionType {
        case video(rows: [RowType])
        case info(rows: [RowType])
        case cast(rows: [RowType])
    }
    
    enum RowType {
        case movieVideo(video: [MovieVideo])
        case movieInfo(info: MovieDetails)
        case movieCast(cast: [Cast])
    }
}

// MARK: - Prepare UI

extension MovieDetailsVMImpl {
    private func updateUI(movieVideo: [MovieVideo]?, movieInfo: MovieDetails?, movieCast: MovieCredits?) -> [SectionType] {
        var sections = [SectionType]()
        var videoRowType = [RowType]()
        var infoRowType = [RowType]()
        var castRowType = [RowType]()
        
        if let movieVideo = movieVideo {
            videoRowType.append(.movieVideo(video: movieVideo))
            sections.append(.video(rows: videoRowType))
        }
        
        if let movieInfo = movieInfo {
            infoRowType.append(.movieInfo(info: movieInfo))
            sections.append(.info(rows: infoRowType))
        }
        
        if let movieCast = movieCast?.cast {
            castRowType.append(.movieCast(cast: movieCast))
            sections.append(.cast(rows: castRowType))
        }
        
        return sections
    }
}

// MARK: - Service call

extension MovieDetailsVMImpl {
    private func fetchMovieDetails(movieId: Int) {
        print("Fetch Movie Details API request started")
        self.output.send(.isLoading(true))
        
        self.movieDetailsUseCase?.fetchMovieDetails(movieId: movieId)?
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                self.output.send(.isLoading(false))
                if case .failure(let error) = completion {
                    print("⚠️ FetchMovieDetails API Error: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] response in
                guard let self else { return }
                if let movieDetails = response {
                    print("Movie Details \(movieDetails)")
                    self.movieDetails = movieDetails
                    self.updateSections() // Combine all data and update UI
                } else {
                    self.output.send(.errorOccurred("No movie details found"))
                }
            }).store(in: &self.cancellables)
    }
    
    private func fetchMovieCredits(movieId: Int) {
        print("🎭 Fetch Movie Credits API çağrısı başlatıldı! movieId: \(movieId)")
            
        self.movieCreditsUseCase?.fetchMovieCredits(movieId: movieId)?
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                if case .failure(let error) = completion {
                    print("⚠️ FetchMovieCredits API Hatası: \(error.localizedDescription)")
                    self.output.send(.errorOccurred("Oyuncu bilgileri yüklenirken hata oluştu."))
                }
            }, receiveValue: { [weak self] response in
                guard let self = self else { return }
                if let movieCredits = response {
                    print("Fetched credits: \(movieCredits.cast.count) cast members")
                    self.movieCredits = movieCredits
                    self.updateSections()
                } else {
                    self.output.send(.errorOccurred("No cast details found"))
                }
            })
            .store(in: &self.cancellables)
    }
    
    private func fetchMovieVideos(movieId: Int) {
        print("Fetch Movie Video Api cagrisi baslatildi. movieId: \(movieId)")
        
        self.movieVideosUseCase?.fetchMovieVideos(movieId: movieId)?
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                if case .failure(let error) = completion {
                    print("FetchMovieVideos Api hatasi: \(error.localizedDescription)")
                    self.output.send(.errorOccurred("Video yuklenirken hata olustu"))
                }
            }, receiveValue: { [weak self] singleTrailer in
                guard let self = self else { return }
                if let trailer = singleTrailer,
                   let url = trailer.youtubeURL
                {
                    print("Best trailer YouTube URL: \(url.absoluteString)")
                    self.bestTrailer = trailer
                    self.updateSections()
                } else {
                    print("No valid trailer found")
                    self.output.send(.errorOccurred("No valid trailer found"))
                }
            })
            .store(in: &self.cancellables)
    }
}

// MARK: - Update Sections
 
extension MovieDetailsVMImpl {
    private func updateSections() {
        let bestTrailerArray: [MovieVideo]? = self.bestTrailer.map { [$0] }
        let sections = self.updateUI(
            movieVideo: bestTrailerArray,
            movieInfo: self.movieDetails,
            movieCast: self.movieCredits
        )
        self.output.send(.dataSource(section: sections))
    }
}

// MARK: - Activity Handler

extension MovieDetailsVMImpl {
    func activityHandler(input: AnyPublisher<MovieDetailsVMInput, Never>) -> AnyPublisher<MovieDetailsVMOutput, Never> {
        input.sink { [weak self] inputEvent in
            guard let self = self else { return }
            switch inputEvent {
            case .fetchMovieDetails(let movieId):
                self.fetchMovieDetails(movieId: movieId)
            case .fetchMovieCredits(let movieId):
                self.fetchMovieCredits(movieId: movieId)
            case .fetchMovieVideos(movieId: let movieId):
                self.fetchMovieVideos(movieId: movieId)
            }
        }.store(in: &self.cancellables)
        return self.output.eraseToAnyPublisher()
    }
}
