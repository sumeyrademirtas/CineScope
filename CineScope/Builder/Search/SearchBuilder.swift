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
        let service = SearchMovieServiceImpl()
        let useCase = SearchUseCaseImpl(service: service)
        let viewModel = SearchVMImpl(useCase: useCase)
        let provider = SearchListProviderImpl()
        let vc = SearchVC(viewModel: viewModel, provider: provider)
        
        
        return vc
    }
}
