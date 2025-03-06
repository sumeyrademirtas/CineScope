//
//  PersonDetailsProvider.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/24/25.
//

import Combine
import Foundation
import UIKit

protocol PersonDetailsProvider: CollectionViewProvider where T == PersonDetailsVMImpl.SectionType, I == IndexPath {
    func activityHandler(input: AnyPublisher<PersonDetailsProviderImpl.PersonDetailsProviderInput, Never>) -> AnyPublisher<PersonDetailsProviderImpl.PersonDetailsProviderOutput, Never>
}

final class PersonDetailsProviderImpl: NSObject, PersonDetailsProvider {

    
    typealias T = PersonDetailsVMImpl.SectionType
    typealias I = IndexPath
    var dataList: [PersonDetailsVMImpl.SectionType] = [] // FIXME: -

    // Binding
    private let output = PassthroughSubject<PersonDetailsProviderOutput, Never>()

    private var cancellables = Set<AnyCancellable>()

    private weak var collectionView: UICollectionView?

    private var isLoading: Bool = false
}

// MARK: - EventType

extension PersonDetailsProviderImpl {
    enum PersonDetailsProviderInput {
        case setupUI(collectionView: UICollectionView)
        case prepareCollectionView(data: [PersonDetailsVMImpl.SectionType])
    }

    enum PersonDetailsProviderOutput {
        case didSelectMovie(movieId: Int) // FIXME: -
        case didSelectTvSeries(tvSeriesId: Int) // FIXME: -
    }
}

// MARK: - Binding

extension PersonDetailsProviderImpl {
    func activityHandler(input: AnyPublisher<PersonDetailsProviderInput, Never>) -> AnyPublisher<PersonDetailsProviderOutput, Never> {
        input.sink { [weak self] eventType in
            switch eventType {
            case .setupUI(let collectionView):
                self?.setupCollectionView(collectionView: collectionView)
            case .prepareCollectionView(let data):
                self?.prepareCollectionView(data: data) // FIXME: Bura yanlis olabilir
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
}

// MARK: - CollectionView Setup and Delegation

extension PersonDetailsProviderImpl: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func setupCollectionView(collectionView: UICollectionView) {
        self.collectionView = collectionView
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        // Register cells
        self.collectionView?.register(
            PersonDetailsHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: PersonDetailsHeaderView.reuseIdentifier
        )
        collectionView.register(PersonDetailsInfoCell.self,
                                forCellWithReuseIdentifier: PersonDetailsInfoCell.reuseIdentifier)
        collectionView.register(PersonMovieSectionCell.self,
                                forCellWithReuseIdentifier: PersonMovieSectionCell.reuseIdentifier)
        collectionView.register(PersonTvSectionCell.self,
                                forCellWithReuseIdentifier: PersonTvSectionCell.reuseIdentifier)

        print("Person CollectionView setup tamamlandi.")
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataList.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int
    {
        // Her section’da 1 cell göstereceğiz (except info).
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = dataList[indexPath.section]
        switch section {
        case .info(let rows):
            // Extract the first row and then the associated person info
            guard let row = rows.first, case .personInfo(let person) = row else {
                fatalError("No person info available")
            }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PersonDetailsInfoCell.reuseIdentifier, for: indexPath) as! PersonDetailsInfoCell
            cell.configure(with: person)
            return cell

        case .movies(let rows):
            guard let row = rows.first, case .personMovieCredits(let movieCredits) = row else {
                fatalError("No movie credits available")
            }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PersonMovieSectionCell.reuseIdentifier, for: indexPath) as! PersonMovieSectionCell
            cell.configure(with: movieCredits)
            
            //
            cell.onMovieSelected = { [weak self] movieId in
                print("Movie with ID \(movieId) selected from person's credits.")
                self?.output.send(.didSelectMovie(movieId: movieId)) }
                    
            return cell

        case .tvShows(let rows):
            guard let row = rows.first, case .personTvCredits(let tvCredits) = row else {
                fatalError("No TV credits available")
            }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PersonTvSectionCell.reuseIdentifier, for: indexPath) as! PersonTvSectionCell
            cell.configure(with: tvCredits)
            cell.onTvSeriesSelected = { [weak self] tvSeriesId in
                print("tvSeries with ID \(tvSeriesId) selected from person's credits.")
                self?.output.send(.didSelectTvSeries(tvSeriesId: tvSeriesId)) }
            return cell
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }

        // Sadece en üstte (indexPath.section == 0) header göstermek istiyoruz.
        if indexPath.section == 0 {
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: PersonDetailsHeaderView.reuseIdentifier,
                for: indexPath
            ) as! PersonDetailsHeaderView

            // Kişinin adıyla header'ı configure et
            if let firstSection = dataList.first, case .info(let rows) = firstSection,
               let firstRow = rows.first, case .personInfo(let person) = firstRow {
                header.configure(with: person.name)
            }

            return header
        } else {
            return UICollectionReusableView() // Diğer section'larda header istemiyoruz
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        if section == 0 {
            return CGSize(width: collectionView.frame.width, height: 50) // Header için uygun yükseklik
        } else {
            return CGSize(width: 0, height: 0) // Diğer section'lar header kullanmayacak
        }
    }

    
    
    // Hucre boyutlari
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
           return CGSize(width: collectionView.frame.width, height: 250)
        } else {
           return CGSize(width: collectionView.frame.width, height: 200)
        }
    }
    
    func reloadCollectionView() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView?.reloadData()
        }
    }
    
    func prepareCollectionView(data: [PersonDetailsVMImpl.SectionType]) {
        dataList = data
        reloadCollectionView()
    }
}
