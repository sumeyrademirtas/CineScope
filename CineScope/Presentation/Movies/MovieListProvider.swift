//
//  MovieListProvider.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/5/25.
//

import Foundation
import Combine
import UIKit

protocol MovieListProvider : CollectionViewProvider where T == MovieVMImpl.SectionType, I == IndexPath {
    func activityHandler(input: AnyPublisher<MovieListProviderImpl.MovieListProviderInput, Never>) -> AnyPublisher<MovieListProviderImpl.MovieListProviderOutput, Never>
}

final class MovieListProviderImpl: NSObject, MovieListProvider {
    
    typealias T = MovieVMImpl.SectionType
    typealias I = IndexPath
    var dataList: [MovieVMImpl.SectionType] = []
//    var titleDataList: [MovieVMImpl.TitleSectionType] = [] // MARK: Ben bu sekilde yapmadigim icin burayi yorum satirina aldim. title isini farkli sekilde halletmistim. Bunun uzerinde biraz dursam iyi olur.
    
    // Binding
    private let output = PassthroughSubject<MovieListProviderOutput, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    private weak var collectionView: UICollectionView?
    private var isLoading: Bool = false
}

// MARK: - EventType
extension MovieListProviderImpl {
    
    enum MovieListProviderOutput {
        case didSelect(indexPath: IndexPath)
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
                self?.collectionView = collectionView
            case .prepareCollectionView(let data):
                self?.prepareCollectionView(data: data)
            }
        }.store(in: &self.cancellables)
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
        //header icin
        self.collectionView?.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "DefaultHeaderView")
    }
    
    /// Header View - Section Title Settings
    // MARK: - Mahsuna sor. Bunu burada yapmamizin bir sakincasi var mi?
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            fatalError("Unsupported kind: \(kind)")
        }
        
        let header = collectionView
            .dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "DefaultHeaderView", for: indexPath)
        
        // Eski subviewlar temizleniyor.
        header.subviews.forEach {
            $0.removeFromSuperview()
        }
        
        let category = MovieCategory.orderedCategories[indexPath.section]
        
        let titleLabel = UILabel(frame: CGRect(x:16, y:0, width: collectionView.frame.width - 32, height: 30))
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
    
    // Hucreyi olusturup yapilandiriyoruz
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell =
                collectionView.dequeueReusableCell(withReuseIdentifier: MovieSectionViewCell.reuseIdentifier, for: indexPath) as? MovieSectionViewCell else {
            fatalError("Unable to dequeue MovieSectionViewCell")
        }
        let section = dataList[indexPath.section]
        switch section {
        case .popular(rows: let rows):
            let row = rows[indexPath.row]
            switch row {
            case .movie(let movie):
                cell.setUpDataList(movie: movie)
            }
        case .upcoming(rows: let rows):
            let row = rows[indexPath.row]
            switch row {
            case .movie(let movie):
                cell.setUpDataList(movie: movie)
            }
        case .nowPlaying(rows: let rows):
            let row = rows[indexPath.row]
            switch row {
            case .movie(let movie):
                cell.setUpDataList(movie: movie)
            }
        case .topRated(rows: let rows):
            let row = rows[indexPath.row]
            switch row {
            case .movie(let movie):
                cell.setUpDataList(movie: movie)
            }
        }
        return cell
    }
    
    // MARK: Mahsuna sor. PrefetchItems icin func ayarlamadim. Onceligi yok gibi su anlik.
//    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
//        <#code#>
//    }
    
    func reloadCollectionView() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView?.reloadData()
        }
    }
    
    func prepareCollectionView(data: [MovieVMImpl.SectionType]) {
        self.dataList = data
        reloadCollectionView()
    }
    
}
