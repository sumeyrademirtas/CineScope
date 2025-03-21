//
//  SearchListProvider.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/13/25.
//

import Combine
import Foundation
import UIKit

enum SearchItem {
    case movie(SearchMovie)
    case tvSeries(SearchTvSeries)
}

protocol SearchListProvider: TableViewProvider where T == SearchItem, I == IndexPath {
    func activityHandler(input: AnyPublisher<SearchListProviderImpl.SearchListProviderInput, Never>) -> AnyPublisher<SearchListProviderImpl.SearchListProviderOutput, Never>
}

final class SearchListProviderImpl: NSObject, SearchListProvider // Delegate DataSource protokollerini kullanacagimiz zaman NSObject gerekiyor o yuzden kullaniyoruz
{
    typealias T = SearchItem
    typealias I = IndexPath
    
    var dataList: [SearchItem] = []

    // Binding properties
    private let output = PassthroughSubject<SearchListProviderOutput, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    private weak var tableView: UITableView?
//    private var isLoading: Bool = FIXME: false Bunu sonra kullanacagim
}

// MARK: EventType

extension SearchListProviderImpl {
    enum SearchListProviderOutput {
        case didSelect(indexPath: IndexPath)
    }
    
    enum SearchListProviderInput {
        case setupUI(tableView: UITableView)
        case prepareTableView(data: [SearchItem])
    }
}

// MARK: - Binding

extension SearchListProviderImpl {
    func activityHandler(input: AnyPublisher<SearchListProviderInput, Never>) -> AnyPublisher<SearchListProviderOutput, Never> {
        input.sink { [weak self] eventType in
            guard let self = self else { return }
            switch eventType {
            case .setupUI(let tableView):
                self.setupTableView(tableView: tableView)
            case .prepareTableView(let data):
                self.prepareTableView(data: data)
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
}

//MARK: - TableView Setup and Delegation
extension SearchListProviderImpl: UITableViewDelegate, UITableViewDataSource {
    
    //  Setup Methods
    func setupTableView(tableView: UITableView) {
        self.tableView = tableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SearchResultTableViewCell.self, forCellReuseIdentifier: SearchResultTableViewCell.reuseIdentifier)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
        }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultTableViewCell.reuseIdentifier, for: indexPath) as? SearchResultTableViewCell else {
            fatalError("Unable to dequeue SearchResultTableViewCell")
        }
        let item = dataList[indexPath.row]
        cell.configure(with: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        output.send(.didSelect(indexPath: indexPath))
    }
    
    
    func reloadTableView() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView?.reloadData()
        }
    }
    
    func prepareTableView(data: [SearchItem]) {
        self.dataList = data
        reloadTableView()
    }
}
