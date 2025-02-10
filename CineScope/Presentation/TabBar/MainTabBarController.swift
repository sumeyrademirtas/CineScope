//
//  MainTabBarController.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/10/25.
//

import UIKit

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.backgroundColor = .gray
        
        
        // Movies tab için builder kullanarak MoviesVC oluşturuyoruz.
        let moviesBuilder = MovieBuilderImpl()
        let moviesVC = moviesBuilder.build()
        moviesVC.tabBarItem = UITabBarItem(
            title: "Movies",
            image: UIImage(systemName: "film"),
            tag: 0
        )
        // TvSeries tab için builder kullanarak TvSeriesVC oluşturuyoruz.
        let tvSeriesBuilder = TvSeriesBuilderImpl()
        let tvSeriesVC = tvSeriesBuilder.build()
        tvSeriesVC.tabBarItem = UITabBarItem(
            title: "TV Series",
            image: UIImage(systemName: "tv"),
            tag: 1
        )
        // TabBarController'ın viewControllers'ını ayarlıyoruz.
        viewControllers = [moviesVC, tvSeriesVC]
    }
}
