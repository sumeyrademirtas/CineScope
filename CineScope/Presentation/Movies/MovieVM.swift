//
//  MovieViewModel.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 1/30/25.
//

import Foundation
import Combine

// MARK: - Protocol Definiton
protocol MovieVM {
    func activityHandler(input: AnyPublisher<MovieVMImpl.MovieVMInput, Never>) -> AnyPublisher<MovieVMImpl.MovieVMOutput, Never>
}

final class MovieVMImpl: MovieVM {

    // Combine Properties
    private let output = PassthroughSubject<MovieVMOutput, Never>() // output veriyi publish etmek icin kullaniliyor.
    private var cancellables = Set<AnyCancellable>() // Abonelikleri yonetmek icin.
    
    // UseCase
    private var useCase: MovieUseCase? // UseCase, Api cagrilari icin kullanilacak.
    
    // DataStorage
    private var categorySections: [MovieCategory: [SectionType]] = [:] // MARK: SOR
    private var sections: [SectionType] = []
    private var movies: [Movie] = []
    
    // Initialization
    init(useCase: MovieUseCase){
        self.useCase = useCase
    }
}

// MARK: - Events => Input, Output, SectionType, RowType
extension MovieVMImpl {
    
    enum MovieVMOutput {
        case isLoading(isShow: Bool) // MARK: - Mahsuna sor. Loading indicator ok, ama nasil kullaniyoruz, ekranda nasil goruyoruz.
        case sectionUpdated(category: MovieCategory, section: [SectionType]) // MARK: Mahsuna sor.
        case errorOccured(message: String)
        case dataSource(section: [SectionType]) // MARK: Mahsuna sor. Burasinin title i titleDataSource olarak degistirilebilir. dur ya cok da emin degilim.
    }
    
    enum MovieVMInput {
        case start(categories: [MovieCategory], page: Int) // MARK: - Mahsuna sor. O daha farkli yapmis. case kismini da function kismini da
    }
    
    enum SectionType {
        case popular(rows: [RowType])
        case upcoming(rows: [RowType])
        case nowPlaying(rows: [RowType])
        case topRated(rows: [RowType])
    }
    
    enum RowType {
        case movie(movie: [Movie])
    }
}

// MARK: - Prepare UI
extension MovieVMImpl {
    private func updateUI(popular: MovieResponse?, upcoming: MovieResponse?, nowPlaying: MovieResponse?, topRated: MovieResponse?) -> [SectionType] {
        
        var sections = [SectionType]()
        var popularRowType = [RowType]()
        var upcomingRowType = [RowType]()
        var nowPlayingRowType = [RowType]()
        
        if let popular = popular?.results {
            popularRowType.append(.movie(movie: popular))
            sections.append(.popular(rows: popularRowType))
        }
        
        if let nowPlaying = nowPlaying?.results {
            nowPlayingRowType.append(.movie(movie: nowPlaying))
            sections.append(.nowPlaying(rows: nowPlayingRowType))
        }
        
        if let topRated = topRated?.results {
            nowPlayingRowType.append(.movie(movie: topRated))
            sections.append(.topRated(rows: nowPlayingRowType))
        }
        
        if let upcoming = upcoming?.results {
            upcomingRowType.append(.movie(movie: upcoming))
            sections.append(.upcoming(rows: upcomingRowType))
        }
        
        return sections
    }
}

// MARK: Services - start
extension MovieVMImpl {
    private func fetchAllMovies(categories: [MovieCategory], page: Int) {
        self.output.send(.isLoading(isShow: true))
        // MARK: Sor weak self ve guard let self kullanmamistim bir onceki versiyonda. ne farki var arastir.
        self.useCase?.fetchAllMovies()?.sink(receiveCompletion: { [weak self] completion in
            guard let self else { return }
            switch completion {
            case . finished:
                self.output.send(.isLoading(isShow: false))
            case .failure(let error):
                print("Error: \(error)")
            }
        }, receiveValue: { [weak self] movies in
            guard let self else { return }
            let sections = self.updateUI(popular: movies.0, upcoming: movies.1, nowPlaying: movies.2, topRated: movies.3)
            self.output.send(.dataSource(section: sections))
        }).store(in: &cancellables)
    }
}



// MARK: - Activity Handler - sink(Combine Publisher dan gelen veriyi dinler)
extension MovieVMImpl {
    func activityHandler(input: AnyPublisher<MovieVMInput, Never>) -> AnyPublisher<MovieVMOutput, Never> {
        input.sink { [weak self] inputEvent in
        guard let self else { return }
            switch inputEvent {
                case .start(let categories, let page):
                self.fetchAllMovies(categories: categories, page: page)
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
}
