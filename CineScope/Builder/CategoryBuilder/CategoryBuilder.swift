//
//  CategoryBuilder.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 4/15/25.
//

import Foundation
import Moya
import UIKit

protocol CategoryBuilder {
    func build() -> UIViewController
}

struct CategoryBuilderImpl: CategoryBuilder {
    func build() -> UIViewController {
        // Servisleri oluştur
        let movieService = GenreMovieServiceImpl()
        let tvService = GenreTvServiceImpl()

        // UseCase’leri oluştur
        let movieUseCase = GenreMovieUseCaseImpl(service: movieService)
        let tvUseCase = GenreTvUseCaseImpl(service: tvService)

        // ViewModel’i oluştur
        let viewModel = CategoryVMImpl(
            genreMovieUseCase: movieUseCase,
            genreTvUseCase: tvUseCase
        )

        // VC’yi oluşturup ViewModel’i enjekte et
        let vc = CategoryVC(viewModel: viewModel)
        return vc
    }
}
