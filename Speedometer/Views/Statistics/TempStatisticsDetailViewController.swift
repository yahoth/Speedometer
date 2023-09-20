//
//  TempStatisticsDetailViewController.swift
//  Speedometer
//
//  Created by TAEHYOUNG KIM on 2023/09/21.
//

import UIKit

class TempStatisticsDetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topContainerView: UIView!
    @IBOutlet weak var mapView: UIImageView!
    @IBOutlet weak var bottomContainerStack: UIStackView!
    @IBOutlet weak var modeImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

    func configure() {
        [imageView, topContainerView, bottomContainerStack, mapView, modeImageView].forEach {
            $0.layer.cornerRadius = 16
        }

        topContainerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        bottomContainerStack.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
}
