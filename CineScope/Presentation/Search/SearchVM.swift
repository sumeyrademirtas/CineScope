//
//  SearchVM.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/12/25.
//

import Foundation
import Combine

// MARK: - Protocol Definition
protocol SearchVM {
    func activityHandler(input: AnyPublisher<SearchVMImpl.SearchVMInput, Never>) -> AnyPublisher<SearchVMImpl.SearchVMOutput, Never>
}

final class SearchVMImpl: SearchVM {
        
    // Combine properties
    private let output = PassthroughSubject<SearchVMOutput, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    //usecase
    private var useCase: SearchUseCase?
    
    init(useCase: SearchUseCase) {
        self.useCase = useCase
    }
    
    // FIXME: Data storage ne kadar anlamli emin degilim su an

}


// MARK: - Events
extension SearchVMImpl {
// FIXME: AMAAAAAN EMIN DEGILIM BURALARDAN BIRAZ DUSUNIM
    // Input events coming from the UI (e.g., search bar)
    enum SearchVMInput {
        case queryChanged(String)    // Her karakter girişiyle tetiklenir.
    }
    
    // Output events to be published to the UI.
    enum SearchVMOutput {
        case isLoading(Bool)         // Arama sırasında yükleme göstergesini kontrol eder.
        case results([SearchMovie])  // Arama sonuçlarını içeren model dizisi.
        case errorOccured(String)    // Hata mesajı.
        case noResults               // Arama sonucunda hiçbir sonuç bulunamazsa.
    }
}

// MARK: Service call
extension SearchVMImpl {
    private func fetchSearchResults(query: String, page: Int) {
        print("API request started")
        self.output.send(.isLoading(true))
        
        self.useCase?.fetchAllSearchResults(query: query)?
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                self.output.send(.isLoading(false))
                if case .failure(let error) = completion {
                    print("⚠️ Search API Error: \(error.localizedDescription)")
//                    self.output.send(.errorOccured(error.localizedDescription))
                }
            }, receiveValue: { [weak self] response in
                guard let self else { return }
                if let results  = response?.results, !results.isEmpty {
                    self.output.send(.results(results))
                } else {
                    self.output.send(.noResults)
                }
            }).store(in: &cancellables)
    }
}




// MARK: - Activity Handler
extension SearchVMImpl {
    func activityHandler(input: AnyPublisher<SearchVMInput, Never>) -> AnyPublisher<SearchVMOutput, Never> {
        input.sink { [weak self] inputEvent in
            guard let self = self else { return }
            switch inputEvent {
            case .queryChanged(let query):
                self.fetchSearchResults(query: query, page: 1)
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher() 
    }
}
