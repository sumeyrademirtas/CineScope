//
//  PersonTvCreditsUseCase.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/24/25.
//

import Combine
import Foundation

// MARK: - Protocol Definition

protocol PersonTvCreditsUseCase {
    func fetchPersonTvCredits(personId: Int) -> AnyPublisher<PersonTvCreditsResponse?, Error>?
}

struct PersonTvCreditsUseCaseImpl: PersonTvCreditsUseCase {
    private let service: PersonTvCreditsService

    init(service: PersonTvCreditsService) {
        self.service = service
    }

    func fetchPersonTvCredits(personId: Int) -> AnyPublisher<PersonTvCreditsResponse?, any Error>? {
        guard let personTvCreditsPublisher = getPersonTvCredits(api: .getPersonTvCredits(personId: personId)) else { return nil }
        return personTvCreditsPublisher.eraseToAnyPublisher()
    }
}

extension PersonTvCreditsUseCaseImpl {
    func getPersonTvCredits(api: PersonTvCreditsApi) -> AnyPublisher<PersonTvCreditsResponse?, any Error>? {
        service.getPersonTvCredits(api: api)
    }
}
