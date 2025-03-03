//
//  TrailerViewCell.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/28/25.
//

import UIKit

class TrailerViewCell: UICollectionViewCell {
    static let reuseIdentifier = "TrailerViewCell"

    private let trailerPlayerView: VideoPlayerView = {
        let view = VideoPlayerView()
        view.backgroundColor = UIColor.brandDarkBlue
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(trailerPlayerView)

        NSLayoutConstraint.activate([
            trailerPlayerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            trailerPlayerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            trailerPlayerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            trailerPlayerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            trailerPlayerView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }

    func loadYouTubeVideo(videoID: String) {
        trailerPlayerView.loadYouTubeVideo(videoID: videoID)
    }
}
