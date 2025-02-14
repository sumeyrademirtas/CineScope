//
//  SearchResultTableViewCell.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/13/25.
//

import Foundation
import UIKit

class SearchResultTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "SearchResultTableViewCell"
    
    // Poster resmi göstermek için UIImageView
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    // Film başlığını göstermek için UILabel
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Setup UI - posterImageView ve titleLabel'ı contentView'a ekleyip Auto Layout ile konumlandırıyoruz.
    private func setupUI() {
        contentView.addSubview(posterImageView)
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            // PosterImageView sol kenara, üst ve alt kenarlara 10 pt boşluk bırakarak yerleştiriliyor.
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            posterImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            posterImageView.widthAnchor.constraint(equalToConstant: 80),
            
            // TitleLabel, posterImageView'in sağından başlayıp, sağ kenara 10 pt boşluk bırakacak şekilde yerleştiriliyor.
            titleLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    // Hücreyi yapılandırma metodu, arama sonucuna göre cell içeriklerini ayarlar.
    func configure(with movie: SearchMovie) {
        // Örneğin, film modelinde title ve posterPath gibi alanlar olduğunu varsayalım.
        titleLabel.text = movie.name
        
        // Basit asenkron image yükleme (örneğin, URLSession veya başka bir kütüphane ile)
        if let url = URL(string: movie.fullPosterURL) {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                guard let data = data,
                      let image = UIImage(data: data) else { return }
                DispatchQueue.main.async {
                    self?.posterImageView.image = image
                }
            }.resume()
        } else {
            posterImageView.image = UIImage(named: "placeholder")
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Eski verilerin kalmaması için hücreyi temizliyoruz.
        posterImageView.image = nil
        titleLabel.text = nil
    }
}
