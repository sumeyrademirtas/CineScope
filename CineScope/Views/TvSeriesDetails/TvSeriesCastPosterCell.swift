//
//  TvSeriesCastPosterCell.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 3/4/25.
//

import UIKit

class TvSeriesCastPhotoCell: UICollectionViewCell {
    static let reuseIdentifier = "TvSeriesCastPhotoCell"

    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = imageView.bounds.width / 2
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .darkGray
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let characterLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .lightGray
        label.textAlignment = .center
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
  
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
//        contentView.backgroundColor = .red // Debug
        contentView.backgroundColor = UIColor(hue: 0.65, saturation: 0.27, brightness: 0.18, alpha: 1.00) // Debug

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(characterLabel)

        NSLayoutConstraint.activate([
            // Profile image at the top and centered
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 120),
            profileImageView.heightAnchor.constraint(equalToConstant: 120),

            // Name label below the image
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 4),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            
            // Character label below the name label
            characterLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            characterLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            characterLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            characterLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
        ])
        
    }

    func configure(with cast: TvSeriesCast) {
        nameLabel.text = cast.name ?? "Unknown"
        characterLabel.text = cast.character ?? "Unknown"
        loadImage(from: cast.profilePathURL)
    }
    
    private func loadImage(from urlString: String) {
        guard !urlString.isEmpty, let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                self.profileImageView.image = UIImage(named: "placeholder")
                self.profileImageView.backgroundColor = .darkGray
            }
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self, let data = data, error == nil else {
                DispatchQueue.main.async {
                    self?.profileImageView.image = UIImage(named: "placeholder")
                    self?.profileImageView.backgroundColor = .darkGray
                }
                return
            }
            DispatchQueue.main.async {
                self.profileImageView.image = UIImage(data: data)
                self.profileImageView.backgroundColor = .clear
                // Force an update to the corner radius using the current bounds
                self.profileImageView.layer.cornerRadius = self.profileImageView.bounds.width / 2
                self.layoutIfNeeded()
            }
        }.resume()
    }
}
