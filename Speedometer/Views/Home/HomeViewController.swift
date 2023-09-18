//
//  HomeViewController.swift
//  GPSPractice
//
//  Created by TAEHYOUNG KIM on 2023/09/07.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var startButton: UIButton!

    var vm: HomeViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        vm = HomeViewModel()
    }

    @IBAction func startButtonTapped(_ sender: Any) {
        if vm.locationPublisher.authorizationStatus != .authorizedWhenInUse {
            vm.locationPublisher.requestWhenInUseAuthorization()
        } else {
            startSpeedometerMeasurement()
        }
    }

    func startSpeedometerMeasurement() {
        let sb = UIStoryboard(name: "Speedometer", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "SpeedometerNavigationController") as! SpeedometerNavigationController

        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve

        present(vc, animated: true)
    }
}
