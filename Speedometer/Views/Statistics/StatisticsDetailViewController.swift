//
//  StatisticsDetailViewController.swift
//  Speedometer
//
//  Created by TAEHYOUNG KIM on 2023/09/14.
//

import UIKit
import Combine

class StatisticsDetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var mapView: UIImageView!

    @IBOutlet weak var averageSpeedLabel: UILabel!
    @IBOutlet weak var topSpeedLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    @IBOutlet weak var averageView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var distanceView: UIView!
    @IBOutlet weak var durationView: UIView!

    var vm: StatisticsDetailViewModel!
    var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewRadius()
        bind()
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

        averageSpeedLabel.text = result.averageSpeedString
        topSpeedLabel.text = "\(result.topSpeed)"
        distanceLabel.text = result.distanceString
        timeLabel.text = result.timeString
    }

    func configureViewRadius() {
        [averageView, topView, distanceView, durationView].forEach { view in
            view?.layer.cornerRadius = 8
            view?.backgroundColor = .gray.withAlphaComponent(0.5)
        }
    }
}
