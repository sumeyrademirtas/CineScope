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
        
        // Category tab
        let categoryBuilder = CategoryBuilderImpl()
        let categoryVC = categoryBuilder.build()
        categoryVC.tabBarItem = UITabBarItem(
            title: "Categories",
            image: UIImage(systemName: "square.grid.2x2.fill"),
            tag: 2
        )
        
        // Search tabi
        let searchBuilder = SearchBuilderImpl()
        let searchVC = searchBuilder.build()
        searchVC.tabBarItem = UITabBarItem(
            title: "Search",
            image: UIImage(systemName: "magnifyingglass"),
            tag: 3
        )
        
        // Favorites tab
        let favoritesBuilder = FavoritesBuilderImpl()
        let favoritesVC = favoritesBuilder.build()
        favoritesVC.tabBarItem = UITabBarItem(
            title: "Favorites",
            image: UIImage(systemName: "heart.fill"),
            tag: 4
        )
        


               
        // TabBarController'ın viewControllers'ını ayarlıyoruz.
        viewControllers = [moviesVC, tvSeriesVC, categoryVC, searchVC, favoritesVC]
    }
}
