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
        
        let service = MovieDetailsServiceImpl()
        let videoService = MovieVideosServiceImpl()
        let useCase = MovieDetailsUseCaseImpl(service: service, videoService: videoService)
        let viewModel = MovieDetailsVMImpl(useCase: useCase)
        let provider = MovieDetailsProviderImpl()

        let vc = MovieDetailsVC(viewModel: viewModel, provider: provider)
        vc.configure(movieId: movieId) // 🔥 Burada configure çağrılıyor

        return vc
    }
}
