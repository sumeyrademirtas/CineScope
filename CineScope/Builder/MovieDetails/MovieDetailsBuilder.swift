//
//  MovieDetailsBuilder.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/17/25.
//

import Foundation
import Moya
import UIKit

protocol MovieDetailsBuilder {
    func build(movieId: Int) -> UIViewController
}

struct MovieDetailsBuilderImpl: MovieDetailsBuilder {
    func build(movieId: Int) -> UIViewController {
        
        let movieDetailsService = MovieDetailsServiceImpl()
        let movieCreditsService = MovieCreditsServiceImpl()
//        let videoService = MovieVideosServiceImpl()
        let movieDetailsUseCase = MovieDetailsUseCaseImpl(service: movieDetailsService/*, videoService: videoService*/)
        let movieCreditsUseCase = MovieCreditsUseCaseImpl(service: movieCreditsService)
        let viewModel = MovieDetailsVMImpl(movieDetailsUseCase: movieDetailsUseCase, movieCreditsUseCase: movieCreditsUseCase)
        let provider = MovieDetailsProviderImpl()

        let vc = MovieDetailsVC(viewModel: viewModel, provider: provider)
        vc.configure(movieId: movieId) // 🔥 Burada configure çağrılıyor

        return vc
    }
}
