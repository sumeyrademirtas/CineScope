//
//  TvSeriesDetailsBuilder.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 3/4/25.
//

import Foundation
import Moya
import UIKit

protocol TvSeriesDetailsBuilder {
    func build(tvSeriesId: Int) -> UIViewController
}

struct TvSeriesDetailsBuilderImpl: TvSeriesDetailsBuilder {
    func build(tvSeriesId: Int) -> UIViewController {
        
        let tvSeriesDetailsService = TvSeriesDetailsServiceImpl()
        let tvSeriesCreditsService = TvSeriesCreditsServiceImpl()
        let tvSeriesVideoService = TvSeriesVideoServiceImpl()
        let tvSeriesDetailsUseCase = TvSeriesDetailsUseCaseImpl(service: tvSeriesDetailsService)
        let tvSeriesCreditsUseCase = TvSeriesCreditsUseCaseImpl(service: tvSeriesCreditsService)
        let tvSeriesVideoUseCase = TvSeriesVideoUseCaseImpl(service: tvSeriesVideoService)
        let viewModel = TvSeriesDetailsVMImpl(tvSeriesDetailsUseCase: tvSeriesDetailsUseCase, tvSeriesCreditsUseCase: tvSeriesCreditsUseCase, tvSeriesVideosUseCase: tvSeriesVideoUseCase)
        let provider = TvSeriesDetailsProviderImpl()

        let vc = TvSeriesDetailsVC(viewModel: viewModel, provider: provider)
        vc.configure(tvSeriesId: tvSeriesId) // 🔥 Burada configure çağrılıyor
        let navController = UINavigationController(rootViewController: vc)
        
        return navController
    }
}
