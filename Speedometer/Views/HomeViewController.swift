//
//  HomeViewController.swift
//  GPSPractice
//
//  Created by TAEHYOUNG KIM on 2023/09/07.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    @IBAction func startButtonTapped(_ sender: Any) {
        let sb = UIStoryboard(name: "Speedometer", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "SpeedometerNavigationController") as! SpeedometerNavigationController

        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve

        present(vc, animated: true)
    }

}
