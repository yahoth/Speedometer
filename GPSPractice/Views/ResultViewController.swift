//
//  ResultViewController.swift
//  GPSPractice
//
//  Created by TAEHYOUNG KIM on 2023/09/05.
//

import UIKit
import MapKit
import Combine

class ResultViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @Published var allCoordinates: [CLLocationCoordinate2D]!
    @Published var span: MKCoordinateSpan = MKCoordinateSpan()
    var subscriptions = Set<AnyCancellable>()
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        mapView.delegate = self
        setRegion()
    }
    @IBAction func xButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }

    private func setRegion() {
        let latitudes = allCoordinates.map { $0.latitude }
        let longitudes = allCoordinates.map { $0.longitude }

        let minLat = latitudes.min() ?? 0
        let maxLat = latitudes.max() ?? 0
        let minLon = longitudes.min() ?? 0
        let maxLon = longitudes.max() ?? 0

        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLon + maxLon) / 2)
        self.span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.3, longitudeDelta: (maxLon - minLon) * 1.3)

        mapView.setRegion(MKCoordinateRegion(center: center, span: self.span), animated: true)
    }

    private func bind() {
        $allCoordinates.receive(on: RunLoop.current)
            .sink { [unowned self] coordinates in
                let lineDraw = MKPolyline(coordinates: self.allCoordinates, count: self.allCoordinates.count)
                mapView.addOverlay(lineDraw)
            }.store(in: &subscriptions)

        $span.receive(on: RunLoop.current)
            .sink { span in
                self.addCircleOverlay(span: span)
            }.store(in: &subscriptions)
    }

    private func addCircleOverlay(span: MKCoordinateSpan) {
        guard let startCoordinate = allCoordinates.first, let endCoordinate = allCoordinates.last else { return }

        let radius = span.latitudeDelta * 0.1 * 111000

        let startCircle = MKCircle(center: startCoordinate, radius: radius) // 반지름 10미터
        let endCircle = MKCircle(center: endCoordinate, radius: radius)
        startCircle.title = "start"
        endCircle.title = "end"
        mapView.addOverlay(startCircle)
        mapView.addOverlay(endCircle)
    }

}

extension ResultViewController: MKMapViewDelegate {
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

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("region changed")
    }
//// CustomPin 생성
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        guard let annotation = annotation as? CustomAnnotation else { return nil }
//
//        let identifier = "CustomPin"
//        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
//
//        if annotationView == nil {
//            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
//
//            if annotation.isStartPoint {
//                let startImage = UIImage(named: "avocado")
//                annotationView?.image = startImage
//                annotationView?.frame.size = CGSize(width: 30, height: 30)
////                imageView.frame.size =
//
//            } else {
//                let endImage = UIImage(named: "avocado")
//                annotationView?.image = endImage
//            }
//        } else {
//            annotationView?.annotation = annotation
//        }
//
//        return annotationView
//    }

}
