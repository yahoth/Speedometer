//
//  HomeViewController.swift
//  GPSPractice
//
//  Created by TAEHYOUNG KIM on 2023/09/07.
//

import UIKit
import Combine

enum Mode: String, CaseIterable {
    case cycling
    case hiking
    case running
    case driving

    var image: String {
        switch self {
        case .cycling:
            return "figure.outdoor.cycle"
        case .hiking:
            return "figure.hiking"
        case .driving:
            return "car.fill"
        case .running:
            return "figure.run"
        }
    }

    var title: String {
        self.rawValue.capitalized
    }
}

class HomeViewController: UIViewController {

    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var modeImageView: UIImageView!
    @IBOutlet weak var modeLabel: UILabel!

    let modeButton: CustomCardButton = {
        let button = CustomCardButton()
        button.backgroundColor = .lightGray
        button.layer.cornerRadius = 16
        button.isUserInteractionEnabled = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    var subscriptions = Set<AnyCancellable>()
    var vm: HomeViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        vm = HomeViewModel()
        setConstraints()
        setupMenu()
        bind()
        configure()
    }

    private func configure() {
        startButton.layer.borderWidth = 10
        startButton.layer.borderColor = UIColor.label.cgColor
    }

    private func setConstraints() {
        view.addSubview(modeButton)

        NSLayoutConstraint.activate([
            modeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            modeButton.topAnchor.constraint(equalTo: startButton.bottomAnchor, constant: 20),
            modeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            modeButton.leadingAnchor.constraint(equalTo: startButton.leadingAnchor)
        ])
    }

    private func updateModeCardView(mode: Mode) {
        modeButton.cardLabel.text = mode.title
        modeButton.cardImage.image = UIImage(systemName: mode.image)
    }

    private func setupMenu() {
        let modes = Mode.allCases.map { mode in
            UIAction(title: mode.title, image: UIImage(systemName: mode.image)) { [weak self] _ in
                self?.vm.updateMode(mode)
            }
        }
        modeButton.menu = UIMenu(title: "Mode", image: nil, identifier: nil, options: .displayInline, children: modes)
        modeButton.showsMenuAsPrimaryAction = true
    }

    private func bind() {
        vm.$mode
            .receive(on: DispatchQueue.main)
            .sink { mode in
                self.updateModeCardView(mode: mode)
            }.store(in: &subscriptions)
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

