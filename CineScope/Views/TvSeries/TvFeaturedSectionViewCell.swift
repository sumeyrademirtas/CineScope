//
//  FeaturedSectionViewCell.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 3/21/25.
//

import Foundation
import UIKit

class TvFeaturedSectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "TvFeaturedSectionViewCell"
    
    var tvSeries = [TvSeries]()

    private let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.hidesForSinglePage = true
        pc.currentPageIndicatorTintColor = .white
        pc.pageIndicatorTintColor = .lightGray
        pc.translatesAutoresizingMaskIntoConstraints = false
        return pc
    }()
    
    private let innerCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: 300, height: 500)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = .fast
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    // Closure to notify selection events
    var onTvSelected: ((TvSeries) -> Void)?
    
    func setUpDataList(tv: [TvSeries]) {
        tvSeries = tv
        pageControl.numberOfPages = tv.count
        pageControl.currentPage = 0
        innerCollectionView.reloadData()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(innerCollectionView)
        contentView.addSubview(pageControl)
        backgroundColor = UIColor.brandDarkBlue
        
        // Delegate & DataSource
        innerCollectionView.delegate = self
        innerCollectionView.dataSource = self
        
        // register
        innerCollectionView.register(
            FeaturedPosterViewCell.self,
            forCellWithReuseIdentifier: FeaturedPosterViewCell.reuseIdentifier
        )
        
        // Layout Constraints
        NSLayoutConstraint.activate([
            innerCollectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            innerCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            innerCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            innerCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
            
            pageControl.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        tvSeries = []
        innerCollectionView.reloadData()
    }
}

extension TvFeaturedSectionViewCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tvSeries.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell =
            collectionView.dequeueReusableCell(withReuseIdentifier: "FeaturedPosterViewCell", for: indexPath) as? FeaturedPosterViewCell
        else {
            fatalError("Unable to dequeue FeaturedPosterViewCell")
        }
        cell.configure(with: tvSeries[indexPath.row])
        return cell
    }
    
    // FIXME: Provider icinde yapamadigim icin burada yaptim problem olur mu?

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedTvSeries = tvSeries[indexPath.row]
        print("Inner Cell Tıklandı: \(selectedTvSeries.name) - ID: \(selectedTvSeries.id)")
        onTvSelected?(selectedTvSeries)
    }
}

extension TvFeaturedSectionViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        // Her sayfa, collectionView'in tamamını kaplayacak
        return collectionView.bounds.size
    }
}

extension TvFeaturedSectionViewCell: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Kullanıcının hangi sayfada olduğunu hesapla
        let pageWidth = scrollView.frame.size.width
        // +0.5 * pageWidth => en yakın sayfaya yaklaşma
        let currentPage = Int(scrollView.contentOffset.x + (0.5 * pageWidth)) / Int(pageWidth)
        pageControl.currentPage = currentPage
    }
}
