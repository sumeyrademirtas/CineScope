//
//  MovieDetailsVC.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/17/25.
//

import Combine
import Foundation
import UIKit

class MovieDetailsVC: BaseViewController {
    deinit {
        print("Destroy MovieDetailsVC") // MARK: - Memory Leak Check
    }

    // MARK: - Types

    typealias P = MovieDetailsProvider
    typealias V = MovieDetailsVM

    // MARK: - Properties

    private var viewModel: V?
    private var provider: (any P)?

    private var movieId: Int? // 💡 Dependency Injection ile set edilecek

    // Combine binding
    private let inputVM = PassthroughSubject<MovieDetailsVMImpl.MovieDetailsVMInput, Never>()
    private let inputPR = PassthroughSubject<MovieDetailsProviderImpl.MovieDetailsProviderInput, Never>()
    private var cancellables = Set<AnyCancellable>()

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 250) // Header boyutu
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .brandDarkBlue

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    // MARK: - Init

    init(viewModel: V, provider: any P) {
        self.viewModel = viewModel
        self.provider = provider
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Movie ID’yi dışarıdan set eden fonksiyon
    func configure(movieId: Int) {
        self.movieId = movieId
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.brandDarkBlue
        collectionView.contentInsetAdjustmentBehavior = .never
        //    Eğer Navigation Bar varsa, CollectionView başlangıçta aşağıya kayar (içeriğin üstü Navigation Bar’ın altından başlamaz).

        setupUI()
        binding()
        inputPR.send(.setupUI(collectionView: collectionView))
        // 🔥 Eğer `movieId` varsa detayları getir
        if let movieId = movieId {
            inputVM.send(.fetchMovieDetails(movieId: movieId))
            inputVM.send(.fetchMovieCredits(movieId: movieId)) // Cast için de ekle
            inputVM.send(.fetchMovieVideos(movieId: movieId))
        }

        print("🛠️ CollectionView Delegate: \(String(describing: collectionView.delegate))")
    }
}

// MARK: - Setup UI

extension MovieDetailsVC {
    private func setupUI() {
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - Combine Binding

extension MovieDetailsVC {
    private func binding() {
        let vmOutput = viewModel?.activityHandler(input: inputVM.eraseToAnyPublisher())
        vmOutput?.receive(on: DispatchQueue.main).sink {
            [weak self] event in
            switch event {
            case .isLoading(let isShow):
                self?.loading(isShow: isShow)
            case .errorOccurred(let message):
                self?.showError(message: message)
            case .dataSource(let section):
                self?.inputPR.send(.prepareCollectionView(data: section))
            }
        }.store(in: &cancellables)

        let providerOutput = provider?.activityHandler(input: inputPR.eraseToAnyPublisher())
        providerOutput?.sink {
            [weak self] event in
            switch event {
            case .didToggleFavorite(let movieId, let isFavorite):
                    print("Favori Durumu Değişti: MovieID: \(movieId), Favori: \(isFavorite)")
                    // Provider, dataList ve collectionView'ı yönettiği için animasyonu onun üzerinden tetikleyin:
                if let providerImpl = self!.provider as? MovieDetailsProviderImpl {
                        providerImpl.animateFavorite(for: movieId, isFavorite: isFavorite)
                    }
            case .didSelectCast(let personId):
                print("Did select cast with personId: \(personId)")
                self?.navigateToCastDetails(personId: personId)
            }
        }.store(in: &cancellables)
    }
}

// MARK: - Error Handling

extension MovieDetailsVC {
    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}


// MARK: Navigate to Cast Details
extension MovieDetailsVC {
    private func navigateToCastDetails(personId: Int) {
        let personDetailsVC = PersonDetailsBuilderImpl().build(personId: personId)
        personDetailsVC.modalPresentationStyle = .pageSheet
        personDetailsVC.modalTransitionStyle = .crossDissolve
        present(personDetailsVC, animated: true, completion: nil)
    }
}
