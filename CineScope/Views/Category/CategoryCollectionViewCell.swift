//
//  CategoryCollectionViewCell.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 4/15/25.
//

import UIKit

struct CategoryItem {
  let id: Int
  let name: String
  let imageName: String

  init(id: Int, name: String, imageName: String = "genre_placeholder") {
    self.id = id
    self.name = name
    self.imageName = imageName
  }
}

class CategoryCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "CategoryCollectionViewCell"
    
    // MARK: - UI Components
    private let categoryImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .white
        // Arka plan rengini yarı saydam siyah yapıyoruz
        label.backgroundColor = UIColor.brandDarkBlue.withAlphaComponent(0.4)
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupViews() {
        contentView.addSubview(categoryImageView)
        contentView.addSubview(categoryLabel)
        
        NSLayoutConstraint.activate([
            // categoryImageView tüm contentView'u kaplayacak şekilde
            categoryImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            categoryImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            categoryImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            categoryImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            // categoryLabel; sol alt köşede, 8pt boşluk bırakılarak yerleştirilecek
            categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            categoryLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    // MARK: - Configure Cell
    func configure(with item: CategoryItem) {
        // Eğer GenreImage enum’u, kategori adını anahtar olarak kabul ediyorsa:
        if let genreImage = GenreImage(rawValue: item.name) {
            categoryImageView.image = UIImage(named: genreImage.imageName)
        } else {
            categoryImageView.image = UIImage(named: "genre_comedy") // FIXME: burada placeholder olacak sekilde duzenle sonra.
        }
        categoryLabel.text = item.name
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        categoryImageView.image = nil
        categoryLabel.text = nil
    }
}
