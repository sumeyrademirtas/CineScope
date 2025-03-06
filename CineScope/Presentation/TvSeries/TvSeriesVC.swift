//
//  TvSeriesVC.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/10/25.
//

import Combine
import Foundation
import UIKit

class TvSeriesVC: BaseViewController {
    // MARK: - Types

    typealias P = TvSeriesListProvider
    typealias V = TvSeriesVM

    // MARK: - Properties

    private var viewModel: V?
    private var provider: (any P)?

    // Combine binding
    private let inputVM = PassthroughSubject<TvSeriesVMImpl.TvSeriesVMInput, Never>()
    private let inputPR = PassthroughSubject<TvSeriesListProviderImpl.TvSeriesListProviderInput, Never>()
    private var cancellables = Set<AnyCancellable>()

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        collectionView.backgroundColor = .darkGray
        collectionView.backgroundColor = UIColor(hue: 0.65, saturation: 0.27, brightness: 0.18, alpha: 1.00)
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
    required init?(coder: NSCoder) { // storyboard olmadigi icin
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

//        self.loading(isShow: true)

        setupUI()
        binding()
        inputPR.send(.setupUI(collectionView: collectionView))
        let categories: [TvSeriesCategory] = [.airingToday, .onTheAir, .popular, .topRated]
        inputVM.send(.start(categories: categories, page: 1))
    }
}

// MARK: - Setup UI

extension TvSeriesVC {
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

extension TvSeriesVC {
    private func binding() {
        // vm den gelen ciktilari dinle
        let vmOutput = viewModel?.activityHandler(input: inputVM.eraseToAnyPublisher())
        vmOutput?.receive(on: DispatchQueue.main).sink {
            [weak self] event in
            switch event {
            case .isLoading(let isShow):
                self?.loading(isShow: isShow)
//            case .sectionUpdated(let category, let section):
//                break // MARK: MAhsuna sor
            case .errorOccured(let message):
                self?.showError(message: message)
            case .dataSource(let section):
                self?.inputPR.send(.prepareCollectionView(data: section))
            }
        }.store(in: &cancellables)

        // providerdan gelen ciktilari dinle
        let providerOutput = provider?.activityHandler(input: inputPR.eraseToAnyPublisher())
        providerOutput?.sink {
            [weak self] event in
            switch event {
            case .didSelectTvSeries(let tvSeriesId):
                self?.navigateToTvSeriesDetails(tvSeriesId: tvSeriesId)
            }
        }.store(in: &cancellables)
    }
}

// MARK: - Error Handling

extension TvSeriesVC {
    /// Hata mesajını kullanıcıya gösterir
    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// ✅ **TvSeries Details Sayfasına Geçiş Yap**
extension TvSeriesVC {
    private func navigateToTvSeriesDetails(tvSeriesId: Int) {
        let tvSeriesDetailsVC = TvSeriesDetailsBuilderImpl().build(tvSeriesId: tvSeriesId)
        tvSeriesDetailsVC.modalPresentationStyle = .pageSheet
        tvSeriesDetailsVC.modalTransitionStyle = .crossDissolve
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first,
           let rootVC = window.rootViewController
        {
            rootVC.present(tvSeriesDetailsVC, animated: true)
        }
    }
}
