//
//  SpeedometerViewController.swift
//  GPSPractice
//
//  Created by TAEHYOUNG KIM on 2023/09/07.
//

import UIKit
import Combine

class SpeedometerViewController: UIViewController {

    @IBOutlet weak var currentSpeedLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var averageSpeedLabel: UILabel!
    @IBOutlet weak var topSpeedLabel: UILabel!
    @IBOutlet weak var altitudeLabel: UILabel!
    @IBOutlet weak var heartRateLabel: UILabel!

    @IBOutlet weak var menuButton: UIButton!
    
    var vm: SpeedometerViewModel!
    var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        vm = SpeedometerViewModel()
        vm.startTracking()
        bind()
        setupMenu()
        menuButton.layer.cornerRadius = 8
        vm.startDate = Date()
    }

    private func setupMenu() {
        let start = UIAction(title: "start", image: UIImage(systemName: "play.fill"), handler: { [weak self] _ in self?.vm.startTracking() })
        let pause = UIAction(title: "pause", image: UIImage(systemName: "pause.fill"), handler: { [weak self] _ in self?.vm.pauseTracking() })
        let stop  = UIAction(title: "stop", image: UIImage(systemName: "stop.fill")) { [weak self] _ in
            self?.vm.stopTracking()
            self?.vm.createSpeedometerResult()

            let sb = UIStoryboard(name: "SpeedometerResultCompletion", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "SpeedometerResultCompletionViewController") as! SpeedometerResultCompletionViewController
            vc.vm = self?.vm
            self?.navigationController?.pushViewController(vc, animated: true)
        }

        menuButton.menu = UIMenu(title: "hello", image: nil, identifier: nil, options: .displayInline, children: [start, pause, stop])
        menuButton.showsMenuAsPrimaryAction = true
    }

    private func bind() {
        vm.currentSpeed
            .receive(on: RunLoop.main)
            .sink { [unowned self] speed in
                self.currentSpeedLabel.text = speed == 0.0 ? "0" : "\(speed)"
            }.store(in: &subscriptions)

        vm.$averageSpeed
            .receive(on: RunLoop.main)
            .sink { [unowned self ] averageSpeed in
                self.averageSpeedLabel.text = averageSpeed.isNaN ? "0" : "\(averageSpeed)"
            }.store(in: &subscriptions)

        vm.$totalDistance
            .receive(on: RunLoop.main)
            .sink { [unowned self] distance in
                switch distance {
                case 0..<1000:
                    self.distanceLabel.text = "\(Int(round(distance)))M"
                case 1000...:
                    self.distanceLabel.text = "\((round(distance / 10) / 100))KM"
                default:
                    break
                }
            }.store(in: &subscriptions)

        vm.$topSpeed
            .receive(on: RunLoop.main)
            .sink { speed in
                self.topSpeedLabel.text = "\(speed)"
            }.store(in: &subscriptions)

        vm.$alititude
            .receive(on: RunLoop.main)
            .sink { altitude in
                self.altitudeLabel.text = "\(Int(round(altitude)))M"
            }.store(in: &subscriptions)

        vm.stopwatch.$totalElapsedTime
            .receive(on: RunLoop.main)
            .sink { [unowned self] time in
                let hours = time / 3600
                let minutes = (time % 3600) / 60
                let seconds = (time % 3600) % 60

                self.timeLabel.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
            }.store(in: &subscriptions)
    }
}
