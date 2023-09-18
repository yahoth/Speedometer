//
//  SpeedometerResultCompletionViewController.swift
//  Speedometer
//
//  Created by TAEHYOUNG KIM on 2023/09/10.
//

import UIKit
import MapKit
import Combine
import PhotosUI

class SpeedometerResultCompletionViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var averageSpeedLabel: UILabel!
    @IBOutlet weak var topSpeedLabel: UILabel!
    @IBOutlet weak var altitudeLabel: UILabel!
    @IBOutlet weak var heartRateLabel: UILabel!

    @IBOutlet weak var imageView: UIImageView!
    var vm: SpeedometerViewModel!
    var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        mapView.delegate = self
        setRegion()
        setNavigationBar()
    }

    private func setNavigationBar() {
        self.navigationItem.setHidesBackButton(true, animated: true)
        let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveResultAndDismiss))
        navigationItem.rightBarButtonItem = saveButton

        let deleteButton = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(deleteResultAndDismiss))
        navigationItem.leftBarButtonItem = deleteButton

        let addPhotoButton = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addPhotoButtonTapped))
        navigationItem.rightBarButtonItems = [saveButton, addPhotoButton]

    }

    @objc func deleteResultAndDismiss() {
        self.dismiss(animated: true)
    }

    @objc func saveResultAndDismiss() {
        vm.saveResult()
        self.dismiss(animated: true)
    }

    @objc func addPhotoButtonTapped() {
        addPhoto()
    }

    func addPhoto() {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.preferredAssetRepresentationMode = .current
        config.selection = .ordered
        config.selectionLimit = 1

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    // 출발점과 종착점을 고려하여 MapView의 center, span을 조절
    private func setRegion() {
        let latitudes = vm.allCoordinates.map { $0.latitude }
        let longitudes = vm.allCoordinates.map { $0.longitude }

        let minLat = latitudes.min() ?? 0
        let maxLat = latitudes.max() ?? 0
        let minLon = longitudes.min() ?? 0
        let maxLon = longitudes.max() ?? 0

        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLon + maxLon) / 2)
        vm.span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.3, longitudeDelta: (maxLon - minLon) * 1.3)
        guard let span = vm.span else { return }
        mapView.setRegion(MKCoordinateRegion(center: center, span: span), animated: true)
    }

    private func bind() {
        vm.$allCoordinates
            .receive(on: RunLoop.current)
            .sink { [unowned self] coordinates in
                let lineDraw = MKPolyline(coordinates: vm.allCoordinates, count: vm.allCoordinates.count)
                mapView.addOverlay(lineDraw)
            }.store(in: &subscriptions)

        vm.$span
            .receive(on: RunLoop.current)
            .compactMap { $0 }
            .sink { span in
                self.addCircleOverlay(span: span)
            }.store(in: &subscriptions)

        vm.$speedometerResult
            .receive(on: RunLoop.main)
            .sink { [unowned self] result in
                guard let result else { return }
                self.titleLabel.text = result.title ?? result.defaultTitle
                self.durationLabel.text = result.duration
                self.timeLabel.text = result.timeString
                self.distanceLabel.text = result.distanceString
                self.averageSpeedLabel.text = result.averageSpeedString
                self.topSpeedLabel.text = "\(result.topSpeed)KM/H"
                self.altitudeLabel.text = result.altitudeString
                self.heartRateLabel.text = "0BPM"
            }.store(in: &subscriptions)
        vm.$image
            .receive(on: RunLoop.main)
            .sink { image in
                self.imageView.image = image
            }.store(in: &subscriptions)
    }

    private func addCircleOverlay(span: MKCoordinateSpan) {
        guard let startCoordinate = vm.allCoordinates.first, let endCoordinate = vm.allCoordinates.last else { return }

        let radius = span.latitudeDelta * 0.1 * 111000

        let startCircle = MKCircle(center: startCoordinate, radius: radius) // 반지름 10미터
        let endCircle = MKCircle(center: endCoordinate, radius: radius)
        startCircle.title = "start"
        endCircle.title = "end"
        mapView.addOverlay(startCircle)
        mapView.addOverlay(endCircle)
    }

}

extension SpeedometerResultCompletionViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyLine = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyLine)

            renderer.lineWidth = 5.0
            renderer.alpha = 1.0
            renderer.strokeColor = .blue

            return renderer

        } else if let circleOverlay = overlay as? MKCircle {
            let renderer = MKCircleRenderer(overlay: circleOverlay)

            if circleOverlay.title == "start" {
                renderer.fillColor = UIColor.red.withAlphaComponent(0.1)
                renderer.strokeColor = UIColor.red
            } else if circleOverlay.title == "end" {
                renderer.fillColor = UIColor.blue.withAlphaComponent(0.1)
                renderer.strokeColor = UIColor.blue
            }
            renderer.lineWidth = 1

            return renderer

        } else {
            return MKOverlayRenderer()
        }
    }
}

extension SpeedometerResultCompletionViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        let itemProvider = results.first?.itemProvider

        picker.dismiss(animated: true, completion: nil)

        if let itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                if let image = image as? UIImage {
                    self.vm.image = image
                }
            }
        }
    }
}
