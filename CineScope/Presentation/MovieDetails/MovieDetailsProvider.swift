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
               MovieDetailsContentCell.self,
               forCellWithReuseIdentifier: MovieDetailsContentCell.reuseIdentifier
           )

    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 250)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("📢 CollectionView Item Count: \(dataList.count)")
        return dataList.isEmpty ? 0 : 1
    }
    
    // 🔹 Cell oluşturma - Şimdilik boş bırakıyorum çünkü detayları ileride dolduracağız.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MovieDetailsContentCell.reuseIdentifier,
            for: indexPath
        ) as! MovieDetailsContentCell

        if let movieDetails = dataList.first {
            print("✅ Hücreye Veri Gönderiliyor: \(movieDetails.overview)")
            cell.configure(
                with: movieDetails.overview,
                genres: movieDetails.genres?.map { $0.name }.joined(separator: ", ") ?? "N/A",
                posterURL: movieDetails.fullPosterURL
            )
        } else {
            print("⚠️ dataList.first() boş!")
        }
        
        return cell
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
        
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: MovieDetailsHeaderView.reuseIdentifier,
            for: indexPath
        ) as! MovieDetailsHeaderView
        
        if let movieDetails = dataList.first {
            header.configure(with: movieDetails.title) // Başlığı header'a gönderiyoruz
        }
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 250) // 🔹 Header için 300px yükseklik verdik.
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
}
