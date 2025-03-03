//
//  MovieDetailsProvider.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/17/25.
//

import Combine
import Foundation
import UIKit

protocol MovieDetailsProvider: CollectionViewProvider where T == MovieDetailsVMImpl.SectionType, I == IndexPath {
    func activityHandler(input: AnyPublisher<MovieDetailsProviderImpl.MovieDetailsProviderInput, Never>) -> AnyPublisher<MovieDetailsProviderImpl.MovieDetailsProviderOutput, Never>
}

final class MovieDetailsProviderImpl: NSObject, MovieDetailsProvider {
    typealias T = MovieDetailsVMImpl.SectionType
    typealias I = IndexPath
    var dataList: [MovieDetailsVMImpl.SectionType] = []
    
    // binding
    private let output = PassthroughSubject<MovieDetailsProviderOutput, Never>()
    
    private var cancellables = Set<AnyCancellable>()
    
    private weak var collectionView: UICollectionView?
    
    private var isLoading: Bool = false
}

// MARK: - EventType

extension MovieDetailsProviderImpl {
    enum MovieDetailsProviderInput {
        case setupUI(collectionView: UICollectionView)
        case prepareCollectionView(data: [MovieDetailsVMImpl.SectionType])
    }
    
    enum MovieDetailsProviderOutput {
        // FIXME: -
        case didToggleFavorite(movieId: Int, isFavorite: Bool)
        case didSelectCast(castId: Int)
    }
}

// MARK: - Binding

extension MovieDetailsProviderImpl {
    func activityHandler(input: AnyPublisher<MovieDetailsProviderImpl.MovieDetailsProviderInput, Never>) -> AnyPublisher<MovieDetailsProviderImpl.MovieDetailsProviderOutput, Never> {
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

extension MovieDetailsProviderImpl: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // Setup Methods
    func setupCollectionView(collectionView: UICollectionView) {
        self.collectionView = collectionView
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        self.collectionView?.register(
            MovieDetailsHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: MovieDetailsHeaderView.reuseIdentifier
        )
        self.collectionView?.register(
            TrailerViewCell.self,
            forCellWithReuseIdentifier: TrailerViewCell.reuseIdentifier
        )
        self.collectionView?.register(
            MovieDetailsContentCell.self,
            forCellWithReuseIdentifier: MovieDetailsContentCell.reuseIdentifier
        )
        self.collectionView?.register(
            MovieCastCell.self,
            forCellWithReuseIdentifier: MovieCastCell.reuseIdentifier
        )
        print("MovieDetail CollectionView setup completed.")
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
            guard let row = rows.first, case .movieVideo(let videos) = row else {
                fatalError("No video available")
            }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrailerViewCell.reuseIdentifier, for: indexPath) as! TrailerViewCell
            
            // Örnek: Sadece ilk videoyu oynatmak istiyorsanız:
            if let firstVideo = videos.first {
                cell.loadYouTubeVideo(videoID: firstVideo.key)
            }
            
            return cell
        case .info(let rows):
            guard let row = rows.first, case .movieInfo(let movie) = row else {
                fatalError("No movie info available")
            }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieDetailsContentCell.reuseIdentifier, for: indexPath) as! MovieDetailsContentCell
            cell.configure(with: movie)
            return cell
        case .cast(let rows):
            guard let row = rows.first, case .movieCast(let cast) = row else {
                fatalError("No cast available")
            }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCastCell.reuseIdentifier, for: indexPath) as! MovieCastCell
            cell.configure(with: cast)
            cell.onCastSelected = { [weak self] castId in
                print("Cast with ID \(castId) selected from movies cast.")
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
                withReuseIdentifier: MovieDetailsHeaderView.reuseIdentifier,
                for: indexPath
            ) as! MovieDetailsHeaderView
            
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
                       case .movieInfo(let movie) = firstRow {
                        // 4) Başlığı header'a set et
                        header.configure(with: movie.title)
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
            return CGSize(width: collectionView.frame.width, height: 50)
        } else {
            // Diğer section'larda header yok
            return .zero
        }
    }
}

extension MovieDetailsProviderImpl {
    func prepareCollectionView(data: [MovieDetailsVMImpl.SectionType]) {
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
