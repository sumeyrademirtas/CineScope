//
//  MovieDetailsHeaderView.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/17/25.
//

import UIKit

class MovieDetailsHeaderView: UICollectionReusableView {
    static let reuseIdentifier = "MovieDetailsHeaderView"
    
    private let titleLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.boldSystemFont(ofSize: 24)
            label.textColor = .white
            label.textAlignment = .center
            label.numberOfLines = 2
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()

    private let trailerPlayerView: VideoPlayerView = {
        let view = VideoPlayerView()
        view.backgroundColor = .red
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()



    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        backgroundColor = UIColor.blue.withAlphaComponent(0.5)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(titleLabel)
        addSubview(trailerPlayerView)
        
        trailerPlayerView.layer.borderWidth = 2
        trailerPlayerView.layer.borderColor = UIColor.black.cgColor // Siyah çerçeve ekledik
        trailerPlayerView.layer.cornerRadius = 10
        trailerPlayerView.clipsToBounds = true

        NSLayoutConstraint.activate([
            // Title Label Konumu
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            // Trailer View Konumu (Title'ın hemen altında)
            trailerPlayerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            trailerPlayerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            trailerPlayerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            trailerPlayerView.heightAnchor.constraint(equalToConstant: 200),

            // ❌ Şu satırı kaldır
            // trailerPlayerView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    func configure(with title: String) {
          titleLabel.text = title
      }
}
