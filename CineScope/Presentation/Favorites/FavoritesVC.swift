//
//  FavoritesVC.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 3/13/25.
//


import UIKit
import Combine

class FavoritesVC: BaseViewController {
    
    // MARK: - Properties
    private let viewModel: FavoritesVM
    private let provider: any FavoritesProvider
    private var cancellables = Set<AnyCancellable>()
    
    private let inputVM = PassthroughSubject<FavoritesVMImpl.FavoritesVMInput, Never>()
    private let inputPR = PassthroughSubject<FavoritesProviderImpl.Input, Never>()
    
    // UISegmentedControl (Filmler / TV Dizileri)
    private let segmentControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Movies", "TV Series"])
        sc.selectedSegmentIndex = 0
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
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
        
        inputPR.send(.setupUI(collectionView: collectionView))
        
        inputVM.send(.fetchFavorites)
        
        segmentControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        inputVM.send(.fetchFavorites)

    }
    
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = UIColor.brandDarkBlue
        title = "Favorites"
        
        view.addSubview(segmentControl)
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            segmentControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            segmentControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            collectionView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    

    
    @objc private func segmentChanged() {
        print("Segment changed: \(segmentControl.selectedSegmentIndex)")
        // İleride filtreleme eklenebilir.
    }
}


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
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.inputPR.send(.reloadData(favorites: favorites))
                    print("📩 FAVORİLER PROVIDER’A GÖNDERİLDİ!")
                }
            case .errorOccurred(let message):
                print("❌ Favoriler HATA: \(message)")
            }
        }.store(in: &cancellables)
        
        let providerOutput = provider.activityHandler(input: inputPR.eraseToAnyPublisher())
        providerOutput.receive(on: DispatchQueue.main).sink { event in
            switch event {
            case .didSelectFavoriteItem(let favoriteItem):
                print("🎯 Seçilen favori: ID: \(favoriteItem.id)")
                // Detay sayfası yönlendirmesi yapılabilir.
            }
        }.store(in: &cancellables)
    }
}
