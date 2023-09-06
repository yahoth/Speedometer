//
//  ResultViewController.swift
//  GPSPractice
//
//  Created by TAEHYOUNG KIM on 2023/09/05.
//

import UIKit

class ResultViewController: UIViewController {

    @IBOutlet weak var averageSpeedLabel: UILabel!
    @IBOutlet weak var totalDistanceLabel: UILabel!

    @IBOutlet weak var colorLabel: UILabel!

    var averageSpeed: Double!
    var totalDistance: Double!

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

    private func configure() {
        averageSpeedLabel.text = "\(String(describing: averageSpeed))"
        totalDistanceLabel.text = "\(String(describing: totalDistance))"
        colorLabel.backgroundColor = UIColor(hex: "30611D")
    }
}
