//
//  MovieDetailsHeaderView.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/17/25.
//

import UIKit

class MovieDetailsHeaderView: UICollectionReusableView {
    
    static let reuseIdentifier = "MovieDetailsHeaderView"

    
    // MARK: - UI Elements
    
    private let backdropImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let gradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.black.withAlphaComponent(0.6).cgColor, UIColor.clear.cgColor]
        gradient.locations = [0.0, 0.7]
        return gradient
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "xmark.circle.fill")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.3) // 🔥 Hafif siyah transparan arka plan
        button.layer.cornerRadius = 16 // Tam yuvarlak yapsın
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        addSubview(backdropImageView)
        addSubview(closeButton)
        
        backdropImageView.layer.addSublayer(gradientLayer)
        
        NSLayoutConstraint.activate([
            backdropImageView.topAnchor.constraint(equalTo: topAnchor),
            backdropImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backdropImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backdropImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            closeButton.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = backdropImageView.bounds
    }
    
    // MARK: - Public Methods
    
    func configure(with movie: MovieDetails){
        loadImage(from: movie.backgropPathURL)
    }
    
    // URL'den resim yükleme metodu
    private func loadImage(from url: String) {
        guard let url = URL(string: url) else {
            backdropImageView.image = UIImage(named: "placeholder") // Varsayılan bir görsel kullan
            return
        }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self, let data = data, error == nil else {
                DispatchQueue.main.async {
                    self?.backdropImageView.image = UIImage(named: "placeholder") // Hata durumunda varsayılan görsel
                }
                return
            }
            DispatchQueue.main.async {
                self.backdropImageView.image = UIImage(data: data)
            }
        }.resume()
    }
    
    func setCloseAction(target: Any?, action: Selector) {
        closeButton.addTarget(target, action: action, for: .touchUpInside)
    }
}
