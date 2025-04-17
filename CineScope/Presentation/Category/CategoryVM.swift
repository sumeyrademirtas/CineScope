//
//  CategoryVM.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 4/15/25.
//

import Foundation
import Combine

// MARK: - Protocol Definition
protocol CategoryVM {
    func activityHandler(input: AnyPublisher<CategoryVMImpl.CategoryVMInput, Never>) -> AnyPublisher<CategoryVMImpl.CategoryVMOutput, Never>
}

// MARK: - Implementation
final class CategoryVMImpl: CategoryVM {
    private let output = PassthroughSubject<CategoryVMOutput, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    
    private let genreMovieUseCase: GenreMovieUseCase
    private let genreTvUseCase: GenreTvUseCase
    
    init(genreMovieUseCase: GenreMovieUseCase, genreTvUseCase: GenreTvUseCase) {
        self.genreMovieUseCase = genreMovieUseCase
        self.genreTvUseCase = genreTvUseCase
    }
    
    
    func activityHandler(input: AnyPublisher<CategoryVMInput, Never>) -> AnyPublisher<CategoryVMOutput, Never> {
        input
            .sink { [weak self] inputEvent in
                guard let self = self else { return }
                switch inputEvent {
                case .fetchGenres(let isMovie):
                    self.fetchGenres(isMovie: isMovie)
                }
            }
            .store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
    
}

// MARK: - Input/Output Events
extension CategoryVMImpl {
    enum CategoryVMInput {
        case fetchGenres(isMovie: Bool)
    }
    
    enum CategoryVMOutput {
        case isLoading(Bool)
        case dataSource(genres: [CategoryItem])
        case errorOccurred(message: String)
    }
}

extension CategoryVMImpl {
    func fetchGenres(isMovie: Bool) {
        print("🔵 [CategoryVM] fetchGenres(isMovie: \(isMovie))")
        output.send(.isLoading(true))
        
        let publisher: AnyPublisher<[CategoryItem], Error> = {
            if isMovie {
                return genreMovieUseCase
                    .fetchMovieGenres()!
                    .map { response in
                        (response?.genres ?? []).map {
                            CategoryItem(
                                id: $0.id,
                                name: $0.name,
                                imageName: GenreImage(rawValue: $0.name)?.imageName ?? "genre_placeholder"
                            )
                        }
                    }
                    .eraseToAnyPublisher()
            } else {
                return genreTvUseCase
                    .fetchTvGenres()!
                    .map { response in
                        (response?.genres ?? []).map {
                            CategoryItem(
                                id: $0.id,
                                name: $0.name,
                                imageName: GenreImage(rawValue: $0.name)?.imageName ?? "genre_placeholder"
                            )
                        }
                    }
                    .eraseToAnyPublisher()
            }
        }()
        
        publisher
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.output.send(.isLoading(false))
                if case .failure(let err) = completion {
                    self.output.send(.errorOccurred(message: err.localizedDescription))
                }
            } receiveValue: { [weak self] items in
                guard let self = self else { return }
                self.output.send(.dataSource(genres: items))
            }
            .store(in: &cancellables)
    }
}
