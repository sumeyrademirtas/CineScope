//
//  TvSeriesDetailsProvider.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 3/4/25.
//

import Combine
import Foundation
import UIKit

protocol TvSeriesDetailsProvider: CollectionViewProvider where T == TvSeriesDetailsVMImpl.SectionType, I == IndexPath {
    func activityHandler(input: AnyPublisher<TvSeriesDetailsProviderImpl.TvSeriesDetailsProviderInput, Never>) -> AnyPublisher<TvSeriesDetailsProviderImpl.TvSeriesDetailsProviderOutput, Never>
}

final class TvSeriesDetailsProviderImpl: NSObject, TvSeriesDetailsProvider {
    typealias T = TvSeriesDetailsVMImpl.SectionType
    typealias I = IndexPath
    var dataList: [TvSeriesDetailsVMImpl.SectionType] = []

    // binding
    private let output = PassthroughSubject<TvSeriesDetailsProviderOutput, Never>()
    private var cancellables = Set<AnyCancellable>()

    private weak var collectionView: UICollectionView?

    private var isLoading: Bool = false
}

// MARK: - EventType

extension TvSeriesDetailsProviderImpl {
    enum TvSeriesDetailsProviderInput {
        case setupUI(collectionView: UICollectionView)
        case prepareCollectionView(data: [TvSeriesDetailsVMImpl.SectionType])
    }

    enum TvSeriesDetailsProviderOutput {
        case didToggleFavorite(tvSeriesId: Int, isFavorite: Bool)
        case didSelectCast(castId: Int)
    }
}

// MARK: - Binding

extension TvSeriesDetailsProviderImpl {
    func activityHandler(input: AnyPublisher<TvSeriesDetailsProviderImpl.TvSeriesDetailsProviderInput, Never>) -> AnyPublisher<TvSeriesDetailsProviderImpl.TvSeriesDetailsProviderOutput, Never> {
        input.sink { [weak self] eventType in
            guard let self = self else { return }
            switch eventType {
            case .setupUI(let collectionView):
                self.setupCollectionView(collectionView: collectionView)
            case .prepareCollectionView(let data):
                self.prepareCollectionView(data: data)
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
}

// MARK: - CollectionView Setup and Delegation

extension TvSeriesDetailsProviderImpl: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // Setup methods
    func setupCollectionView(collectionView: UICollectionView) {
        self.collectionView = collectionView
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        self.collectionView?.register(
            TvSeriesDetailsHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TvSeriesDetailsHeaderView.reuseIdentifier
        )
        self.collectionView?.register(
            TrailerViewCell.self,
            forCellWithReuseIdentifier: TrailerViewCell.reuseIdentifier
        )
        self.collectionView?.register(
            TvSeriesDetailsContentCell.self,
            forCellWithReuseIdentifier: TvSeriesDetailsContentCell.reuseIdentifier
        )
        self.collectionView?.register(
            TvSeriesCastCell.self,
            forCellWithReuseIdentifier: TvSeriesCastCell.reuseIdentifier
        )
        print("TvSeries CollectionView setup completed.")
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataList.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = collectionView.frame.width

        let height: CGFloat
        switch indexPath.section {
        case 0:
            height = 240
        case 1:
            height = 300
        case 2:
            height = 240
        default:
            height = 240 // Varsayılan değer
        }
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = dataList[indexPath.section]
        switch section {
        case .video(let rows):
            guard let row = rows.first, case .tvSeriesVideo(let videos) = row else {
                fatalError("No video available")
            }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrailerViewCell.reuseIdentifier, for: indexPath) as! TrailerViewCell

            // Örnek: Sadece ilk videoyu oynatmak istiyorsanız:
            if let firstVideo = videos.first {
                cell.loadYouTubeVideo(videoID: firstVideo.key)
            }

            return cell
        case .info(let rows):
            guard let row = rows.first, case .tvSeriesInfo(let tvSeries) = row else {
                fatalError("No tvSeries info available")
            }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TvSeriesDetailsContentCell.reuseIdentifier, for: indexPath) as! TvSeriesDetailsContentCell
            cell.configure(with: tvSeries)
            return cell
        case .cast(let rows):
            guard let row = rows.first, case .tvSeriesCast(let cast) = row else {
                fatalError("No cast available")
            }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TvSeriesCastCell.reuseIdentifier, for: indexPath) as! TvSeriesCastCell
            cell.configure(with: cast)
            cell.onCastSelected = { [weak self] castId in
                print("Cast with ID \(castId) selected from tvSeries cast.")
                self?.output.send(.didSelectCast(castId: castId))
            }
            return cell
        }
    }
    
    // 🔹 Header'ı göstermek için eklenmesi gereken method
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        // Sadece section == 0 için header göstermek istiyorsanız
        if indexPath.section == 0 {
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: TvSeriesDetailsHeaderView.reuseIdentifier,
                for: indexPath
            ) as! TvSeriesDetailsHeaderView
            
            // 1) dataList içinde .info section'ı bul
            if let infoSection = dataList.first(where: {
                if case .info = $0 { return true }
                return false
            }) {
                // 2) O section'ın row'larını al
                switch infoSection {
                case .info(let rows):
                    // 3) rows.first -> .movieInfo(let movie) mi?
                    if let firstRow = rows.first,
                       case .tvSeriesInfo(let tvSeries) = firstRow {
                        // 4) Başlığı header'a set et
                        header.configure(with: tvSeries.name!)
                    }
                default:
                    break
                }
            }
            
            return header
        } else {
            // Diğer section'larda boş bir view döndür
            return UICollectionReusableView()
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        if section == 0 {
            // Yalnızca ilk section için header boyutu
            return CGSize(width: collectionView.frame.width, height: 60)
        } else {
            // Diğer section'larda header yok
            return .zero
        }
    }
}


extension TvSeriesDetailsProviderImpl {
    func prepareCollectionView(data: [TvSeriesDetailsVMImpl.SectionType]) {
        dataList = data
        print("📢 CollectionView Güncelleniyor, Veri Sayısı: \(data.count)")
        reloadCollectionView()
    }
    
    func reloadCollectionView() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView?.reloadData()
        }
    }
}
