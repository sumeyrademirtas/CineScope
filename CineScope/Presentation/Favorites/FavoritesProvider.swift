//
//  FavoritesProvider.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 3/15/25.
//


import UIKit
import Combine

protocol FavoritesProvider: CollectionViewProvider where T == FavoriteItem, I == IndexPath {
    func activityHandler(input: AnyPublisher<FavoritesProviderImpl.Input, Never>) -> AnyPublisher<FavoritesProviderImpl.Output, Never>
}

final class FavoritesProviderImpl: NSObject, FavoritesProvider {

    
    typealias T = FavoriteItem
    typealias I = IndexPath
    
    var dataList: [FavoriteItem] = []
    
    private let output = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()
    private weak var collectionView: UICollectionView?
    
    // MARK: - Input & Output Enums
    enum Input {
        case setupUI(collectionView: UICollectionView)
        case reloadData(favorites: [FavoriteItem])
    }
    
    enum Output {
        case didSelectFavoriteItem(FavoriteItem)
    }
    
    // MARK: - Activity Handler
    func activityHandler(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        print("🚀 Provider activityHandler ÇALIŞTI!") // ✅ Görünüyor

        input.sink { [weak self] inputEvent in
            guard let self = self else { return }

            switch inputEvent {
            case .setupUI(let collectionView):
                print("🛠️ CollectionView kuruluyor...")
                self.setupCollectionView(collectionView: collectionView)

            case .reloadData(let favorites):
                print("🔄 Provider'a gelen favori verileri: \(favorites.count) adet")

                self.dataList = favorites
                print("🔢 CollectionView Item Count: \(dataList.count)")

                DispatchQueue.main.async {
                    if let cv = self.collectionView {
                        print("✅ CollectionView bulundu! Yenileniyor...")
                        cv.reloadData()
                        print("✅ CollectionView reloadData() çağrıldı!")
                    } else {
                        print("🚨 CollectionView bulunamadı! Yenileme başarısız.")
                    }
                }
        }
        }.store(in: &cancellables)

        return output.eraseToAnyPublisher()
    }
    
    // MARK: - CollectionView Setup
    func setupCollectionView(collectionView: UICollectionView) {
        print("✅ CollectionView başarıyla ayarlandı!")
        self.collectionView = collectionView
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(FavoritePosterCell.self, forCellWithReuseIdentifier: FavoritePosterCell.reuseIdentifier)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate
extension FavoritesProviderImpl: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
        
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("🔢 CollectionView Item Count: \(dataList.count)")
        return dataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FavoritePosterCell.reuseIdentifier, for: indexPath) as! FavoritePosterCell
        let item = dataList[indexPath.item]
        print("🖼️ Poster Yükleniyor: ID: \(item.id), URL: \(item.posterURL ?? "N/A")")
        cell.configure(with: item.posterURL)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedItem = dataList[indexPath.item]
        output.send(.didSelectFavoriteItem(selectedItem))
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalSpacing: CGFloat = 10 * 2 // minimumInteritemSpacing * (columns - 1) (örneğin 2)
        let availableWidth = collectionView.frame.width - totalSpacing
        let cellWidth = availableWidth / 3
        let cellHeight = cellWidth * 1.5
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    
}

extension FavoritesProviderImpl {
    func prepareCollectionView(data: [FavoriteItem]) {
        self.dataList = data
        reloadCollectionView()
    }
    
    func reloadCollectionView() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            print("🔄 CollectionView Yenileniyor, Toplam Favori: \(self.dataList.count)")
            self.collectionView?.reloadData()
        }
    }
}
