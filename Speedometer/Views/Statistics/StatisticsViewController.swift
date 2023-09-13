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
    let vm = StatisticsViewModel()

    @IBOutlet weak var tableView: UITableView!
    var datasource: UITableViewDiffableDataSource<Section, Item>!
    typealias Item = SavedResult
    enum Section {
        case main
    }

    @Published var results: [SavedResult]?
    var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        fetch()
        bind()
        print("Statisctics VC init")
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
        datasource = UITableViewDiffableDataSource<Section, Item>(tableView: tableView) { tableView, indexPath, item in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "StatisticsRowCell", for: indexPath) as? StatisticsRowCell else { return nil }
            cell.configure(item: item)
            return cell
        }
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems([])

        datasource.apply(snapshot)
        tableView.delegate = self
    }

}

extension StatisticsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = datasource.itemIdentifier(for: indexPath) else { return }

    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.bounds.size.height * 0.4
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .delete
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, completion) in
            var snapshot = self.datasource.snapshot()
            guard let itemToDelete = self.datasource.itemIdentifier(for: indexPath) else {
                completion(false)
                return
            }
            self.vm.coredataManager.deleteItem(itemToDelete: itemToDelete)
            snapshot.deleteItems([itemToDelete])
            self.datasource.apply(snapshot)
            completion(true)
        }
         return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}



