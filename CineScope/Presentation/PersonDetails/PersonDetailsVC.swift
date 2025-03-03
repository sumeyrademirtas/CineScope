//
//  PersonDetailsVC.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/25/25.
//

import Combine
import Foundation
import UIKit

class PersonDetailsVC: BaseViewController {
    
    deinit {
        print("Destroy PersonDetailsVC") // MARK: - Memory Leak Check
    }
    // MARK: - Types

    typealias P = PersonDetailsProvider
    typealias V = PersonDetailsVM
    
    // MARK: - Properties

    private var viewModel: V?
    private var provider: (any P)?
    
    // Combine binding
    private let inputVM = PassthroughSubject<PersonDetailsVMImpl.PersonDetailsVMInput, Never>()
    private let inputPR = PassthroughSubject<PersonDetailsProviderImpl.PersonDetailsProviderInput, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .brandDarkBlue
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    private var personId: Int?
    
    init(viewModel: V, provider: any P /* , personId: Int */ ) {
        self.viewModel = viewModel
        self.provider = provider
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // This method sets the person ID after initialization
    func configure(personId: Int) {
        self.personId = personId
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Navigation bar'ı gizle
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        // Ustteki kodu yazinca kaydirarak geri gitme ozelligi calismiyordu. onun da calismasi icin alttaki kodu ekledik
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        super.viewDidLoad()

        setupUI()
        binding()
        inputPR.send(.setupUI(collectionView: collectionView))
            
        // Person ID ile fetch
        if let id = personId {
            inputVM.send(.fetchPersonDetails(personId: id))
            inputVM.send(.fetchPersonMovieCredits(personId: id))
            inputVM.send(.fetchPersonTvCredits(personId: id))
        }
        
        
    }
}

// MARK: - Setup UI

extension PersonDetailsVC {
    private func setupUI() {
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - Combine Binding

extension PersonDetailsVC {
    private func binding() {
        // vm den gelen ciktilari dinlemece
        let vmOutput = viewModel?.activityHandler(input: inputVM.eraseToAnyPublisher())
        vmOutput?.sink(receiveValue: { [weak self] event in
            switch event {
            case .isLoading(let show):
                self?.loading(isShow: show)
            case .dataSource(let section):
                self?.inputPR.send(.prepareCollectionView(data: section))
            case .errorOccured(let msg):
                self?.showError(message: msg)
            }
        }).store(in: &cancellables)
        
        // Provider Output
        let providerOutput = provider?.activityHandler(input: inputPR.eraseToAnyPublisher())
        providerOutput?.sink(receiveValue: { [weak self] event in
            switch event {
            case .didSelectMovie(let movieId):
                print("📲 didSelectMovie triggered with movieId: \(movieId)")
                self?.navigateToMovieDetails(movieId: movieId)
            case .didSelectTvSeries(let tvSeriesId):
                print("📲 didSelectTvSeries triggered with tvSeriesId: \(tvSeriesId)")
            }
        }).store(in: &cancellables)
    }
}


// MARK: - Error Handling

extension PersonDetailsVC {
    /// Hata mesajını kullanıcıya gösterir
    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension PersonDetailsVC {
    private func navigateToMovieDetails(movieId: Int) {
           let movieDetailsVC = MovieDetailsBuilderImpl().build(movieId: movieId)
           movieDetailsVC.modalPresentationStyle = .pageSheet
           movieDetailsVC.modalTransitionStyle = .crossDissolve
           self.present(movieDetailsVC, animated: true, completion: nil)
       }
}

