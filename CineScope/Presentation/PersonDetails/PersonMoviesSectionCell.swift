//
//  PersonMoviesSectionCell.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/24/25.
//

import UIKit

class PersonMoviesSectionCell: UICollectionViewCell {
    static let reuseIdentifier = "PersonMoviesSectionCell"

    private var personMovies: [PersonMovieCredits] = []
    
    var onMovieSelected: ((Int) -> Void)?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Movies"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .white
        return label
    }()

    private let innerCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .clear
        return cv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI() {
        contentView.backgroundColor = .brandDarkBlue
        contentView.addSubview(titleLabel)
        contentView.addSubview(innerCollectionView)
        innerCollectionView.dataSource = self
        innerCollectionView.delegate = self
        innerCollectionView.register(PersonMoviePosterViewCell.self,
                                     forCellWithReuseIdentifier: PersonMoviePosterViewCell.reuseIdentifier) // Poster cell

        // Auto Layout
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),

            innerCollectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            innerCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            innerCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            innerCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    func configure(with personMovies: [PersonMovieCredits]) {
        self.personMovies = personMovies
        innerCollectionView.reloadData()
    }
}

// MARK: - DataSource, Delegate
extension PersonMoviesSectionCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return personMovies.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "PersonMoviePosterViewCell",
            for: indexPath) as? PersonMoviePosterViewCell else {
            fatalError("Cannot dequeue PersonMoviePosterViewCell")
        }
        let personMovie = personMovies[indexPath.item]
        cell.configure(with: personMovie) // Poster’ı yükleyen bir metot
        return cell
    }

    // FlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 150) // Poster boyutu
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = personMovies[indexPath.item]
        onMovieSelected?(movie.id)
    }
}
