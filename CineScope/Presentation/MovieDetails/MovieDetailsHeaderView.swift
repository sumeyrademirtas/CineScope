//
//  MovieDetailsHeaderView.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/17/25.
//

import UIKit

class MovieDetailsHeaderView: UICollectionReusableView {
    static let reuseIdentifier = "MovieDetailsHeaderView"

    private let trailerPlayerView: VideoPlayerView = {
        let view = VideoPlayerView()
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
        backgroundColor = .black
        addSubview(trailerPlayerView)

        NSLayoutConstraint.activate([
            trailerPlayerView.topAnchor.constraint(equalTo: topAnchor),
            trailerPlayerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            trailerPlayerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            trailerPlayerView.heightAnchor.constraint(equalToConstant: 250)
    }

}
