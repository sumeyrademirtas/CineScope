//
//  FavoritesVC.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 3/13/25.
//

import Combine
import UIKit

class FavoritesVC: BaseViewController {
    // MARK: - Properties

    private let viewModel: FavoritesVM
    private let provider: any FavoritesProvider
    private var cancellables = Set<AnyCancellable>()
    
    private let inputVM = PassthroughSubject<FavoritesVMImpl.FavoritesVMInput, Never>()
    private let inputPR = PassthroughSubject<FavoritesProviderImpl.Input, Never>()
    
    private var allFavorites: [FavoriteItem] = []
    private var filteredFavorites: [FavoriteItem] = []

    private var selectedFilter: String? = nil
    
    // MARK: - UI Elements

    private let allButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("All", for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.cornerRadius = 15
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.clear
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let moviesButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Movies", for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.cornerRadius = 15
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.clear
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let tvSeriesButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Tv Series", for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.cornerRadius = 15
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.clear
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // CollectionView: Favori posterlerinin grid olarak gösterileceği alan
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    // MARK: - Init

    init(viewModel: FavoritesVM, provider: any FavoritesProvider) {
        self.viewModel = viewModel
        self.provider = provider
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        binding()
        updateButtonStyles()
        
        inputPR.send(.setupUI(collectionView: collectionView))
        
        inputVM.send(.fetchFavorites)
        collectionView.delegate = self
        allButton.addTarget(self, action: #selector(filterAll), for: .touchUpInside)
        moviesButton.addTarget(self, action: #selector(filterMovies), for: .touchUpInside)
        tvSeriesButton.addTarget(self, action: #selector(filterTvSeries), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        inputVM.send(.fetchFavorites)
    }
    
    // MARK: - Setup UI

    private func setupUI() {
        view.backgroundColor = UIColor.brandDarkBlue
        title = "Favorites"
        
        allButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 100).isActive = true
        moviesButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 100).isActive = true
        tvSeriesButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 100).isActive = true
        
        let buttonStackView = UIStackView(arrangedSubviews: [allButton, moviesButton, tvSeriesButton])
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 12
        buttonStackView.distribution = .fillEqually
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
               
        view.addSubview(buttonStackView)
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            buttonStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            buttonStackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16),
                  
            collectionView.topAnchor.constraint(equalTo: buttonStackView.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Filter Functions

    @objc private func filterAll() {
        selectedFilter = nil
        updateButtonStyles()
        applyFilter()
    }

    @objc private func filterMovies() {
        if selectedFilter == "movie" {
            selectedFilter = nil
        } else {
            selectedFilter = "movie"
        }
        updateButtonStyles()
        applyFilter()
    }

    @objc private func filterTvSeries() {
        if selectedFilter == "tvSeries" {
            selectedFilter = nil
        } else {
            selectedFilter = "tvSeries"
        }
        updateButtonStyles()
        applyFilter()
    }
        
    private func applyFilter() {
        if let filter = selectedFilter {
            filteredFavorites = allFavorites.filter { $0.itemType == filter }
        } else {
            filteredFavorites = allFavorites
        }
            
        inputPR.send(.reloadData(favorites: filteredFavorites))
    }
    
    // MARK: - Button Style Update

    private func updateButtonStyles() {
        if selectedFilter == nil {
            allButton.backgroundColor = UIColor.white
            allButton.setTitleColor(UIColor.brandDarkBlue, for: .normal)
        } else {
            allButton.backgroundColor = UIColor.brandDarkBlue
            allButton.setTitleColor(UIColor.white, for: .normal)
        }
        
        if selectedFilter == "movie" {
            moviesButton.backgroundColor = UIColor.white
            moviesButton.setTitleColor(UIColor.brandDarkBlue, for: .normal)
        } else {
            moviesButton.backgroundColor = UIColor.brandDarkBlue
            moviesButton.setTitleColor(UIColor.white, for: .normal)
        }
        
        if selectedFilter == "tvSeries" {
            tvSeriesButton.backgroundColor = UIColor.white
            tvSeriesButton.setTitleColor(UIColor.brandDarkBlue, for: .normal)
        } else {
            tvSeriesButton.backgroundColor = UIColor.brandDarkBlue
            tvSeriesButton.setTitleColor(UIColor.white, for: .normal)
        }
    }
}

// MARK: - ViewModel & Provider Binding

extension FavoritesVC {
    private func binding() {
        let vmOutput = viewModel.activityHandler(input: inputVM.eraseToAnyPublisher())
        vmOutput.receive(on: DispatchQueue.main).sink { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .isLoading(let isShow):
                self.loading(isShow: isShow)
                print("⏳ Favoriler yükleniyor: \(isShow)")
            case .dataSource(let favorites):
                print("📢 Favori verileri Provider'a gönderiliyor: \(favorites.count) adet")
                self.allFavorites = favorites
                self.applyFilter()
            case .errorOccurred(let message):
                print("❌ Favoriler HATA: \(message)")
            }
        }.store(in: &cancellables)
        
        let providerOutput = provider.activityHandler(input: inputPR.eraseToAnyPublisher())
        providerOutput.receive(on: DispatchQueue.main).sink { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .didSelectFavoriteItem(let indexPath):
                print("Tiklandi")
            }
        }.store(in: &cancellables)
    }
}

extension FavoritesVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item < filteredFavorites.count else { return }
        let favorite = filteredFavorites[indexPath.item]
        
        guard let type = favorite.itemType?.lowercased() else { return }
        if type == "movie" {
            let movieDetailsVC = MovieDetailsBuilderImpl().build(movieId: Int(favorite.id))
            movieDetailsVC.modalPresentationStyle = .pageSheet
            movieDetailsVC.modalTransitionStyle = .crossDissolve
            
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = scene.windows.first,
               let rootVC = window.rootViewController
            {
                rootVC.present(movieDetailsVC, animated: true)
            }
        } else if type == "tv" || type == "tvseries" {
            let tvDetailsVC = TvSeriesDetailsBuilderImpl().build(tvSeriesId: Int(favorite.id))
            tvDetailsVC.modalPresentationStyle = .pageSheet
            tvDetailsVC.modalTransitionStyle = .crossDissolve
            
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = scene.windows.first,
               let rootVC = window.rootViewController
            {
                rootVC.present(tvDetailsVC, animated: true)
            }
        }
    }
}

extension FavoritesVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let totalSpacing: CGFloat = 16 * 3
        let width = (collectionView.bounds.width - totalSpacing) / 3
        let height = width * 1.5
        return CGSize(width: width, height: height)
    }
}
