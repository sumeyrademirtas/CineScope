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
    
    //usecase
    private var useCase: MovieDetailsUseCase?
    
    init(useCase: MovieDetailsUseCase) {
        self.useCase = useCase
    }
    
    //data storage
    private var movieDetails: MovieDetails?

}


// MARK: - Events
extension MovieDetailsVMImpl {
    
    enum MovieDetailsVMInput {
        case fetchMovieDetails(movieId: Int)
    }
    
    enum MovieDetailsVMOutput {
        case isLoading(Bool)
        case movieDetails(MovieDetails)
        case errorOccurred(String)
    }
}

// MARK: - Service call
extension MovieDetailsVMImpl {
    private func fetchMovieDetails(movieId: Int) {
        print("Fetch Movie Details API request started")
        self.output.send(.isLoading(true))
        
        self.useCase?.fetchMovieDetails(movieId: movieId)?
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
}


// MARK: - Activity Handler
extension MovieDetailsVMImpl {
    func activityHandler(input: AnyPublisher<MovieDetailsVMInput, Never>) -> AnyPublisher<MovieDetailsVMOutput, Never> {
        input.sink { [weak self] inputEvent in
            guard let self = self else { return }
            switch inputEvent {
            case .fetchMovieDetails(let movieId):
                self.fetchMovieDetails(movieId: movieId)
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
}
