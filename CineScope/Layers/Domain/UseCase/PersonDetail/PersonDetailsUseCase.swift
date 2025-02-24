//
//  PersonDetailsUseCase.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/24/25.
//

import Combine
import Foundation

// MARK: - Protocol Definition

protocol PersonDetailsUseCase {
    func fetchPersonDetails(personId: Int) -> AnyPublisher<PersonDetails?, Error>?
}

struct PersonDetailsUseCaseImpl: PersonDetailsUseCase {
    private let service: PersonDetailsService

    init(service: PersonDetailsService) {
        self.service = service
    }
    
    func fetchPersonDetails(personId: Int) -> AnyPublisher<PersonDetails?, any Error>? {
        guard let personDetailsPublisher = getPersonDetails(api: .getPersonDetails(personId: personId)) else { return nil }
        return personDetailsPublisher.eraseToAnyPublisher()
    }
}

extension PersonDetailsUseCaseImpl {
    func getPersonDetails(api: PersonDetailsApi) -> AnyPublisher<PersonDetails?, any Error>? {
        service.getPersonDetails(api: api)
    }
}
