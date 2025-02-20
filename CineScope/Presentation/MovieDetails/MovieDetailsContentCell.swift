//
//  MovieDetailsContentView.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/20/25.
//

import UIKit

class MovieDetailsContentCell: UICollectionViewCell {
    static let reuseIdentifier = "MovieDetailsContentCell"
    
    
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.translatesAutoresizingMaskIntoConstraints = false
        // Sabit genişlik belirleyelim
        imageView.widthAnchor.constraint(equalToConstant: 130).isActive = true
        return imageView
    }()
    
    private let overviewLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .natural
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let genreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.italicSystemFont(ofSize: 14)
        label.textColor = .black
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    // Sağ tarafta genre ve overview'u barındıracak dikey stack view
    private let infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // Tüm elemanları yatay olarak yerleştirecek container stack view
    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.alignment = .top
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .orange  // Debug için
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
           // Info stack view'a genre ve overview label'larını ekleyelim
           infoStackView.addArrangedSubview(genreLabel)
           infoStackView.addArrangedSubview(overviewLabel)
           
           // Container stack view'a sol tarafta poster, sağ tarafta info stack ekleyelim
           containerStackView.addArrangedSubview(posterImageView)
           containerStackView.addArrangedSubview(infoStackView)
           
           // Container stack view'ı contentView'e ekleyip kenarlardan sabit aralık verelim
           contentView.addSubview(containerStackView)
           NSLayoutConstraint.activate([
               containerStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
               containerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
               containerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
               containerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
           ])
       }
    
    // Hücreyi yapılandırmak için: overview, genres ve posterURL kullanılır.
    func configure(with overview: String, genres: String, posterURL: String?) {
        print("✅ Hücreye Veri Gönderiliyor: \(overview)")
        overviewLabel.text = overview
        genreLabel.text = genres
        
        // loadImage fonksiyonunu kullanarak resmi indiriyoruz.
        loadImage(from: posterURL)
    }
    
    // URL'den resim yükleme metodu
    private func loadImage(from urlString: String?) {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            posterImageView.image = UIImage(named: "placeholder") // Varsayılan görsel
            return
        }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self, let data = data, error == nil else {
                DispatchQueue.main.async {
                    self?.posterImageView.image = UIImage(named: "placeholder")
                }
                return
            }
            DispatchQueue.main.async {
                self.posterImageView.image = UIImage(data: data)
            }
        }.resume()
    }
}
