//
//  TvSeriesDetailsVC.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 3/4/25.
//

import Combine
import Foundation
import UIKit

class TvSeriesDetailsVC: BaseViewController {
    deinit {
        print("Destroy TvSeriesDetailsVC") // MARK: - Memory Leak Check
    }

    // MARK: - Types

    typealias P = TvSeriesDetailsProvider
    typealias V = TvSeriesDetailsVM

    // MARK: - Properties

    private var viewModel: V?
    private var provider: (any P)?

    private var tvSeriesId: Int?

    // Combine binding
    private let inputVM = PassthroughSubject<TvSeriesDetailsVMImpl.TvSeriesDetailsVMInput, Never>()
    private let inputPR = PassthroughSubject<TvSeriesDetailsProviderImpl.TvSeriesDetailsProviderInput, Never>()
    private var cancellables = Set<AnyCancellable>()

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
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

    func configure(tvSeriesId: Int) {
        self.tvSeriesId = tvSeriesId
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
        if let tvSeriesId = tvSeriesId {
            inputVM.send(.fetchTvSeriesDetails(tvSeriesId: tvSeriesId))
            inputVM.send(.fetchTvSeriesCredits(tvSeriesId: tvSeriesId)) // Cast için de ekle
            inputVM.send(.fetchTvSeriesVideos(tvSeriesId: tvSeriesId))
        }
        print("🛠️ CollectionView Delegate: \(String(describing: collectionView.delegate))")
    }
}

// MARK: - Setup UI

extension TvSeriesDetailsVC {
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

extension TvSeriesDetailsVC {
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
            case .didToggleFavorite(let tvSeriesId, let isFavorite, let posterURL, let itemType):
                print("Favori Durumu Değişti: TvSeriesId: \(tvSeriesId), Favori: \(isFavorite), posterURL: \(posterURL), itemType: \(itemType)")
                if isFavorite {
                    CoreDataManager.shared.addFavorite(id: Int64(tvSeriesId), posterURL: posterURL, itemType: itemType)
                } else {
                    CoreDataManager.shared.removeFavorite(id: Int64(tvSeriesId))
                }
                if let providerImpl = self!.provider as? TvSeriesDetailsProviderImpl {
                    providerImpl.animateFavorite(for: tvSeriesId, isFavorite: isFavorite)
                }
            case .didSelectCast(let personId):
                print("Did select cast with personId: \(personId)")
                self?.navigateToCastDetails(personId: personId)
            }
        }.store(in: &cancellables)
    }
}

// MARK: - Error Handling

extension TvSeriesDetailsVC {
    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension TvSeriesDetailsVC {
    private func navigateToCastDetails(personId: Int) {
        let personDetailsVC = PersonDetailsBuilderImpl().build(personId: personId)
        personDetailsVC.modalPresentationStyle = .pageSheet
        personDetailsVC.modalTransitionStyle = .crossDissolve
        present(personDetailsVC, animated: true, completion: nil)
    }
}
