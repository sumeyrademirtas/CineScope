//
//  SearchBuilder.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/14/25.
//

import Foundation
import Moya
import UIKit

protocol SearchBuilder {
    func build() -> UIViewController
}

struct SearchBuilderImpl: SearchBuilder {
    func build() -> UIViewController {
        let constants = ApiConstants()
        let movieService = SearchMovieServiceImpl()
        let tvSeriesService = SearchTvSeriesServiceImpl()
        let useCase = SearchUseCaseImpl(movieService: movieService, tvSeriesService: tvSeriesService)
        let viewModel = SearchVMImpl(useCase: useCase)
        let provider = SearchListProviderImpl()
        let searchVC = SearchVC(viewModel: viewModel, provider: provider)

        let navController = UINavigationController(rootViewController: searchVC)
        return navController
    }
}
