//
//  TvSeriesBuilder.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/10/25.
//

import Foundation
import Moya
import UIKit

protocol TvSeriesBuilder {
    func build() -> UIViewController
}

struct TvSeriesBuilderImpl: TvSeriesBuilder {
    func build() -> UIViewController {
        
        let constants = ApiConstants()
        let service = TvSeriesServiceImpl()
        let useCase = TvSeriesUseCaseImpl(service: service)
        let viewModel = TvSeriesVMImpl(useCase: useCase)
        let provider = TvSeriesListProviderImpl()
        let vc = TvSeriesVC(viewModel: viewModel, provider: provider)
        
        return vc
    }
    
    
}
