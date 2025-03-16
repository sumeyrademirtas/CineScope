//
//  MoviePosterViewCell.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/5/25.
//

import Foundation
import UIKit

class MoviePosterViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "MoviePosterViewCell"
    
    // MARK: - Properties
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        contentView.addSubview(posterImageView)
        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            posterImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 1) // bunu eklemeyince boyutlar sapitiyor
            ])
    }
    
    override func prepareForReuse() {
          super.prepareForReuse()
          posterImageView.image = nil // Eski resmi temizle
      }
    
    
    // MARK: Configure Cell
    func configure(with movie: Movie) {
        guard let posterURL = movie.fullPosterURL else {
            posterImageView.image = UIImage(named: "placeholder") // Eğer URL yoksa varsayılan resim
            return
        }
        loadImage(from: posterURL)
    }
    
    
    // MARK: - URL'den Resim Yükleme
        private func loadImage(from url: String) {
            guard let imageURL = URL(string: url) else {
                posterImageView.image = UIImage(named: "placeholder") // Geçersiz URL için varsayılan görsel
                return
            }
            
            URLSession.shared.dataTask(with: imageURL) { [weak self] data, _, error in
                guard let self = self, let data = data, error == nil, let image = UIImage(data: data) else {
                    DispatchQueue.main.async {
                        self?.posterImageView.image = UIImage(named: "placeholder") // Hata durumunda varsayılan görsel
                    }
                    return
                }
                DispatchQueue.main.async {
                    self.posterImageView.image = image
                }
            }.resume()
        }
    
}
