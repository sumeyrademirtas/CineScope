//
//  TvSeriesListProvider.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/10/25.
//

import Foundation
import Combine
import UIKit

protocol TvSeriesListProvider: CollectionViewProvider where T == TvSeriesVMImpl.SectionType, I == IndexPath {
    func activityHandler(input: AnyPublisher<TvSeriesListProviderImpl.TvSeriesListProviderInput, Never>) -> AnyPublisher<TvSeriesListProviderImpl.TvSeriesListProviderOutput, Never>
}

final class TvSeriesListProviderImpl: NSObject, TvSeriesListProvider {
    
    typealias T = TvSeriesVMImpl.SectionType
    typealias I = IndexPath
    var dataList: [TvSeriesVMImpl.SectionType] = []
    
    
    //Binding
    private let output = PassthroughSubject<TvSeriesListProviderOutput, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    private weak var collectionView: UICollectionView?
    private var isLoadnig: Bool = false
}

extension TvSeriesListProviderImpl {
    
    enum TvSeriesListProviderOutput {
        case didSelectTvSeries(tvSeries: Int)
    }
    
    enum TvSeriesListProviderInput {
        case setupUI(collectionView: UICollectionView)
        case prepareCollectionView(data: [TvSeriesVMImpl.SectionType])
    }
}

// MARK: - Binding
extension TvSeriesListProviderImpl {
    
    func activityHandler(input: AnyPublisher<TvSeriesListProviderInput, Never>) -> AnyPublisher<TvSeriesListProviderOutput, Never> {
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
extension TvSeriesListProviderImpl: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func setupCollectionView(collectionView: UICollectionView) {
        self.collectionView = collectionView
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        self.collectionView?.register(TvSeriesSectionViewCell.self, forCellWithReuseIdentifier: TvSeriesSectionViewCell.reuseIdentifier)
        //header icin
        self.collectionView?.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "DefaultHeaderView")
    }
    
    /// Header View - Section Title Settings
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
        
        let category = TvSeriesCategory.orderedCategories[indexPath.section]
        
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
    
    /// Hücre boyutları
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 200) // Tüm genişlik + uygun yükseklik SECTION IN YUKSEKLIGI GENISLIGI BURASI.
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
    
    // Hucreyi olusturup yapilandiriyoruz
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell =
                collectionView.dequeueReusableCell(withReuseIdentifier: TvSeriesSectionViewCell.reuseIdentifier, for: indexPath) as? TvSeriesSectionViewCell else {
            fatalError("Unable to dequeue MovieSectionViewCell")
        }
        let section = dataList[indexPath.section]
        switch section {
        case .airingToday(rows: let rows):
            let row = rows[indexPath.row]
            switch row {
            case .tvSeries(let tvSeries):
                cell.setUpDataList(tvSeries: tvSeries)
                cell.onTvSeriesSelected = { [weak self] selectedTvSeries in
                    print("Delegated Selected TvSeries: \(selectedTvSeries.name), ID: \(selectedTvSeries.id)")
                    self?.output.send(.didSelectTvSeries(tvSeries: selectedTvSeries.id))
                }
            }
        case .onTheAir(rows: let rows):
            let row = rows[indexPath.row]
            switch row {
            case .tvSeries(let tvSeries):
                cell.setUpDataList(tvSeries: tvSeries)
                cell.onTvSeriesSelected = { [weak self] selectedTvSeries in
                    print("Delegated Selected TvSeries: \(selectedTvSeries.name), ID: \(selectedTvSeries.id)")
                    self?.output.send(.didSelectTvSeries(tvSeries: selectedTvSeries.id))
                }
            }
        case .popular(rows: let rows):
            let row = rows[indexPath.row]
            switch row {
            case .tvSeries(let tvSeries):
                cell.setUpDataList(tvSeries: tvSeries)
                cell.onTvSeriesSelected = { [weak self] selectedTvSeries in
                    print("Delegated Selected TvSeries: \(selectedTvSeries.name), ID: \(selectedTvSeries.id)")
                    self?.output.send(.didSelectTvSeries(tvSeries: selectedTvSeries.id))
                }
            }
        case .topRated(rows: let rows):
            let row = rows[indexPath.row]
            switch row {
            case .tvSeries(let tvSeries):
                cell.setUpDataList(tvSeries: tvSeries)
                cell.onTvSeriesSelected = { [weak self] selectedTvSeries in
                    print("Delegated Selected TvSeries: \(selectedTvSeries.name), ID: \(selectedTvSeries.id)")
                    self?.output.send(.didSelectTvSeries(tvSeries: selectedTvSeries.id))
                }
            }
        }
        return cell
    }
    
    
    func reloadCollectionView() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView?.reloadData()
        }
    }
    
    func prepareCollectionView(data: [TvSeriesVMImpl.SectionType]) {
        self.dataList = data
        reloadCollectionView()
    }
    
}
