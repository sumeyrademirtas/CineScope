//
//  FavoriteAnimationView.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 3/6/25.
//

import UIKit
import Lottie

public protocol FavoriteAnimatable {
    var isFavorite: Bool { get }
    func toggleFavorite(to newState: Bool, completion: ((Bool) -> Void)?)
}

public class FavoriteAnimationView: UIView, FavoriteAnimatable {
    
    private var animationView: LottieAnimationView!
    
    public private(set) var isFavorite: Bool = false
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupAnimationView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupAnimationView()
    }
    
    private func setupAnimationView() {
        animationView = LottieAnimationView(name: "favorite")
        animationView.loopMode = .playOnce
        animationView.contentMode = .scaleAspectFit
        animationView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.topAnchor.constraint(equalTo: topAnchor),
            animationView.bottomAnchor.constraint(equalTo: bottomAnchor),
            animationView.leadingAnchor.constraint(equalTo: leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        animationView.currentProgress = 0
    }
    
    public func toggleFavorite(to newState: Bool, completion: ((Bool) -> Void)? = nil) {
        guard newState != isFavorite else {
            completion?(true)
            return
        }
        
        isFavorite = newState
        
        if newState {
            animationView.play { finished in
                completion?(finished)
            }
        } else {
            animationView.play(fromProgress: 1, toProgress: 0, loopMode: .playOnce) { finished in
                completion?(finished)
            }
        }
    }
    
    public func resetAnimation() {
        animationView.currentProgress = 0
    }
}
