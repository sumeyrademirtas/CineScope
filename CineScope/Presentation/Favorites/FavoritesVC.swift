//
//  FavoritesVC.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 3/13/25.
//

import UIKit
import CoreData

class FavoritesVC: UIViewController {

    private var favorites: [FavoriteItem] = []
    private let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadFavorites()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "Favoriler"
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
//    private func loadFavorites() {
//        favorites = CoreDataManager.shared.fetchFavorites()
//        tableView.reloadData()
//    }
    private func loadFavorites() {
        favorites = CoreDataManager.shared.fetchFavorites()
        
        // Eğer favori listesi boşsa, dummy data ekleyelim.
        if favorites.isEmpty {
            let context = CoreDataManager.shared.context
            
            let dummyFavorite1 = FavoriteItem(context: context)
            dummyFavorite1.id = 101
            dummyFavorite1.posterURL = "https://dummyimage.com/200x300/000/fff&text=Movie+101"
            dummyFavorite1.itemType = "movie"
            
            let dummyFavorite2 = FavoriteItem(context: context)
            dummyFavorite2.id = 202
            dummyFavorite2.posterURL = "https://dummyimage.com/200x300/000/fff&text=TV+Series+202"
            dummyFavorite2.itemType = "tv"
            
            // Dummy veriyi favoriler dizisine ekliyoruz
            favorites = [dummyFavorite1, dummyFavorite2]
            
            // İsteğe bağlı: Context'i kaydedip dummy verilerin kalıcılığını sağlayabilirsiniz.
            CoreDataManager.shared.saveContext()
        }
        tableView.reloadData()
    }
}

extension FavoritesVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let favorite = favorites[indexPath.row]
        
        // Favori öğesi film mi, dizi mi onu belirtmek için
        if let type = favorite.itemType {
            cell.textLabel?.text = (type == "movie" ? "🎬 " : "📺 ") + "ID: \(favorite.id)"
        } else {
            cell.textLabel?.text = "ID: \(favorite.id)"
        }
        
        return cell
    }
    
    // Silme işlemi için (favori çıkarma)
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let favorite = favorites[indexPath.row]
            CoreDataManager.shared.removeFavorite(id: favorite.id)
            favorites.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}
