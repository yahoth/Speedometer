//
//  StatisticsViewController.swift
//  GPSPractice
//
//  Created by TAEHYOUNG KIM on 2023/09/07.
//

import UIKit
import CoreData
import Combine

class StatisticsViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!

    var datasource: UICollectionViewDiffableDataSource<Section, Item>!
    @Published var results: [SavedResult]?
    var subscriptions = Set<AnyCancellable>()
    typealias Item = SavedResult
    enum Section {
        case main
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        fetch()
        bind()
    }

    func bind() {
        $results
            .compactMap { $0 }
            .sink { results in
                self.applySnapshot(item: results)
            }.store(in: &subscriptions)
    }

    func applySnapshot(item: [SavedResult]) {
        var snapshot = datasource.snapshot()
        snapshot.appendItems(item)
        datasource.apply(snapshot)
    }

    func fetch() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext

        do {
            let results = try context.fetch(SavedResult.fetchRequest()) as? [SavedResult]
            self.results = results
        } catch {
            print(error.localizedDescription)
        }
    }

    private func configureCollectionView() {
        datasource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StatisticsRowCell", for: indexPath) as? StatisticsRowCell else { return UICollectionViewCell() }
            cell.configure(item: item)
            return cell
        }
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems([])

        datasource.apply(snapshot)

        collectionView.collectionViewLayout = layout()
        collectionView.delegate = self
    }

    private func layout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(2 / 5))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 15
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}

extension StatisticsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = datasource.itemIdentifier(for: indexPath) else { return }
    }
}
