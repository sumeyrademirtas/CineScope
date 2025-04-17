//
//  CategoryListProvider.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 4/15/25.
//

import Foundation
import UIKit
import Combine

protocol CategoryListProvider: CollectionViewProvider where T == CategoryItem, I == IndexPath {
    func activityHandler(input: AnyPublisher<CategoryListProviderImpl.CategoryListProviderInput, Never>) -> AnyPublisher<CategoryListProviderImpl.CategoryListProviderOutput, Never>
}

final class CategoryListProviderImpl: NSObject, CategoryListProvider {

    
    typealias T = CategoryItem
    typealias I = IndexPath
    
    var dataList: [CategoryItem] = []
    
    // MARK: - Binding Properties
    private let output = PassthroughSubject<CategoryListProviderImpl.CategoryListProviderOutput, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    private weak var collectionView: UICollectionView?
}

extension CategoryListProviderImpl {
    enum CategoryListProviderOutput {
        case didSelect(category: CategoryItem)
    }
    
    enum CategoryListProviderInput {
        case setupUI(collectionView: UICollectionView)
        case prepareCollectionView(data: [CategoryItem])
    }
}

extension CategoryListProviderImpl {
    func activityHandler(input: AnyPublisher<CategoryListProviderInput, Never>) -> AnyPublisher<CategoryListProviderOutput, Never> {
        input.sink { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .setupUI(let collectionView):
                self.setupCollectionView(collectionView: collectionView)
            case .prepareCollectionView(let data):
                self.dataList = data
                self.reloadCollectionView()
            }
        }
        .store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
    
    func setupCollectionView(collectionView: UICollectionView) {
        self.collectionView = collectionView
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.reuseIdentifier)
    }
    
    func prepareCollectionView(data: [CategoryItem]) {
        self.dataList = data
        reloadCollectionView()
    }
    
    func reloadCollectionView() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView?.reloadData()
        }
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

extension CategoryListProviderImpl: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1  // Tüm kategoriler tek bir section altında listelenecek
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.reuseIdentifier, for: indexPath) as? CategoryCollectionViewCell else {
            fatalError("Unable to dequeue CategoryCollectionViewCell")
        }
        let category = dataList[indexPath.row]
        cell.configure(with: category)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = dataList[indexPath.row]
        output.send(.didSelect(category: category))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // İki sütunlu grid düzeni için hesaplama:
        let totalSpacing: CGFloat = 10 * 3  // sol, sağ ve aradaki boşluklar
        let width = (collectionView.bounds.width - totalSpacing) / 2
        return CGSize(width: width, height: width * 1.2)
    }
}
