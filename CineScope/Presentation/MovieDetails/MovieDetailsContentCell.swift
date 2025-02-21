////
////  MovieDetailsContentView.swift
////  CineScope
////
////  Created by Sümeyra Demirtaş on 2/20/25.
////
//


import UIKit

class MovieDetailsContentCell: UICollectionViewCell {
    static let reuseIdentifier = "MovieDetailsContentCell"

    // MARK: - UI Elements

    // Poster Image
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 130).isActive = true
        return imageView
    }()

    // Overview
    private let overviewLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .natural
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    //Genre
    private let genreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.italicSystemFont(ofSize: 14)
        label.textColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Poster + Info Stack (yatay)
    private let horizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.alignment = .top
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    // MARK: - Info (dikey)
    private let infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    // MARK: - Rating Progress
    private let ratingProgressView: CircularProgressView = {
        let view = CircularProgressView(radius: 16) // ✅ Artık büyüklüğü değişiyor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let releaseDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let runtimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Rating, ReleaseDate, Runtime
    private let ratingDateRuntimeStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    // MARK: - Tüm Layout'u Tutan Dikey Stack
    private let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup UI
    private func setupUI() {
        contentView.backgroundColor = UIColor(hue: 0.65, saturation: 0.27, brightness: 0.18, alpha: 1.00) // Debug
        NSLayoutConstraint.activate([
            ratingProgressView.widthAnchor.constraint(equalToConstant: 40), // Genişlik
            ratingProgressView.heightAnchor.constraint(equalToConstant: 40) // Yükseklik
        ])

        // Info stack'e genre + overview ekle
        infoStackView.addArrangedSubview(genreLabel)
        infoStackView.addArrangedSubview(overviewLabel)

        // Horizontal stack'e poster + info ekle
        horizontalStackView.addArrangedSubview(posterImageView)
        horizontalStackView.addArrangedSubview(infoStackView)

        // Rating stack'e ratingProgressView ekle (İleride başka elemanlar da ekleyebilirsin)
        ratingDateRuntimeStackView.addArrangedSubview(ratingProgressView)
        ratingDateRuntimeStackView.addArrangedSubview(releaseDateLabel)
        ratingDateRuntimeStackView.addArrangedSubview(runtimeLabel)

        // Dikey stack'e sırasıyla horizontalStackView (poster + info), sonra ratingStackView ekle
        verticalStackView.addArrangedSubview(horizontalStackView)
        verticalStackView.addArrangedSubview(ratingDateRuntimeStackView)

        contentView.addSubview(verticalStackView)

        // Dikey stack'i kenarlardan sabitle
        NSLayoutConstraint.activate([
            verticalStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            verticalStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            verticalStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            verticalStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }

    // MARK: - Configure
    func configure(with overview: String, genres: String, posterURL: String?, voteAverage: CGFloat, releaseDate: String, runtime: String) {
        overviewLabel.text = overview
        genreLabel.text = genres
        ratingProgressView.setProgress(voteAverage: voteAverage) // Oranı ayarla
        loadImage(from: posterURL)
        
        // SF Symbol ile Release Date Label
        let calendarIcon = NSTextAttachment()
        calendarIcon.image = UIImage(systemName: "calendar")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        calendarIcon.bounds = CGRect(x: 0, y: -2, width: 14, height: 14)

        let releaseAttributedString = NSMutableAttributedString(attachment: calendarIcon)
        releaseAttributedString.append(NSAttributedString(string: " \(releaseDate)"))
        releaseDateLabel.attributedText = releaseAttributedString

        // SF Symbol ile Runtime Label
        let clockIcon = NSTextAttachment()
        clockIcon.image = UIImage(systemName: "clock")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        clockIcon.bounds = CGRect(x: 0, y: -2, width: 14, height: 14)

        let runtimeAttributedString = NSMutableAttributedString(attachment: clockIcon)
        runtimeAttributedString.append(NSAttributedString(string: " \(runtime)"))
        runtimeLabel.attributedText = runtimeAttributedString
    }

    // MARK: - Load Image
    private func loadImage(from urlString: String?) {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            posterImageView.image = UIImage(named: "placeholder")
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
