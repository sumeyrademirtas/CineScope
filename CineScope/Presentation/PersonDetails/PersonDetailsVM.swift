//
//  PersonDetailsVM.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/24/25.
//

import Combine
import Foundation

// MARK: - Protocol Definition

protocol PersonDetailsVM {
    func activityHandler(input: AnyPublisher<PersonDetailsVMImpl.PersonDetailsVMInput, Never>) -> AnyPublisher<PersonDetailsVMImpl.PersonDetailsVMOutput, Never>
}

final class PersonDetailsVMImpl: PersonDetailsVM {
    // Combine properties
    private let output = PassthroughSubject<PersonDetailsVMOutput, Never>()
    private var cancellables = Set<AnyCancellable>()

    // UseCases
    private var personDetailsUseCase: PersonDetailsUseCase?
    private var personMovieCreditsUseCase: PersonMovieCreditsUseCase?
    private var personTvCreditsUseCase: PersonTvCreditsUseCase?

    init(personDetailsUseCase: PersonDetailsUseCase, personMovieCreditsUseCase: PersonMovieCreditsUseCase,
         personTvCreditsUseCase: PersonTvCreditsUseCase)
    {
        self.personDetailsUseCase = personDetailsUseCase
        self.personMovieCreditsUseCase = personMovieCreditsUseCase
        self.personTvCreditsUseCase = personTvCreditsUseCase
    }

    // Data Storage
    private var personDetails: PersonDetails?
    private var personMovieCredits: PersonMovieCreditsResponse?
    private var personTvCredits: PersonTvCreditsResponse?
}

// MARK: - Events

extension PersonDetailsVMImpl {
    enum PersonDetailsVMInput {
        case fetchPersonDetails(personId: Int)
        case fetchPersonMovieCredits(personId: Int)
        case fetchPersonTvCredits(personId: Int)
    }

    enum PersonDetailsVMOutput {
        case isLoading(Bool)
//        case personDetails(PersonDetails)
//        case personMovieCredits([PersonMovieCredits])
//        case personTvCredits([PersonTvCredits])
        case dataSource(section: [SectionType])
        case errorOccured(String)
    }

    enum SectionType {
        case info(rows: [RowType]) // Kişinin temel bilgileri
        case movies(rows: [RowType])
        case tvShows(rows: [RowType])
    }

    enum RowType {
        case personInfo(info: PersonDetails)
        case personMovieCredits(movie: [PersonMovieCredits])
        case personTvCredits(tvShow: [PersonTvCredits])
    }
}

// MARK: - Prepare UI

extension PersonDetailsVMImpl {
    private func updateUI(person: PersonDetails?, personMovie: PersonMovieCreditsResponse?, personTvShows: PersonTvCreditsResponse?) -> [SectionType] {
        var sections = [SectionType]()
        var infoRowType = [RowType]()
        var moviesRowType = [RowType]()
        var tvShowsRowType = [RowType]()

        if let person = person {
            infoRowType.append(.personInfo(info: person))
            sections.append(.info(rows: infoRowType))
        }

        if let personMovie = personMovie?.cast {
            moviesRowType.append(.personMovieCredits(movie: personMovie))
            sections.append(.movies(rows: moviesRowType))
        }

        if let personTvShows = personTvShows?.cast {
            tvShowsRowType.append(.personTvCredits(tvShow: personTvShows))
            sections.append(.tvShows(rows: tvShowsRowType))
        }

        return sections
    }
}

// MARK: - Service Call

extension PersonDetailsVMImpl {
    private func fetchPersonDetails(personId: Int) {
        print("Fetch Person Details API request started")
        self.output.send(.isLoading(true))

        self.personDetailsUseCase?.fetchPersonDetails(personId: personId)?
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                self.output.send(.isLoading(false))
                if case .failure(let error) = completion {
                    print("⚠️ FetchPersonDetails API Error: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] response in
                guard let self else { return }
                if let personDetails = response {
                    print("Person details \(personDetails)")
                    self.personDetails = personDetails
                                self.updateSections() // Combine all data and update UI
                } else {
                    self.output.send(.errorOccured("No person details found"))
                }
            }).store(in: &self.cancellables)
    }

    private func fetchPersonTvCredits(personId: Int) {
        print("Fetch Person Tv Credits API request started")
        self.output.send(.isLoading(true))

        self.personTvCreditsUseCase?.fetchPersonTvCredits(personId: personId)?
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                self.output.send(.isLoading(false))
                if case .failure(let error) = completion {
                    print("⚠️ FetchPersonTvCredits API Error: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] response in
                guard let self else  { return }
                if let tvCredits = response {
                    print("Fetched credits: \(tvCredits.cast.count) cast members")
                    self.personTvCredits = tvCredits
                    self.updateSections() // Combine all data and update UI
                } else {
                    self.output.send(.errorOccured("No person details found"))
                }
            }).store(in: &self.cancellables)
    }

    private func fetchPersonMovieCredits(personId: Int) {
        print("Fetch Person Movie Credits API request started")
        self.output.send(.isLoading(true))

        self.personMovieCreditsUseCase?.fetchPersonMovieCredits(personId: personId)?
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                self.output.send(.isLoading(false))
                if case .failure(let error) = completion {
                    print("⚠️ FetchPersonMovieCredits API Error: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] response in
                guard let self else { return }
                if let movieCredits = response {
                    print("Fetched credits: \(movieCredits.cast.count) cast members")
                    self.personMovieCredits = movieCredits
                    self.updateSections() // Combine all data and update UI
                } else {
                    self.output.send(.errorOccured("No person details found"))
                }
            }).store(in: &self.cancellables)
    }
}

// MARK: - Update Sections

extension PersonDetailsVMImpl {
    private func updateSections() {
        let sections = self.updateUI(person: self.personDetails,
                                     personMovie: self.personMovieCredits,
                                     personTvShows: self.personTvCredits)
        self.output.send(.dataSource(section: sections))
    }
}

// MARK: - Activity Handler

extension PersonDetailsVMImpl {
    func activityHandler(input: AnyPublisher<PersonDetailsVMInput, Never>) -> AnyPublisher<PersonDetailsVMOutput, Never> {
        input.sink { [weak self] inputEvent in
            guard let self else { return }
            switch inputEvent {
            case .fetchPersonDetails(let personId):
                self.fetchPersonDetails(personId: personId)
            case .fetchPersonMovieCredits(let personId):
                self.fetchPersonMovieCredits(personId: personId)
            case .fetchPersonTvCredits(let personId):
                self.fetchPersonTvCredits(personId: personId)
            }
        }.store(in: &self.cancellables)
        return self.output.eraseToAnyPublisher()
    }
}
