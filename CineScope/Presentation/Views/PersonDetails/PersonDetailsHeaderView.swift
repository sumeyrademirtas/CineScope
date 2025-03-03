//
//  PersonDetailsHeaderView.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/26/25.
//

import Foundation
import UIKit

class PersonDetailsHeaderView: UICollectionReusableView {
    
    static let reuseIdentifier = "PersonDetailsHeaderView"
    
    private let titleLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.boldSystemFont(ofSize: 20)
            label.textColor = .white
            label.textAlignment = .center
            label.numberOfLines = 2
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        backgroundColor = UIColor(hue: 0.65, saturation: 0.27, brightness: 0.18, alpha: 1.00) // Debug
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupUI() {
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor), // Yatay merkezleme
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor), // Dikey merkezleme
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16)
        ])
        
    }
    
    func configure(with title: String) {
        titleLabel.text = title
    }
        
}
