//
//  StatisticsRowCell.swift
//  Speedometer
//
//  Created by TAEHYOUNG KIM on 2023/09/12.
//

import UIKit

class StatisticsRowCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!

    func configure(item: SavedResult) {
        self.layer.cornerRadius = 20

        titleLabel.text = item.title
        if let image = item.image {
            thumbnailImageView.image = UIImage(data: image)
            thumbnailImageView.contentMode = .scaleAspectFill
        }
    }
    
}
