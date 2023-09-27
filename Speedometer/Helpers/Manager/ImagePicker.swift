//
//  ImagePicker.swift
//  Speedometer
//
//  Created by TAEHYOUNG KIM on 2023/09/26.
//

import UIKit
import Combine
import PhotosUI

class ImagePicker: NSObject, PHPickerViewControllerDelegate {
    let selectedImagePublisher = PassthroughSubject<UIImage?, Never>()

    weak var viewController: UIViewController?

    func presentPhotoPicker(from viewController: UIViewController) {
        self.viewController = viewController

        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.preferredAssetRepresentationMode = .current
        config.selectionLimit = 1

        let pickerVC = PHPickerViewController(configuration: config)

        pickerVC.delegate = self

        viewController.present(pickerVC, animated:true)
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        let itemProvider = results.first?.itemProvider

        picker.dismiss(animated: true, completion: nil)

        if let itemProvider = itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                DispatchQueue.main.async {
                    self?.selectedImagePublisher.send(image as? UIImage)
                }
            }
        } else {
            DispatchQueue.main.async {
                self.selectedImagePublisher.send(nil)
            }
        }
    }
}
