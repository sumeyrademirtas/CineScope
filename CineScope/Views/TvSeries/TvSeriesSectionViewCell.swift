//
//  TvSeriesSectionViewCell.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/10/25.
//

import Foundation
import UIKit

class TvSeriesSectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "TvSeriesSectionViewCell"
    
    var tvSeries = [TvSeries]()
    func setUpDataList(tvSeries: [TvSeries]) {
        self.tvSeries = tvSeries
        innerCollectionView.reloadData()

    }
    
    private let innerCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.itemSize = CGSize(width: 120, height: 180) // Poster boyutlari
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    // Closure to notify selection events
    var onTvSeriesSelected: ((TvSeries) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(innerCollectionView)
        innerCollectionView.dataSource = self
        innerCollectionView.delegate = self
        innerCollectionView.register(TvSeriesPosterViewCell.self, forCellWithReuseIdentifier: TvSeriesPosterViewCell.reuseIdentifier)
//        innerCollectionView.backgroundColor = .gray
        innerCollectionView.backgroundColor = UIColor(hue: 0.65, saturation: 0.27, brightness: 0.18, alpha: 1.00)
        innerCollectionView.alwaysBounceHorizontal = true
        
        NSLayoutConstraint.activate([
            innerCollectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            innerCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            innerCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            innerCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        innerCollectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        tvSeries = []
        innerCollectionView.reloadData()
    }
}

extension TvSeriesSectionViewCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tvSeries.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell =
                collectionView.dequeueReusableCell(withReuseIdentifier: TvSeriesPosterViewCell.reuseIdentifier, for: indexPath) as? TvSeriesPosterViewCell else {
            fatalError("Unable to dequeue TvSeriesPosterViewCell")
        }
        cell.configure(with: tvSeries[indexPath.row])
        return cell
    }
    
    // MARK: Mahsuna sor. Provider icinde yapamadigim icin burada yaptim problem olur mu?
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedTvSeries = tvSeries[indexPath.row]
        onTvSeriesSelected?(selectedTvSeries)
    }
}
