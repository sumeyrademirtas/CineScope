//
//  MovieDetailsVM.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/16/25.
//

import Foundation
import Combine

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
    private var movieCreditsUseCase: MovieCreditsUseCase? // 🎭 Yeni eklendi

    init(movieDetailsUseCase: MovieDetailsUseCase, movieCreditsUseCase: MovieCreditsUseCase) {
        self.movieDetailsUseCase = movieDetailsUseCase
        self.movieCreditsUseCase = movieCreditsUseCase
    }
    
    // Data storage
    private var movieDetails: MovieDetails?
    private var movieCredits: MovieCredits? // 🎭 Yeni eklendi

}


// MARK: - Events
extension MovieDetailsVMImpl {
    
    enum MovieDetailsVMInput {
        case fetchMovieDetails(movieId: Int)
        case fetchMovieCredits(movieId: Int) // 🎭 Yeni eklendi

    }
    
    enum MovieDetailsVMOutput {
        case isLoading(Bool)
        case movieDetails(MovieDetails)
        case errorOccurred(String)
        case movieCredits([Cast]) // 🎭 Yeni eklendi
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
            }, receiveValue: { [weak self] response  in
                guard let self else { return }
                if let details = response {
                    self.output.send(.movieDetails(details))
                } else {
                    self.output.send(.errorOccurred("No movie detils found"))
                }
            }).store(in: &cancellables)
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
                    if let credits = response {
                        print("Fetched credits: \(credits.cast.count) cast members")
                        self.movieCredits = credits
                        self.output.send(.movieCredits(credits.cast)) // 🎭 Output'a gönderiyoruz
                    } else {
                        self.output.send(.errorOccurred("Oyuncu bilgileri bulunamadı."))
                    }
                })
                .store(in: &cancellables)
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
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
}
