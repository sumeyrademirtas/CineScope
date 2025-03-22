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
    private var categorySections: [MovieCategory: [SectionType]] = [:] // Her bir kategoriye ait SectionType listesi tutabilir.
    private var sections: [SectionType] = [] // Tum SectionType larin bir listesi.
    private var movies: [Movie] = [] // Filmlerin listesi.
    
    // Initialization // Dependency Injection
    init(useCase: MovieUseCase){ // Disaridan MovieUseCase i aliyor, test edilebilir moduler yapi olusturuyoruz.
        self.useCase = useCase
    }
}

// MARK: - Events => Input, Output, SectionType, RowType
extension MovieVMImpl {
    
    enum MovieVMOutput {
        case isLoading(isShow: Bool)
        case errorOccured(message: String)
        case dataSource(section: [SectionType])
    }
    
    enum MovieVMInput {
        case start(categories: [MovieCategory], page: Int)
    }
    
    enum SectionType { // Kategoriler
        case trending(rows: [RowType])
        case popular(rows: [RowType])
        case upcoming(rows: [RowType])
        case nowPlaying(rows: [RowType])
        case topRated(rows: [RowType])
    }
    
    enum RowType { // Her section icindeki filmler icin.
        case movie(movie: [Movie])
    }
}

// MARK: - Prepare UI
extension MovieVMImpl { 
    private func updateUI(trending: MovieResponse?, popular: MovieResponse?, upcoming: MovieResponse?, nowPlaying: MovieResponse?, topRated: MovieResponse?) -> [SectionType] {
        
        var sections = [SectionType]()
        var trendingRowType = [RowType]()
        var popularRowType = [RowType]()
        var upcomingRowType = [RowType]()
        var nowPlayingRowType = [RowType]()
        var topRatedRowType = [RowType]()
        
        if let trending = trending?.results {
            trendingRowType.append(.movie(movie: trending))
            sections.append(.trending(rows: trendingRowType))
        }
        
        if let popular = popular?.results {
            popularRowType.append(.movie(movie: popular))
            sections.append(.popular(rows: popularRowType))
        }
     
    
        if let upcoming = upcoming?.results {
            upcomingRowType.append(.movie(movie: upcoming))
            sections.append(.upcoming(rows: upcomingRowType))
        }
        
        if let nowPlaying = nowPlaying?.results {
            nowPlayingRowType.append(.movie(movie: nowPlaying))
            sections.append(.nowPlaying(rows: nowPlayingRowType))
        }
        
        if let topRated = topRated?.results {
            topRatedRowType.append(.movie(movie: topRated))
            sections.append(.topRated(rows: topRatedRowType))
        }
        
        return sections
    }
}

// MARK: Services - start
extension MovieVMImpl {
    private func fetchAllMovies(categories: [MovieCategory], page: Int) {
        self.output.send(.isLoading(isShow: true))
        self.useCase?.fetchAllMovies()?
            .sink(receiveCompletion: { [weak self] completion in // (ViewModel) zayıf referans
            guard let self else { return }
            switch completion {
            case . finished:
                self.output.send(.isLoading(isShow: false))
            case .failure(let error):
                print("Error: \(error)")
            }
        }, receiveValue: { [weak self] movies in
            guard let self else { return }
            let sections = self.updateUI(trending: movies.0, popular: movies.1, upcoming: movies.2, nowPlaying: movies.3, topRated: movies.4)
            self.output.send(.dataSource(section: sections))
        }).store(in: &cancellables)
    }
}



// MARK: - Activity Handler - sink(Combine Publisher dan gelen veriyi dinler)
extension MovieVMImpl {
    // Alttaki yapi reaktif programlama prensiplerini kullanarak, ViewModel ile UI arasinda veri akisini ve durum yonetimini saglar. 
    func activityHandler(input: AnyPublisher<MovieVMInput, Never>) -> AnyPublisher<MovieVMOutput, Never> {
        input.sink { [weak self] inputEvent in
        guard let self else { return }
            switch inputEvent {
                case .start(let categories, let page):
                self.fetchAllMovies(categories: categories, page: page) // MovieVMImpl icindeki fetchAllMovies i cagiriyor bu sefer.
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
}
