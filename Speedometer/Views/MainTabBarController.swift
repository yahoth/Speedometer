//
//  MainTabBarController.swift
//  Speedometer
//
//  Created by TAEHYOUNG KIM on 2023/09/18.
//

import UIKit

class MainTabBarController: UITabBarController {

    var vm: MainTabBarViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        vm = MainTabBarViewModel()
        delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateNavigationItem(vc: selectedViewController!)
    }

    private func updateNavigationItem(vc: UIViewController) {
        switch vc {
        case is StatisticsViewController:
            let resetButton = UIBarButtonItem(title: "reset", style: .plain, target: self, action: #selector(reset))
            self.navigationItem.rightBarButtonItems = [resetButton]
        default:
            self.navigationItem.rightBarButtonItems = []
        }
    }

    @objc func reset() {
        vm.coreDataManager.reset()
    }
}

extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        updateNavigationItem(vc: viewController)    }
}
