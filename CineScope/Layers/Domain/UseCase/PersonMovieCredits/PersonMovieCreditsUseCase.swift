//
//  PersonMovieCreditsUseCase.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/24/25.
//

import Combine
import Foundation

// MARK: - Protocol Definition

protocol PersonMovieCreditsUseCase {
    func fetchPersonMovieCredits(personId: Int) -> AnyPublisher<PersonMovieCreditsResponse?, Error>?
}

struct PersonMovieCreditsUseCaseImpl: PersonMovieCreditsUseCase {
    private let service: PersonMovieCreditsService

    init(service: PersonMovieCreditsService) {
        self.service = service
    }

    func fetchPersonMovieCredits(personId: Int) -> AnyPublisher<PersonMovieCreditsResponse?, any Error>? {
        guard let personMovieCreditsPublisher = getPersonMovieCredits(api: .getPersonMovieCredits(personId: personId)) else { return nil }
        return personMovieCreditsPublisher.eraseToAnyPublisher()
    }
}

extension PersonMovieCreditsUseCaseImpl {
    func getPersonMovieCredits(api: PersonMovieCreditsApi) -> AnyPublisher<PersonMovieCreditsResponse?, any Error>? {
        service.getPersonMovieCredits(api: api)
    }
}
