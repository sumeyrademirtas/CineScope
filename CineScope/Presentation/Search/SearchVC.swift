//
//  SearchVC.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/14/25.
//

import Combine
import UIKit

class SearchVC: BaseViewController {
    // MARK: - Types

    typealias P = SearchListProvider
    typealias V = SearchVM
    
    // MARK: - Properties

    private var viewModel: V?
    private var provider: (any P)?
    
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


        // Do any additional setup after loading the view.
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
        tableView.rowHeight = 120  // Poster ve yazının daha geniş gözükmesi için.
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
            case .results(let results):
                self?.inputPR.send(.prepareTableView(data: results))
            case .errorOccured(let message):
                self?.showError(message: message)
            case .noResults:
                self?.inputPR.send(.prepareTableView(data: []))
                            
            }
        }.store(in: &cancellables)
        
        //provider dan gelen ciktilari dinle
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
