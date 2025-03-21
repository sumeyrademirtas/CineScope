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
    
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
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
    

    private func setupUI() {
        contentView.addSubview(posterImageView)
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            posterImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            posterImageView.widthAnchor.constraint(equalToConstant: 80),
            
            titleLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with item: SearchItem) {
        switch item {
        case .movie(let movie):
            titleLabel.text = movie.name
            if let posterURL = movie.fullPosterURL, let url = URL(string: posterURL) {
                URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                    guard let self = self, let data = data, let image = UIImage(data: data) else {
                        DispatchQueue.main.async {
                            self?.posterImageView.image = UIImage(named: "placeholder")
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        self.posterImageView.image = image
                    }
                }.resume()
            } else {
                posterImageView.image = UIImage(named: "placeholder")
            }
            
        case .tvSeries(let tvSeries):
            titleLabel.text = tvSeries.name
            if let posterURL = tvSeries.fullPosterURL, let url = URL(string: posterURL) {
                URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                    guard let self = self, let data = data, let image = UIImage(data: data) else {
                        DispatchQueue.main.async {
                            self?.posterImageView.image = UIImage(named: "placeholder")
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        self.posterImageView.image = image
                    }
                }.resume()
            } else {
                posterImageView.image = UIImage(named: "placeholder")
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.image = nil
        titleLabel.text = nil
    }
}
