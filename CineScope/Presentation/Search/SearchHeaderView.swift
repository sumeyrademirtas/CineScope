//
//  SearchHeaderView.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/13/25.
//

import Foundation
import UIKit

class SearchHeaderView: UIView {
    
    // Arama çubuğu: UISearchBar kullanıyoruz
    let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Search movies..."
        sb.translatesAutoresizingMaskIntoConstraints = false
        return sb
    }()
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        // SearchBar'ı view'e ekleyelim.
        addSubview(searchBar)
        
        // Auto Layout kısıtlamaları: SearchBar, tüm kenarlara yapışık olsun.
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: trailingAnchor),
            searchBar.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
