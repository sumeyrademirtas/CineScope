//
//  MovieBuilder.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/6/25.
//

import Foundation
import Moya
import UIKit

protocol MovieBuilder {
    func build() -> UIViewController
}

struct MovieBuilderImpl: MovieBuilder {
    func build() -> UIViewController {
        
        let constants = ApiConstants()
        let service = MovieServiceImpl()
        let useCase = MovieUseCaseImpl(service: service)
        let viewModel = MovieVMImpl(useCase: useCase)
        let provider = MovieListProviderImpl()
        let vc = MoviesVC(viewModel: viewModel, provider: provider)
        
        
        return vc
    }
}
