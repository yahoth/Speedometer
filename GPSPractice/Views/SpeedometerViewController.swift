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
    @IBOutlet weak var durationLabel: UILabel!
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

    }
    private func setupMenu() {
        let start = UIAction(title: "start", image: UIImage(systemName: "play.fill"), handler: { _ in self.vm.startTracking() })
        let pause = UIAction(title: "pause", image: UIImage(systemName: "pause.fill"), handler: { _ in self.vm.pauseTracking() })
        let stop  = UIAction(title: "stop", image: UIImage(systemName: "stop.fill")) { _ in
            self.vm.stopTracking()
            let sb = UIStoryboard(name: "Result", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "ResultViewController") as! ResultViewController
            vc.allCoordinates = self.vm.allCoordinates
            self.navigationController?.pushViewController(vc, animated: true)
        }

        menuButton.menu = UIMenu(title: "hello", image: nil, identifier: nil, options: .displayInline, children: [start, pause, stop])
        menuButton.showsMenuAsPrimaryAction = true
    }

    private func configureUI() {
        
    }

    private func bind() {
        vm.currentSpeed
            .subscribe(on: DispatchQueue.global())
            .map { round($0 * 10) / 10 }
            .receive(on: RunLoop.main)
            .sink { [unowned self] speed in
                self.currentSpeedLabel.text = speed == 0.0 ? "0" : "\(speed)"
            }.store(in: &subscriptions)

        vm.averageSpeedPublisher
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

        vm.topSpeed
            .receive(on: RunLoop.main)
            .sink { speed in
                self.topSpeedLabel.text = "\(speed)"
            }.store(in: &subscriptions)

        vm.$alititude
            .sink { altitude in
                self.altitudeLabel.text = "\(altitude)M"
            }.store(in: &subscriptions)

        vm.stopwatch.$totalElapsedTime
            .receive(on: RunLoop.main)
            .sink { [unowned self] time in
                let hours = time / 3600
                let minutes = (time % 3600) / 60
                let seconds = (time % 3600) % 60

                self.durationLabel.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
            }.store(in: &subscriptions)
    }
}

//3분에 5.35 평속 약 100

//거 속 시
/// 거리 = 속 * 시
/// 5.35 = 5초를 시간으로
///
///
