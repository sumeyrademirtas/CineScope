//
//  TvSeriesDetailsContentCell.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 3/4/25.
//
import UIKit

class TvSeriesDetailsContentCell: UICollectionViewCell {
    static let reuseIdentifier = "TvSeriesDetailsContentCell"

    // MARK: - UI Elements

    // Poster Image
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        return imageView
    }()

    // Overview
    private let overviewLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .white
        label.numberOfLines = 8
        label.textAlignment = .natural
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // More Button (Eğer 300+ kelime varsa gösterilecek)
    private let moreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Read More", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal) // Mavi renk
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true // ✅ Başlangıçta gizli olacak
        return button
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
    
    private let firtAirYearLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let numberofSeasonsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Rating, firtAirYearLabel, numberofSeasonsLabel
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
        moreButton.addTarget(self, action: #selector(moreButtonTapped), for: .touchUpInside)
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
        infoStackView.addArrangedSubview(moreButton)

        // Horizontal stack'e poster + info ekle
        horizontalStackView.addArrangedSubview(posterImageView)
        horizontalStackView.addArrangedSubview(infoStackView)

        // Rating stack'e ratingProgressView ekle (İleride başka elemanlar da ekleyebilirsin)
        ratingDateRuntimeStackView.addArrangedSubview(ratingProgressView)
        ratingDateRuntimeStackView.addArrangedSubview(firtAirYearLabel)
        ratingDateRuntimeStackView.addArrangedSubview(numberofSeasonsLabel)

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


    func configure(with tvSeries: TvSeriesDetails) {
        overviewLabel.text = tvSeries.overview
        genreLabel.text = tvSeries.genres?.map { $0.name }.joined(separator: ", ") ?? "N/A"
        ratingProgressView.setProgress(voteAverage: CGFloat(tvSeries.voteAverage ?? 0.0))
        loadImage(from: tvSeries.fullPosterURL)
        
        let yearsRange = "\(tvSeries.firstAirYear) - \(tvSeries.lastAir)"
        firtAirYearLabel.attributedText = createAttributedText(iconName: "calendar", text: yearsRange)
        
        let seasonsText: String
        if let count = tvSeries.numberOfSeasons {
            seasonsText = "\(count) Season" + (count > 1 ? "s" : "")
        } else {
            seasonsText = "N/A"
        }
        numberofSeasonsLabel.attributedText = createAttributedText(iconName: "tv", text: seasonsText)
        
        // Eğer overview 250 karakterden uzunsa "More" butonunu göster
        moreButton.isHidden = tvSeries.overview!.count <= 250 || tvSeries.overview!.isEmpty
    }

    // MARK: - Yardımcı Fonksiyon
    private func createAttributedText(iconName: String, text: String) -> NSAttributedString {
        let iconAttachment = NSTextAttachment()
        iconAttachment.image = UIImage(systemName: iconName)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        iconAttachment.bounds = CGRect(x: 0, y: -2, width: 14, height: 14)
        
        let attributedText = NSMutableAttributedString(attachment: iconAttachment)
        attributedText.append(NSAttributedString(string: " \(text)"))
        return attributedText
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
    
    // MARK: - More Button Action
       @objc private func moreButtonTapped() {
           let moreDetailsVC = MoreDetailsVC(text: overviewLabel.text ?? "")
           moreDetailsVC.modalPresentationStyle = .formSheet
           if let sheet = moreDetailsVC.sheetPresentationController {
               sheet.detents = [
                           .custom(resolver: { context in
                               return UIScreen.main.bounds.height / 3 // ✅ Ekran yüksekliğinin 1/3’ü
                           })
                       ]
               sheet.preferredCornerRadius = 16
               
               // Yukarı çekme çubuğu görünmesin
               sheet.prefersGrabberVisible = false
               
               // Sayfa yukarı kaydırılmasın
               moreDetailsVC.isModalInPresentation = false
           }

           if let parentVC = findViewController() {
               parentVC.present(moreDetailsVC, animated: true)
           }
       }

       // MARK: - Find Parent ViewController
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
}
