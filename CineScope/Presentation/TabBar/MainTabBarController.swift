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
        
        // Search tabi
        let searchBuilder = SearchBuilderImpl()
        let searchVC = searchBuilder.build()
        searchVC.tabBarItem = UITabBarItem(
            title: "Search",
            image: UIImage(systemName: "magnifyingglass"),
            tag: 2
        )
        
        // Favorites tab: Favoriler ekranını oluşturuyoruz.
        let favoritesVC = FavoritesVC() // Önceki adımlarda oluşturduğumuz FavoritesVC
        favoritesVC.tabBarItem = UITabBarItem(
            title: "Favorites",
            image: UIImage(systemName: "heart.fill"),
            tag: 3
        )
               
        // TabBarController'ın viewControllers'ını ayarlıyoruz.
        viewControllers = [moviesVC, tvSeriesVC, searchVC, favoritesVC]
    }
}
