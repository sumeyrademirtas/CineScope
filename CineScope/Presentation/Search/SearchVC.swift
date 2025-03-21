//
//  SearchVC.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/14/25.
//

import Combine
import UIKit

class SearchVC: BaseViewController {
    deinit {
        print("Destroy SearchVC") // MARK: - Memory Leak Check
    }
    
    // MARK: - Types

    typealias P = SearchListProvider
    typealias V = SearchVM
    
    // MARK: - Properties

    private var viewModel: V?
    private var provider: (any P)?
    
    private var searchItems: [SearchItem] = []

    // Combine binding
    private let inputVM = PassthroughSubject<SearchVMImpl.SearchVMInput, Never>()
    private let inputPR = PassthroughSubject<SearchListProviderImpl.SearchListProviderInput, Never>()
    
    private var cancellables = Set<AnyCancellable>()
    
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private let headerView = SearchHeaderView()

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
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupUI()
        binding()
        inputPR.send(.setupUI(tableView: tableView))
        
        headerView.searchBar.delegate = self
        
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
}

// MARK: - Setup UI

extension SearchVC {
    private func setupUI() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        headerView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 44)
        tableView.tableHeaderView = headerView
        tableView.rowHeight = 120 // Poster ve yazının daha geniş gözükmesi için.
    }
}

// MARK: - Combine Binding

extension SearchVC {
    private func binding() {
        // vm den gelen ciktilari dinle
        let vmOutput = viewModel?.activityHandler(input: inputVM.eraseToAnyPublisher())
        vmOutput?.receive(on: DispatchQueue.main).sink {
            [weak self] event in
            switch event {
            case .isLoading(let isShow):
                self?.loading(isShow: isShow)
            case .results(let movies, let tvSeries):
                let movieItems = movies.map { SearchItem.movie($0) }
                let tvSeriesItems = tvSeries.map { SearchItem.tvSeries($0) }
                let combined = movieItems + tvSeriesItems
                self?.inputPR.send(.prepareTableView(data: combined))
            case .errorOccured(let message):
                self?.showError(message: message)
            case .noResults:
                self?.inputPR.send(.prepareTableView(data: []))
            }
        }.store(in: &cancellables)
        
        let providerOutput = provider?.activityHandler(input: inputPR.eraseToAnyPublisher())
        providerOutput?.receive(on: DispatchQueue.main).sink { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .didSelect(let indexPath):
                if let providerImpl = self.provider as? SearchListProviderImpl {
                    let item = providerImpl.dataList[indexPath.row]
                            
                    switch item {
                    case .movie(let movie):
                        self.presentMovieDetails(movieId: movie.id)
                                
                    case .tvSeries(let tvSeries):
                        self.presentTvSeriesDetails(tvSeriesId: tvSeries.id)
                    }
                }
            }
        }.store(in: &cancellables)
    }
    
    private func presentMovieDetails(movieId: Int) {
        let movieDetailsVC = MovieDetailsBuilderImpl().build(movieId: movieId)
        movieDetailsVC.modalPresentationStyle = .pageSheet
        movieDetailsVC.modalTransitionStyle = .crossDissolve
            
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first,
           let rootVC = window.rootViewController
        {
            rootVC.present(movieDetailsVC, animated: true)
        }
    }
        
    private func presentTvSeriesDetails(tvSeriesId: Int) {
        let tvDetailsVC = TvSeriesDetailsBuilderImpl().build(tvSeriesId: tvSeriesId)
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

// MARK: - Error Handling

extension SearchVC {
    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension SearchVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Arama çubuğundaki metin değiştiğinde inputVM'e event gönderilir.
        inputVM.send(.queryChanged(searchText))
    }
}

// keyboard to dismiss when the user taps the search button on the keyboard
extension SearchVC {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension SearchVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < searchItems.count else { return }
        let selectedItem = searchItems[indexPath.row]
        
        switch selectedItem {
        case .movie(let movie):
            let movieDetailsVC = MovieDetailsBuilderImpl().build(movieId: movie.id)
            movieDetailsVC.modalPresentationStyle = .pageSheet
            movieDetailsVC.modalTransitionStyle = .crossDissolve
            
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = scene.windows.first,
               let rootVC = window.rootViewController
            {
                rootVC.present(movieDetailsVC, animated: true)
            }
            
        case .tvSeries(let tvSeries):
            let tvDetailsVC = TvSeriesDetailsBuilderImpl().build(tvSeriesId: tvSeries.id)
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
