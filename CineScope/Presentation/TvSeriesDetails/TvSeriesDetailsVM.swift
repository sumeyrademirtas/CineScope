//
//  TvSeriesDetailsVM.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 3/4/25.
//

import Combine
import Foundation

// MARK: - Protocol Definition

protocol TvSeriesDetailsVM {
    func activityHandler(input: AnyPublisher<TvSeriesDetailsVMImpl.TvSeriesDetailsVMInput, Never>) -> AnyPublisher<TvSeriesDetailsVMImpl.TvSeriesDetailsVMOutput, Never>
}

final class TvSeriesDetailsVMImpl: TvSeriesDetailsVM {
    // Combine properties
    private let output = PassthroughSubject<TvSeriesDetailsVMOutput, Never>()
    private var cancellables = Set<AnyCancellable>()

    // UseCases
    private var tvSeriesDetailsUseCase: TvSeriesDetailsUseCase?
    private var tvSeriesCreditsUseCase: TvSeriesCreditsUseCase?
    private var tvSeriesVideosUseCase: TvSeriesVideoUseCase?

    init(tvSeriesDetailsUseCase: TvSeriesDetailsUseCase, tvSeriesCreditsUseCase: TvSeriesCreditsUseCase, tvSeriesVideosUseCase: TvSeriesVideoUseCase) {
        self.tvSeriesDetailsUseCase = tvSeriesDetailsUseCase
        self.tvSeriesCreditsUseCase = tvSeriesCreditsUseCase
        self.tvSeriesVideosUseCase = tvSeriesVideosUseCase
    }

    // Data storage
    private var tvSeriesDetails: TvSeriesDetails?
    private var tvSeriesCredits: TvSeriesCredits?
    private var tvSeriesVideos: TvSeriesVideosResponse?
    private var bestTrailer: TvSeriesVideo?
}

// MARK: - Events

extension TvSeriesDetailsVMImpl {
    enum TvSeriesDetailsVMInput {
        case fetchTvSeriesDetails(tvSeriesId: Int)
        case fetchTvSeriesCredits(tvSeriesId: Int)
        case fetchTvSeriesVideos(tvSeriesId: Int)
    }

    enum TvSeriesDetailsVMOutput {
        case isLoading(Bool)
        case dataSource(section: [SectionType])
        case errorOccurred(String)
    }

    enum SectionType {
        case video(rows: [RowType])
        case info(rows: [RowType])
        case cast(rows: [RowType])
    }

    enum RowType {
        case tvSeriesVideo(video: [TvSeriesVideo])
        case tvSeriesInfo(info: TvSeriesDetails)
        case tvSeriesCast(cast: [TvSeriesCast])
    }
}

// MARK: - Prepare UI

extension TvSeriesDetailsVMImpl {
    private func updateUI(tvSeriesVideo: [TvSeriesVideo]?, tvSeriesInfo: TvSeriesDetails?, tvSeriesCast: TvSeriesCredits?) -> [SectionType] {
        var sections = [SectionType]()
        var videoRowType = [RowType]()
        var infoRowType = [RowType]()
        var castRowType = [RowType]()

        if let tvSeriesVideo = tvSeriesVideo {
            videoRowType.append(.tvSeriesVideo(video: tvSeriesVideo))
            sections.append(.video(rows: videoRowType))
        }

        if let tvSeriesInfo = tvSeriesInfo {
            infoRowType.append(.tvSeriesInfo(info: tvSeriesInfo))
            sections.append(.info(rows: infoRowType))
        }

        if let tvSeriesCast = tvSeriesCast?.cast {
            castRowType.append(.tvSeriesCast(cast: tvSeriesCast))
            sections.append(.cast(rows: castRowType))
        }

        return sections
    }
}

// MARK: - Service call

extension TvSeriesDetailsVMImpl {
    private func fetchTvSeriesDetails(tvSeriesId: Int) {
        print("Fetch TvSeries Details API request started")
        self.output.send(.isLoading(true))

        self.tvSeriesDetailsUseCase?.fetchTvSeriesDetails(tvSeriesId: tvSeriesId)?
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                self.output.send(.isLoading(false))
                if case .failure(let error) = completion {
                    print("⚠️ FetchTvseriesDetails API Error: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] response in
                guard let self else { return }
                if let tvSeriesDetails = response {
                    print("Tv Series Details \(tvSeriesDetails)")
                    self.tvSeriesDetails = tvSeriesDetails
                    self.updateSections()
                } else {
                    self.output.send(.errorOccurred("No tv series details found"))
                }
            }).store(in: &self.cancellables)
    }

    private func fetchTvCredits(tvSeriesId: Int) {
        print("🎭 Fetch TvSeries Credits API çağrısı başlatıldı! tvSeriesId: \(tvSeriesId)")
        self.output.send(.isLoading(true))

        self.tvSeriesCreditsUseCase?.fetchTvSeriesCredits(tvSeriesId: tvSeriesId)?
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                self.output.send(.isLoading(false))
                if case .failure(let error) = completion {
                    print("⚠️ FetchTvSeriesCredits API Hatası: \(error.localizedDescription)")
                    self.output.send(.errorOccurred("Oyuncu bilgileri yüklenirken hata oluştu."))
                }
            }, receiveValue: { [weak self] response in
                guard let self = self else { return }
                if let tvSeriesCredits = response {
                    print("Fetched credits: \(tvSeriesCredits.cast.count) cast members")
                    self.tvSeriesCredits = tvSeriesCredits
                    self.updateSections()
                } else {
                    self.output.send(.errorOccurred("No details found"))
                }
            }).store(in: &self.cancellables)
    }

    private func fetchTvSeriesVideos(tvSeriesId: Int) {
        print("Fetch TvSeries Video Api cagrisi baslatildi. tvSeriesId: \(tvSeriesId)")
        self.output.send(.isLoading(true))

        self.tvSeriesVideosUseCase?.fetchTvSeriesVideos(tvSeriesId: tvSeriesId)?
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                self.output.send(.isLoading(false))
                if case .failure(let error) = completion {
                    print("FetchTvSeriesVideos Api hatasi: \(error.localizedDescription)")
                    self.output.send(.errorOccurred("Video yuklenirken hata olustu"))
                }
            }, receiveValue: { [weak self] singleTrailer in
                guard let self = self else { return }
                if let trailer = singleTrailer,
                   let url = trailer.youtubeURL
                {
                    print("Best trailer YouTube URL: \(url.absoluteString)")
                    self.bestTrailer = trailer
                    self.updateSections()
                } else {
                    print("No valid trailer found")
                    self.output.send(.errorOccurred("No valid trailer found"))
                }
            }).store(in: &self.cancellables)
    }
}

// MARK: - Update Sections

extension TvSeriesDetailsVMImpl {
    private func updateSections() {
        let bestTrailerArray: [TvSeriesVideo]? = self.bestTrailer.map { [$0] }
        let sections = self.updateUI(tvSeriesVideo: bestTrailerArray, tvSeriesInfo: self.tvSeriesDetails, tvSeriesCast: self.tvSeriesCredits)
        self.output.send(.dataSource(section: sections))
    }
}

// MARK: - Activity Handler

extension TvSeriesDetailsVMImpl {
    func activityHandler(input: AnyPublisher<TvSeriesDetailsVMInput, Never>) -> AnyPublisher<TvSeriesDetailsVMOutput, Never> {
        input.sink { [weak self] inputEvent in
            guard let self = self else { return }
            switch inputEvent {
            case .fetchTvSeriesDetails(let tvSeriesId):
                self.fetchTvSeriesDetails(tvSeriesId: tvSeriesId)
            case .fetchTvSeriesCredits(let tvSeriesId):
                self.fetchTvCredits(tvSeriesId: tvSeriesId)
            case .fetchTvSeriesVideos(let tvSeriesId):
                self.fetchTvSeriesVideos(tvSeriesId: tvSeriesId)
            }
        }.store(in: &self.cancellables)
        return self.output.eraseToAnyPublisher()
    }
}
