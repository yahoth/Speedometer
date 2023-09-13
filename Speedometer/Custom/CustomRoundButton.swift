//
//  CustomRoundButton.swift
//  Speedometer
//
//  Created by TAEHYOUNG KIM on 2023/09/13.
//

import UIKit

class CustomButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderWidth = 10
        self.layer.borderColor = UIColor.label.cgColor
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateCornerRadius()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        // 현재 trait collection에 따라 borderColor 업데이트
        switch traitCollection.userInterfaceStyle {
        case .light, .unspecified:
            self.layer.borderColor = UIColor.label.cgColor
        case .dark:
            self.layer.borderColor = UIColor.label.cgColor
        @unknown default:
            break
        }
    }

    private func updateCornerRadius() {
        let buttonSize = min(bounds.width, bounds.height)
        layer.cornerRadius = buttonSize / 2
        clipsToBounds = true
    }

    override var isHighlighted: Bool {
        didSet {
            // 버튼이 highlighted 됐을 때 색상 변경
            backgroundColor = isHighlighted ? .darkGray : .clear

            // 버튼이 highlighted 됐을 때 scale 변경
            if isHighlighted {
                UIView.animate(withDuration: 0.3) {
                    self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                }
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.transform = CGAffineTransform.identity
                }
            }
        }
    }
}
