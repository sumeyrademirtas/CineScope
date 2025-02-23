//
//  MovieDetailsProvider.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/17/25.
//

import Combine
import Foundation
import UIKit

protocol MovieDetailsProvider: CollectionViewProvider where T == MovieDetails, I == IndexPath {
    func activityHandler(input: AnyPublisher<MovieDetailsProviderImpl.MovieDetailsProviderInput, Never>) -> AnyPublisher<MovieDetailsProviderImpl.MovieDetailsProviderOutput, Never>
}

final class MovieDetailsProviderImpl: NSObject, MovieDetailsProvider {
    typealias T = MovieDetails
    typealias I = IndexPath
    
    var dataList: [MovieDetails] = []
    var castList: [Cast] = [] // Yeni: Cast verilerini saklamak için
    var trailer: [MovieVideo] = []

    
    // binding
    private let output = PassthroughSubject<MovieDetailsProviderOutput, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    private weak var collectionView: UICollectionView?
    
    private var isLoading: Bool = false
}

// MARK: - EventType

extension MovieDetailsProviderImpl {
    enum MovieDetailsProviderOutput {
        // FIXME: -
        case didToggleFavorite(movieId: Int, isFavorite: Bool)
    }
    
    enum MovieDetailsProviderInput {
        case setupUI(collectionView: UICollectionView)
        case prepareCollectionView(data: [MovieDetails])
        case updateCast(cast: [Cast]) // Yeni: Cast verilerini güncellemek için
        case updateTrailer(video: [MovieVideo])

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
            case .updateCast(cast: let cast):
                self.updateCastList(cast: cast)

            case .updateTrailer(video: let video):
                self.updateTrailer(video: video)
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
               MovieDetailsContentCell.self,
               forCellWithReuseIdentifier: MovieDetailsContentCell.reuseIdentifier
           )
        // Yeni: MovieCastCell kaydı
        self.collectionView?.register(
            MovieCastCell.self,
            forCellWithReuseIdentifier: MovieCastCell.reuseIdentifier
        )

    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
           return 2 // Section 0: Film Detayları, Section 1: Cast
    }
    
    // Layout: Details cell height and Cast cell height can be adjusted accordingly.
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            return CGSize(width: collectionView.frame.width, height: 300)
        } else {
            // Cast cell
            return CGSize(width: collectionView.frame.width, height: 240)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            print("📢 Details Section Item Count: \(dataList.isEmpty ? 0 : 1)")
            return dataList.isEmpty ? 0 : 1
        } else {
            print("📢 Cast Section Item Count: \(castList.isEmpty ? 0 : 1)")
            return 1 // FIXME: ---
        }
    }
    
    // 🔹 Cell oluşturma - Şimdilik boş bırakıyorum çünkü detayları ileride dolduracağız.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            // Film Detayları Cell
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MovieDetailsContentCell.reuseIdentifier,
                for: indexPath
            ) as! MovieDetailsContentCell

            if let movieDetails = dataList.first {
                print("✅ Configuring Details Cell with: \(movieDetails.overview)")
                cell.configure(
                    with: movieDetails.overview,
                    genres: movieDetails.genres?.map { $0.name }.joined(separator: ", ") ?? "N/A",
                    posterURL: movieDetails.fullPosterURL,
                    voteAverage: movieDetails.voteAverage, // Eklenen parametre
                    releaseDate: movieDetails.releaseDate,
                    runtime: movieDetails.formattedRuntime
                )
            } else {
                print("⚠️ dataList.first() is empty!")
            }
            return cell
        } else {
            print("🔥 Cast cell for index \(indexPath.row)")

            // Cast Cell (MovieCastCell - container cell that holds horizontal collection view for cast photos)
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MovieCastCell.reuseIdentifier,
                for: indexPath
            ) as! MovieCastCell
            // Konfigürasyon: cell içerisinde castList'in tamamı gösterilecek
            cell.configure(with: castList)
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
        
        // Sadece section == 0 için header göster
        if indexPath.section == 0 {
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: MovieDetailsHeaderView.reuseIdentifier,
                for: indexPath
            ) as! MovieDetailsHeaderView
            
//            if let movieDetails = dataList.first {
//                header.configure(with: movieDetails.title, trailerVideoID: )
//            }
            if let movieDetails = dataList.first {
                // Trailer array'inde uygun trailer varsa, YouTube URL'sinin video ID'sini çıkarıyoruz.
                // Örneğin: "https://www.youtube.com/watch?v=Kp6WlyxBHBM" → "Kp6WlyxBHBM"
                let trailerVideoID = self.trailer.first?.youtubeURL?.absoluteString.components(separatedBy: "v=").last
                print("Header configuring with title: \(movieDetails.title) and trailer video ID: \(String(describing: trailerVideoID))")
                header.configure(with: movieDetails.title, trailerVideoID: trailerVideoID)
            }
            
            return header
        } else {
            // Diğer section'larda boş bir view döndür
            return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            // Yalnızca ilk section için header boyutu
            return CGSize(width: collectionView.frame.width, height: 260)
        } else {
            // Diğer section'larda header yok
            return .zero
        }
    }
    
    func reloadCollectionView() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView?.reloadData()
        }
    }
    
    func prepareCollectionView(data: [MovieDetails]) {
        dataList = data
        print("📢 CollectionView Güncelleniyor, Veri Sayısı: \(data.count)")
        reloadCollectionView()
    }
    
    // Yeni: Cast list güncelleme metodu
    func updateCastList(cast: [Cast]) {
        self.castList = cast
        print("Cast list updated with \(cast.count) items")
        reloadCollectionView()
    }
    
    // Yeni: Trailer güncelleme metodu
    func updateTrailer(video: [MovieVideo]) {
        self.trailer = video
        reloadCollectionView()
    }
    
    
}
