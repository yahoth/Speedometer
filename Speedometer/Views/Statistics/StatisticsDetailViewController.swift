//
//  StatisticsDetailViewController.swift
//  Speedometer
//
//  Created by TAEHYOUNG KIM on 2023/09/21.
//

import UIKit
import Combine

class StatisticsDetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topContainerView: UIView!
    @IBOutlet weak var mapView: UIImageView!
    @IBOutlet weak var bottomContainerStack: UIStackView!
    @IBOutlet weak var modeImageView: UIImageView!

    @IBOutlet weak var startAddress: UILabel!
    @IBOutlet weak var endAddress: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var averageSpeedLabel: UILabel!
    @IBOutlet weak var altitudeLabel: UILabel!
    @IBOutlet weak var topSpeedLabel: UILabel!
    
    var vm:  StatisticsDetailViewModel!
    var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        applyCommonStyles()
        applyTopContainerStyles()
        applyBottomContainerStyles()
        bind()
    }

    func applyCommonStyles() {
        [imageView, topContainerView, bottomContainerStack, mapView, modeImageView].forEach {
            $0.layer.cornerRadius = 16
        }
    }

    func applyTopContainerStyles() {
        topContainerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }

    func applyBottomContainerStyles() {
        bottomContainerStack.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }

    func bind() {
        vm.$result
            .receive(on: RunLoop.main)
            .sink { result in
                self.configureUI(result: result)
            }.store(in: &subscriptions)
    }

    func configureUI(result: SavedResult) {
        if let mapImageView = result.mapView {
            mapView.image = UIImage(data: mapImageView)
        }

        if let image = result.image {
            imageView.image = UIImage(data: image)
            imageView.contentMode = .scaleAspectFill
        }

        if let modeStr = result.mode, let mode = Mode(rawValue: modeStr) {
            modeImageView.image = UIImage(systemName: mode.image)
        }

        averageSpeedLabel.text = result.averageSpeedString
        topSpeedLabel.text = "\(result.topSpeed)KM/H"
        distanceLabel.text = result.distanceString
        timeLabel.text = result.timeString
        altitudeLabel.text = result.altitudeString
        startAddress.text = result.startAddress
        endAddress.text = result.endAddress
    }
}
