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
        let movieVideoService = MovieVideosServiceImpl()
        let movieDetailsUseCase = MovieDetailsUseCaseImpl(service: movieDetailsService/*, videoService: videoService*/)
        let movieCreditsUseCase = MovieCreditsUseCaseImpl(service: movieCreditsService)
        let movieVideoUseCase = MovieVideoUseCaseImpl(service: movieVideoService)
        let viewModel = MovieDetailsVMImpl(movieDetailsUseCase: movieDetailsUseCase, movieCreditsUseCase: movieCreditsUseCase, movieVideosUseCase: movieVideoUseCase)
        let provider = MovieDetailsProviderImpl()

        let vc = MovieDetailsVC(viewModel: viewModel, provider: provider)
        vc.configure(movieId: movieId) // 🔥 Burada configure çağrılıyor
        let navController = UINavigationController(rootViewController: vc)


        return navController
    }
}
