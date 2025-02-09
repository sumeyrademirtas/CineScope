//
//  ViewController.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 1/29/25.
//

import UIKit
import Combine

class MoviesVC: BaseViewController { // FIXME: BaseClass kontrolu yap. BaseClass atacak mahsun

    // MARK: - Types
    typealias P = MovieListProvider
    typealias V = MovieVM
    
    // MARK: - Properties
    private var viewModel: V? // Mahsuna sor. bunlar dogru tanimlamalar mi?
    private var provider: (any P)?
    
    // Combine binding
    private let inputVM = PassthroughSubject<MovieVMImpl.MovieVMInput, Never>() //vm e gonderilecek input olaylari
    private let inputPR = PassthroughSubject<MovieListProviderImpl.MovieListProviderInput, Never>() // provider a gidecek input olaylari
    private var cancellables = Set<AnyCancellable>()
    
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .darkGray
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    // MARK: - Init
    init(viewModel: V, provider: (any P)) {
        self.viewModel = viewModel
        self.provider = provider
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { //storyboard olmadigi icin
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.loading(isShow: true)
        
        setupUI()
        binding()
        inputPR.send(.setupUI(collectionView: collectionView))
        let categories: [MovieCategory] = [.popular, .upcoming, .topRated, .nowPlaying]
        inputVM.send(.start(categories: categories, page: 1))
    }
}

// MARK: - Setup UI
extension MoviesVC {
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
extension MoviesVC {
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
            case .didSelect(let indexPath):
                print("Seçilen IndexPath: \(indexPath)")
            }
        }.store(in: &cancellables)
    }
}



// MARK: - Error Handling

extension MoviesVC {
    /// Hata mesajını kullanıcıya gösterir
    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

