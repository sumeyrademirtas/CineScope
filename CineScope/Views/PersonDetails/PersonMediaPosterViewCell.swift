//
//  PersonMoviePosterViewCell.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/24/25.
//


import UIKit

class PersonMediaPosterViewCell: UICollectionViewCell {
    static let reuseIdentifier = "PersonMediaPosterViewCell"
    
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.backgroundColor = .brandDarkBlue
        contentView.addSubview(posterImageView)
        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            posterImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    // PersonMovieCredits modeline uygun yapılandırma metodu
    func configure(with movieCredits: PersonMovieCredits) {
        loadImage(from: movieCredits.fullPosterURL)
    }
    
    // PersonTvCredits modeline uygun yapılandırma metodu. fazladan ayni dosyadan bi daha yazmak yerine configure u overload edecegim.
    func configure(with tvCredits: PersonTvCredits) {
        loadImage(from: tvCredits.fullPosterURL)

    }
    
    
    private func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else {
            posterImageView.image = UIImage(named: "placeholder")
            return
        }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self, let data = data, error == nil else {
                DispatchQueue.main.async {
                    self?.posterImageView.image = UIImage(named: "placeholder")
                }
                return
            }
            DispatchQueue.main.async {
                self.posterImageView.image = UIImage(data: data)
            }
        }.resume()
    }
}
