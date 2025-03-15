//
//  FavoritesBuilder.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 3/15/25.
//

import Foundation
import UIKit

protocol FavoritesBuilder {
    func build() -> UIViewController
}

final class FavoritesBuilderImpl: FavoritesBuilder {
    func build() -> UIViewController {
        // Favoriler için ViewModel ve Provider'ı oluşturuyoruz
        let favoritesVM = FavoritesVMImpl()
        let favoritesProvider = FavoritesProviderImpl()
        
        // FavoritesVC'yi gerekli bağımlılıklarla oluşturuyoruz
        let favoritesVC = FavoritesVC(viewModel: favoritesVM, provider: favoritesProvider)
        return favoritesVC
    }
}
