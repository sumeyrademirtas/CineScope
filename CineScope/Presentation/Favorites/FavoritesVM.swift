//
//  FavoritesVM.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 3/15/25.
//


import Foundation
import Combine
import CoreData

// MARK: - Protocol Definition
protocol FavoritesVM {
    func activityHandler(input: AnyPublisher<FavoritesVMImpl.FavoritesVMInput, Never>) -> AnyPublisher<FavoritesVMImpl.FavoritesVMOutput, Never>
}

// MARK: - Implementation
final class FavoritesVMImpl: FavoritesVM {

    // Combine Properties
    private let output = PassthroughSubject<FavoritesVMOutput, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Activity Handler
    func activityHandler(input: AnyPublisher<FavoritesVMInput, Never>) -> AnyPublisher<FavoritesVMOutput, Never> {
        input.sink { [weak self] inputEvent in
            guard let self = self else { return }
            switch inputEvent {
            case .fetchFavorites:
                self.fetchFavorites()
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
}

// MARK: - Event Definitions
extension FavoritesVMImpl {
    
    enum FavoritesVMInput {
        case fetchFavorites
    }
    
    enum FavoritesVMOutput {
        case isLoading(Bool)
        case errorOccurred(message: String)
        case dataSource(favorites: [FavoriteItem])
    }
}

// MARK: - Data Fetching
extension FavoritesVMImpl {
    private func fetchFavorites() {
        output.send(.isLoading(true))
        
        let favorites = CoreDataManager.shared.fetchFavorites() 
        print("📢 Favoriler Core Data'dan çekildi: \(favorites.count) adet")

        output.send(.dataSource(favorites: favorites))
        output.send(.isLoading(false))
    }
}
