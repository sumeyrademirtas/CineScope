//
//  PersonDetailsBuilder.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/25/25.
//

import Foundation
import Moya
import UIKit

protocol PersonDetailsBuilder {
    func build(personId: Int) -> UIViewController
}

struct PersonDetailsBuilderImpl: PersonDetailsBuilder {
    func build(personId: Int) -> UIViewController {
        
        let constants = ApiConstants()
        
        let personDetailsService = PersonDetailsServiceImpl()
        let personMovieCreditService = PersonMovieCreditsServiceImpl()
        let personTvCreditService = PersonTvCreditsServiceImpl()
        
        let personDetailsUseCase = PersonDetailsUseCaseImpl(service: personDetailsService)
        let personMovieCreditsUseCase = PersonMovieCreditsUseCaseImpl(service: personMovieCreditService)
        let personTvCreditsUseCase = PersonTvCreditsUseCaseImpl(service: personTvCreditService)
        
        
        let viewModel = PersonDetailsVMImpl(personDetailsUseCase: personDetailsUseCase, personMovieCreditsUseCase: personMovieCreditsUseCase, personTvCreditsUseCase: personTvCreditsUseCase)
        
        let provider = PersonDetailsProviderImpl()
        let vc = PersonDetailsVC(viewModel: viewModel, provider: provider)
        
        vc.configure(personId: personId) // 🔥 Burada configure çağrılıyor
        
        
        return vc
    }
}
