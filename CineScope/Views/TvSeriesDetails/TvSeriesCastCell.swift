//
//  TvSeriesCastCell.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 3/4/25.
//

import UIKit

class TvSeriesCastCell: UICollectionViewCell {
    static let reuseIdentifier = "TvSeriesCastCell"

    private var castList: [TvSeriesCast] = []
    
    // "Top Cast" başlığı için label
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Top Cast"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //Clousure to notify selection events
    var onCastSelected: ((Int) -> Void)?


    private let horizontalCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        layout.itemSize = CGSize(width: 140, height: 200) // Cast cell size
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear // Make sure it's clear
        return collectionView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
//        contentView.backgroundColor = .purple
        contentView.backgroundColor = UIColor(hue: 0.65, saturation: 0.27, brightness: 0.18, alpha: 1.00) // Debug
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(horizontalCollectionView)
        horizontalCollectionView.delegate = self
        horizontalCollectionView.dataSource = self
        horizontalCollectionView.register(
            TvSeriesCastPhotoCell.self,
            forCellWithReuseIdentifier: TvSeriesCastPhotoCell.reuseIdentifier
        )

        NSLayoutConstraint.activate([
            // Title Label konumu
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Collection View konumu
            horizontalCollectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            horizontalCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            horizontalCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            horizontalCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    func configure(with cast: [TvSeriesCast]) {
        self.castList = cast
        horizontalCollectionView.reloadData()
    }
}

extension TvSeriesCastCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return castList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TvSeriesCastPhotoCell.reuseIdentifier,
            for: indexPath
        ) as? TvSeriesCastPhotoCell else {
            fatalError("Unable to dequeue TvSeriesCastPhotoCell")
        }
        cell.configure(with: castList[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCast = castList[indexPath.item]
        print("Inner Cell Tıklandı: \(selectedCast.name ?? "Unknown") - ID: \(String(describing: selectedCast.id))")
        onCastSelected?(selectedCast.id!)
    }
}
