//
//  MovieListProvider.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/5/25.
//

import Combine
import Foundation
import UIKit

protocol MovieListProvider: CollectionViewProvider where T == MovieVMImpl.SectionType, I == IndexPath {
    func activityHandler(input: AnyPublisher<MovieListProviderImpl.MovieListProviderInput, Never>) -> AnyPublisher<MovieListProviderImpl.MovieListProviderOutput, Never>
}

final class MovieListProviderImpl: NSObject, MovieListProvider {
    typealias T = MovieVMImpl.SectionType
    typealias I = IndexPath
    var dataList: [MovieVMImpl.SectionType] = []
    
    // Binding
    private let output = PassthroughSubject<MovieListProviderOutput, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    private weak var collectionView: UICollectionView?
    private var isLoading: Bool = false
}

// MARK: - EventType

extension MovieListProviderImpl {
    enum MovieListProviderOutput {
        case didSelectMovie(movieId: Int)
    }
    
    enum MovieListProviderInput {
        case setupUI(collectionView: UICollectionView)
        case prepareCollectionView(data: [MovieVMImpl.SectionType])
    }
}

// MARK: - Binding

extension MovieListProviderImpl {
    func activityHandler(input: AnyPublisher<MovieListProviderInput, Never>) -> AnyPublisher<MovieListProviderOutput, Never> {
        input.sink { [weak self] eventType in
            switch eventType {
            case .setupUI(let collectionView):
                self?.setupCollectionView(collectionView: collectionView)
            case .prepareCollectionView(let data):
                self?.prepareCollectionView(data: data)
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
}

// MARK: - CollectionView Setup and Delegation

extension MovieListProviderImpl: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func setupCollectionView(collectionView: UICollectionView) {
        self.collectionView = collectionView
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        self.collectionView?.register(MovieSectionViewCell.self, forCellWithReuseIdentifier: MovieSectionViewCell.reuseIdentifier)
        self.collectionView?.register(FeaturedSectionViewCell.self, forCellWithReuseIdentifier: FeaturedSectionViewCell.reuseIdentifier)
        
        // header
        self.collectionView?.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "DefaultHeaderView")
        
        print("✅ CollectionView setup tamamlandı!")
    }
    
    /// Header View - Section Title Settings
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            fatalError("Unsupported kind: \(kind)")
        }
        
        let header = collectionView
            .dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "DefaultHeaderView", for: indexPath)
        
        // Eski subviewlar temizleniyor.
        for subview in header.subviews {
            subview.removeFromSuperview()
        }
        
        let category = MovieCategory.orderedCategories[indexPath.section]
        
        let titleLabel = UILabel(frame: CGRect(x: 16, y: 0, width: collectionView.frame.width - 32, height: 30))
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
        titleLabel.textColor = .white
        titleLabel.text = category.displayName
        header.addSubview(titleLabel)
        
        return header
    }
    
    /// Header boyutlari
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 30)
    }
    
    /// Section sayisi
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1 // Her Section bir adet MovieSectionCell icerecek
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let height: CGFloat = indexPath.section == 0 ? 400 : 200
        return CGSize(width: collectionView.frame.width, height: height)
    }
    
    /// Section kenar boşlukları
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10) // Sol ve sağ boşluk
    }
    
    /// Satır arası boşluk
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 0 // Satırlar arası boşluk
    }
    
    /// Hücreler arası boşluk
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 0 // Hücreler arası boşluk.
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = dataList[indexPath.section]
        
        switch section {
        case .trending(let rows):
            // Featured section için FeaturedSectionViewCell kullanılıyor
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeaturedSectionViewCell.reuseIdentifier, for: indexPath) as? FeaturedSectionViewCell else {
                fatalError("Unable to dequeue FeaturedSectionViewCell")
            }
            let row = rows[indexPath.row]
            switch row {
            case .movie(let movies):
                cell.setUpDataList(movie: movies)
                cell.onMovieSelected = { [weak self] selectedMovie in
                    print("Delegated Selected Movie: \(selectedMovie.title), ID: \(selectedMovie.id)")
                    self?.output.send(.didSelectMovie(movieId: selectedMovie.id))
                }
            }
            return cell
            
        case .popular(let rows),
             .upcoming(let rows),
             .nowPlaying(let rows),
             .topRated(let rows):
            // Diğer sectionlar için MovieSectionViewCell kullanılıyor
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieSectionViewCell.reuseIdentifier, for: indexPath) as? MovieSectionViewCell else {
                fatalError("Unable to dequeue MovieSectionViewCell")
            }
            let row = rows[indexPath.row]
            switch row {
            case .movie(let movies):
                cell.setUpDataList(movie: movies)
                cell.onMovieSelected = { [weak self] selectedMovie in
                    print("Delegated Selected Movie: \(selectedMovie.title), ID: \(selectedMovie.id)")
                    self?.output.send(.didSelectMovie(movieId: selectedMovie.id))
                }
            }
            return cell
        }
    }

    private func navigateToMovieDetails(movie: Movie) {
        let movieDetailsVC = MovieDetailsBuilderImpl().build(movieId: movie.id)
        movieDetailsVC.modalPresentationStyle = .fullScreen
        movieDetailsVC.modalTransitionStyle = .crossDissolve
        
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first,
           let rootVC = window.rootViewController
        {
            rootVC.present(movieDetailsVC, animated: true)
        }
    }
    
    func reloadCollectionView() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView?.reloadData()
        }
    }
    
    func prepareCollectionView(data: [MovieVMImpl.SectionType]) {
        dataList = data
        reloadCollectionView()
    }
}
