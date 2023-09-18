//
//  StatisticsRowCell.swift
//  Speedometer
//
//  Created by TAEHYOUNG KIM on 2023/09/12.
//

import UIKit

class StatisticsRowCell: UITableViewCell {
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!

    override func layoutSubviews() {
        super.layoutSubviews()
        if let thumbnailImageView {
            updateCornerRadius(thumbnailImageView)
        }
        updateCornerRadius(view)
    }

    private func updateCornerRadius(_ view: UIView) {
        let viewSize = min(view.bounds.width, view.bounds.height)
        view.layer.cornerRadius = viewSize * 0.1
        view.clipsToBounds = true
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)

        if highlighted {
            UIView.animate(withDuration: 0.1) { [weak self] in
                self?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }
        } else {
            UIView.animate(withDuration: 0.1) { [weak self] in
                self?.transform = CGAffineTransform.identity
            }
        }
    }

    func configure(item: SavedResult) {
//        self.view.layer.cornerRadius = 16
        self.view.backgroundColor = .label
        titleLabel.text = item.title ?? item.defaultTitle
        let dynamicColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
            return traitCollection.userInterfaceStyle == .dark ? .black : .white
        }
        titleLabel.textColor = dynamicColor
        if let image = item.image {
            thumbnailImageView.image = UIImage(data: image)
            thumbnailImageView.contentMode = .scaleAspectFill
//            thumbnailImageView.layer.cornerRadius = 16
        }
    }
}
