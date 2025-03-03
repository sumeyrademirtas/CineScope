//
//  PersonDetailsInfoCell.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/24/25.
//

import UIKit

class PersonDetailsInfoCell: UICollectionViewCell {
    static let reuseIdentifier = "PersonDetailsInfoCell"

    private let posterImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 8
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.widthAnchor.constraint(equalToConstant: 150).isActive = true
        return iv
    }()
    
    private let birthdayLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        // Buraya küçük bir takvim ikonu da ekleyebilirsiniz (ör. NSAttributedString).
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let biographyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .white
        label.numberOfLines = 8
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let moreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Read More", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.isHidden = true // 📌 Başlangıçta gizli
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // Bu örnekte, sağ tarafı bir vertical stackView ile yönetebilirsiniz.
    private let rightStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private var personName: String = ""
    private var biographyText: String = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

//    private func setupUI() {
//        contentView.backgroundColor = .brandDarkBlue
//
//        contentView.addSubview(posterImageView)
//        contentView.addSubview(rightStackView)
//
//        rightStackView.addArrangedSubview(birthdayLabel)
//        rightStackView.addArrangedSubview(biographyLabel)
//
//        NSLayoutConstraint.activate([
//            // Poster pinned top & bottom
//            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
//            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
//            posterImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
//            posterImageView.widthAnchor.constraint(equalToConstant: 150),
//
//            // Right stack pinned top & bottom
//            rightStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
//            rightStackView.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 12),
//            rightStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
//            rightStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
//        ])
//    }
    
    private func setupUI() {
        contentView.backgroundColor = .brandDarkBlue

        contentView.addSubview(posterImageView)
        contentView.addSubview(rightStackView)

        rightStackView.addArrangedSubview(birthdayLabel)
        rightStackView.addArrangedSubview(biographyLabel)
        rightStackView.addArrangedSubview(moreButton)

        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            posterImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            posterImageView.widthAnchor.constraint(equalToConstant: 150),

            rightStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            rightStackView.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 12),
            rightStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            rightStackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8),

            moreButton.heightAnchor.constraint(equalToConstant: 30) // 📌 Buton boyutu
        ])

        moreButton.addTarget(self, action: #selector(moreButtonTapped), for: .touchUpInside)
    }

    // MARK: - Configure
//    func configure(with person: PersonDetails) {
//        // Örnek: PersonDetails modelinde birthday, biography ve profilePath gibi alanlar olsun
//        birthdayLabel.text = "Born: \(person.birthday ?? "N/A")"
//        biographyLabel.text = person.biography ?? "No biography"
//        loadImage(from: person.profilePhotoURL!) // FIXME: - bunu unwrap yap ya da baska bir sey.
//    }
    
    func configure(with person: PersonDetails) {
        personName = person.name
        biographyText = person.biography ?? "No biography available"

        birthdayLabel.text = "Born: \(person.birthday ?? "N/A")"
        biographyLabel.text = biographyText
        loadImage(from: person.profilePhotoURL ?? "")

        // 📌 Eğer biography 8 satırdan fazlaysa "More" butonunu göster
        if biographyLabel.text?.count ?? 0 > 250 { // Tahmini olarak uzunluğu kontrol ediyoruz
            moreButton.isHidden = false
        } else {
            moreButton.isHidden = true
        }
    }
    
    @objc private func moreButtonTapped() {
        let moreDetailsVC = MoreDetailsVC(text: biographyText)
        
        moreDetailsVC.modalPresentationStyle = .pageSheet
        
        if let sheet = moreDetailsVC.sheetPresentationController {
            sheet.detents = [
                .medium(), .large()
            ]
            sheet.preferredCornerRadius = 16
            
            // Yukarı çekme çubuğu görünmesin
            sheet.prefersGrabberVisible = true
            
            // Sayfa yukarı kaydırılmasın
            moreDetailsVC.isModalInPresentation = false
        }
        
        if let parentVC = findViewController() {
            parentVC.present(moreDetailsVC, animated: true)
        }
    }
    
    private func findViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let nextResponder = responder?.next {
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            responder = nextResponder
        }
        return nil
    }

    // URL'den resim yükleme metodu
    private func loadImage(from url: String) {
        guard let url = URL(string: url) else {
            posterImageView.image = UIImage(named: "placeholder") // Varsayılan bir görsel kullan
            return
        }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self, let data = data, error == nil else {
                DispatchQueue.main.async {
                    self?.posterImageView.image = UIImage(named: "placeholder") // Hata durumunda varsayılan görsel
                }
                return
            }
            DispatchQueue.main.async {
                self.posterImageView.image = UIImage(data: data)
            }
        }.resume()
    }
}
