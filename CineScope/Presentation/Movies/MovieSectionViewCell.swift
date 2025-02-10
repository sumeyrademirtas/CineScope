//
//  MovieSectionViewCell.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/5/25.
//

import Foundation
import UIKit

class MovieSectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "MovieSectionViewCell"
    
    var movies = [Movie]()
    func setUpDataList(movie: [Movie]) {
        self.movies = movie
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
        innerCollectionView.register(MoviePosterViewCell.self, forCellWithReuseIdentifier: MoviePosterViewCell.reuseIdentifier)
        innerCollectionView.backgroundColor = .gray
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
        movies = []
        innerCollectionView.reloadData()
    }
}

extension MovieSectionViewCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell =
                collectionView.dequeueReusableCell(withReuseIdentifier: "MoviePosterViewCell", for: indexPath) as? MoviePosterViewCell else {
            fatalError("Unable to dequeue MoviePosterViewCell")
        }
        cell.configure(with: movies[indexPath.row])
        return cell
    }
    
    
}
