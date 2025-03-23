//
//  TvSeriesVM.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/10/25.
//

import Combine
import Foundation

// MARK: - Protocol Definition

protocol TvSeriesVM {
    func activityHandler(input: AnyPublisher<TvSeriesVMImpl.TvSeriesVMInput, Never>) -> AnyPublisher<TvSeriesVMImpl.TvSeriesVMOutput, Never>
}

final class TvSeriesVMImpl: TvSeriesVM {
    // Combine properties
    private let output = PassthroughSubject<TvSeriesVMOutput, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    // Usecase
    private var useCase: TvSeriesUseCase?
    
    // DataStorage
    private var categorySections: [TvSeriesCategory: [SectionType]] = [:]
    private var sections: [SectionType] = []
    private var tvSeries: [TvSeries] = []
    
    // init
    init(useCase: TvSeriesUseCase) {
        self.useCase = useCase
    }
}

// MARK: - Events

extension TvSeriesVMImpl {
    enum TvSeriesVMOutput {
        case isLoading(isShow: Bool)
        case errorOccured(message: String)
        case dataSource(section: [SectionType])
    }
    
    enum TvSeriesVMInput {
        case start(categories: [TvSeriesCategory], page: Int)
    }

    enum SectionType {
        case trending(rows: [RowType])
        case airingToday(rows: [RowType])
        case onTheAir(rows: [RowType])
        case popular(rows: [RowType])
        case topRated(rows: [RowType])
    }
    
    enum RowType {
        case tvSeries(tvSeries: [TvSeries])
    }
}

// MARK: - Prepare UI

extension TvSeriesVMImpl {
    private func updateUI(trending: TvSeriesResponse?, airingToday: TvSeriesResponse?, onTheAir: TvSeriesResponse?, popular: TvSeriesResponse?, topRated: TvSeriesResponse?) -> [SectionType] {
        var sections = [SectionType]()
        var trendingRowType = [RowType]()
        var airingTodayRowType = [RowType]()
        var onTheAirRowType = [RowType]()
        var popularRowType = [RowType]()
        var topRatedRowType = [RowType]()
        
        if let trending = trending?.results {
            trendingRowType.append(.tvSeries(tvSeries: trending))
            sections.append(.trending(rows: trendingRowType))
        }
        
        if let airingToday = airingToday?.results {
            airingTodayRowType.append(.tvSeries(tvSeries: airingToday))
            sections.append(.airingToday(rows: airingTodayRowType))
        }
        
        if let onTheAir = onTheAir?.results {
            onTheAirRowType.append(.tvSeries(tvSeries: onTheAir))
            sections.append(.onTheAir(rows: onTheAirRowType))
        }
        
        if let popular = popular?.results {
            popularRowType.append(.tvSeries(tvSeries: popular))
            sections.append(.popular(rows: popularRowType))
        }
        
        if let topRated = topRated?.results {
            topRatedRowType.append(.tvSeries(tvSeries: topRated))
            sections.append(.topRated(rows: topRatedRowType))
        }
        
        return sections
    }
}

// MARK: - Services - start

extension TvSeriesVMImpl {
    private func fetchAllTvSeries(categories: [TvSeriesCategory], page: Int) {
        output.send(.isLoading(isShow: true))
        useCase?.fetchAllTvSeries()?
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else { return }
                switch completion {
                case .finished:
                    self.output.send(.isLoading(isShow: false))
                case .failure(let error):
                    print("Error: \(error)")
                }
            }, receiveValue: { [weak self] tvSeries in
                // API'den gelen tvSeries tuple'ı burada alınır.
                guard let self else { return }
                let sections = self.updateUI(trending: tvSeries.0, airingToday: tvSeries.1, onTheAir: tvSeries.2, popular: tvSeries.3, topRated: tvSeries.4)
                // Dönüştürülen section verileri, output üzerinden dataSource event'i ile yayınlanır.
                self.output.send(.dataSource(section: sections))
            }).store(in: &cancellables)
    }
}

// MARK: - ActivityHandler

extension TvSeriesVMImpl {
    func activityHandler(input: AnyPublisher<TvSeriesVMInput, Never>) -> AnyPublisher<TvSeriesVMOutput, Never> {
        input.sink { [weak self] inputEvent in
            guard let self else { return }
            switch inputEvent {
            case .start(let categories, let page):
                self.fetchAllTvSeries(categories: categories, page: page)
            }
        }.store(in: &cancellables)
        // eraseToAnyPublisher(), output publisher'ının tipini soyutlar ve dış dünyaya tek tip bir publisher sunar.
        return output.eraseToAnyPublisher()
    }
}
