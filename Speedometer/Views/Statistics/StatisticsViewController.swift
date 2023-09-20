//
//  StatisticsViewController.swift
//  GPSPractice
//
//  Created by TAEHYOUNG KIM on 2023/09/07.
//

import UIKit
import CoreData
import Combine
import SwiftUI


class StatisticsViewController: UIViewController {
    let vm = StatisticsViewModel()

    @IBOutlet weak var tableView: UITableView!
    var datasource: UITableViewDiffableDataSource<Section, Item>!
    var subscriptions = Set<AnyCancellable>()
    typealias Item = SavedResult
    enum Section {
        case main
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        vm.fetch()
        bind()
        print("Statisctics VC init")
    }

    private func bind() {
        vm.$results
            .compactMap { $0 }
            .sink { results in
                self.applySnapshot(item: results)
            }.store(in: &subscriptions)

        vm.coredataManager.didChangeObjectsNotification
            .sink { _ in
                self.vm.fetch()
        }.store(in: &subscriptions)

        vm.selectedResult
            .sink { result in
                let sb = UIStoryboard(name: "TempDetail", bundle: nil)
                let vc = sb.instantiateViewController(withIdentifier: "TempStatisticsDetailViewController") as! TempStatisticsDetailViewController
//                vc.vm = StatisticsDetailViewModel(result: result)
                self.navigationController?.pushViewController(vc, animated: true)
//                let tempView = tempStatisticsDetail(result: result)
//                let vc = UIHostingController(rootView: tempView)
//                self.navigationController?.pushViewController(vc, animated: true)
            }.store(in: &subscriptions)
    }

    private func applySnapshot(item: [SavedResult]) {
        var snapshot = datasource.snapshot()
        // 기존의 applied Snapshot 제거 후 apply
        snapshot.deleteAllItems()
        snapshot.appendSections([.main])
        snapshot.appendItems(item)
        datasource.apply(snapshot)
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
        vm.selectedResult.send(item)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return tableView.bounds.size.height * 0.4
        return tableView.bounds.size.width * 4 / 3
    }

    // 왼쪽 Swipe하여 아이템 삭제
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, completion) in
            var snapshot = self.datasource.snapshot()
            guard let itemToDelete = self.datasource.itemIdentifier(for: indexPath) else {
                completion(false)
                return
            }
            //Core Data Context의 item 삭제
            self.vm.coredataManager.deleteItem(itemToDelete: itemToDelete)

            //해당 Item 삭제 후 datasource 등록
            snapshot.deleteItems([itemToDelete])
            self.datasource.apply(snapshot)
            completion(true)
        }
         return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}



