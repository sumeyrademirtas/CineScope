//
//  SearchVM.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/12/25.
//

import Combine
import Foundation

// MARK: - Protocol Definition

protocol SearchVM {
    func activityHandler(input: AnyPublisher<SearchVMImpl.SearchVMInput, Never>) -> AnyPublisher<SearchVMImpl.SearchVMOutput, Never>
}

final class SearchVMImpl: SearchVM {
    // Combine properties
    private let output = PassthroughSubject<SearchVMOutput, Never>()
    private var cancellables = Set<AnyCancellable>()

    // usecase
    private var useCase: SearchUseCase?

    init(useCase: SearchUseCase) {
        self.useCase = useCase
    }

    // FIXME: Data storage ne kadar anlamli emin degilim su an
}

// MARK: - Events

extension SearchVMImpl {
    // Input events coming from the UI (e.g., search bar)
    enum SearchVMInput {
        case queryChanged(String)
    }

    // Output events to be published to the UI.
    enum SearchVMOutput {
        case isLoading(Bool)
        case results(movies: [SearchMovie], tvSeries: [SearchTvSeries])
        case errorOccured(String)
        case noResults
    }
}

// MARK: - Service call

extension SearchVMImpl {
    private func fetchSearchResults(query: String, page: Int) {
        print("API request started")
        output.send(.isLoading(true))

        let publisher = useCase?.fetchAllSearchResults(query: query)
            ?? Empty<(SearchMovieResponse?, SearchTvSeriesResponse?), Error>().eraseToAnyPublisher()

        publisher
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                self.output.send(.isLoading(false))
                if case .failure(let error) = completion {
                    print("⚠️ Search API Error: \(error.localizedDescription)")
                    self.output.send(.errorOccured(error.localizedDescription))
                }
            }, receiveValue: { [weak self] response in
                guard let self = self else { return }
                let movieResults = response.0?.results ?? []
                let tvSeriesResults = response.1?.results ?? []

                if !movieResults.isEmpty || !tvSeriesResults.isEmpty {
                    self.output.send(.results(movies: movieResults, tvSeries: tvSeriesResults))
                } else {
                    self.output.send(.noResults)
                }
            })
            .store(in: &cancellables)
    }
}

// MARK: - Activity Handler

extension SearchVMImpl {
    func activityHandler(input: AnyPublisher<SearchVMImpl.SearchVMInput, Never>) -> AnyPublisher<SearchVMImpl.SearchVMOutput, Never> {
        input
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates { previous, current in
                if case .queryChanged(let previousQuery) = previous,
                   case .queryChanged(let currentQuery) = current
                {
                    return previousQuery == currentQuery
                }
                return false
            }
            .sink { [weak self] inputEvent in
                guard let self = self else { return }
                switch inputEvent {
                case .queryChanged(let query):
                    self.fetchSearchResults(query: query, page: 1)
                }
            }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
}
