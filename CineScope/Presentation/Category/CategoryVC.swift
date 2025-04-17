//
//  CategoryVC.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 4/15/25.
//

import UIKit
import Combine



class CategoryVC: BaseViewController {
    deinit {
        print("Destroy CategoryVC") // MARK: - Memory Leak Check
    }
    
    // MARK: - UI Components
    
    private let segmentedControl: UISegmentedControl = {
        let items = ["Movies", "TV Series"]
        let sc = UISegmentedControl(items: items)
        sc.selectedSegmentIndex = 0
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.backgroundColor = .white
        sc.selectedSegmentTintColor = UIColor.brandDarkBlue
        sc.setTitleTextAttributes([.foregroundColor: UIColor.brandDarkBlue], for: .normal)
        sc.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        return sc
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.brandDarkBlue
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    // MARK: - ViewModel
    
    private let viewModel: CategoryVMImpl
        private var cancellables = Set<AnyCancellable>()
        private let inputSubject = PassthroughSubject<CategoryVMImpl.CategoryVMInput, Never>()
        private var categories: [CategoryItem] = []
        
        init(viewModel: CategoryVMImpl) {
            self.viewModel = viewModel
            super.init(nibName: nil, bundle: nil)
        }
        required init?(coder: NSCoder) { fatalError() }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            title = "Categories"
            view.backgroundColor = .brandDarkBlue
            setupUI()
            bindViewModel()
            inputSubject.send(.fetchGenres(isMovie: true))
        }
    
    // MARK: - Binding
    
    @objc private func segChanged() {
        let isMovie = segmentedControl.selectedSegmentIndex == 0
        print("🟠 [CategoryVC] segChanged: isMovie = \(isMovie)")
        inputSubject.send(.fetchGenres(isMovie: isMovie))
    }
    
    private func bindViewModel() {
            viewModel.activityHandler(input: inputSubject.eraseToAnyPublisher())
                .receive(on: RunLoop.main)
                .sink { [weak self] output in
                    guard let self = self else { return }
                    switch output {
                    case .isLoading(let isShow):
                        self.loading(isShow: isShow)
                    case .dataSource(let items):
                        self.categories = items
                        self.collectionView.reloadData()
                        
                    case .errorOccurred(let msg):
                        print("🚨 Category error:", msg)
                    }
                }
                .store(in: &cancellables)
        }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.addSubview(segmentedControl)
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            collectionView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 24),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        collectionView.register(
            CategoryCollectionViewCell.self,
            forCellWithReuseIdentifier: CategoryCollectionViewCell.reuseIdentifier
        )
        collectionView.dataSource = self
        collectionView.delegate   = self
        
        segmentedControl.addTarget(self,
                                      action: #selector(segChanged),
                                      for: .valueChanged)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout


extension CategoryVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ cv: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        categories.count
    }
    func collectionView(_ cv: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = categories[indexPath.item]
        let cell = cv.dequeueReusableCell(
            withReuseIdentifier: CategoryCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as! CategoryCollectionViewCell
        cell.configure(with: item)
        return cell
    }
    func collectionView(_ cv: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 10
        let w = (cv.bounds.width - spacing) / 2
        return CGSize(width: w, height: w * 0.6)
    }
}
