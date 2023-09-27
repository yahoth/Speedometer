//
//  StatisticsRowCell.swift
//  Speedometer
//
//  Created by TAEHYOUNG KIM on 2023/09/21.
//

import UIKit

class StatisticsRowCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var modeImageView: UIImageView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var startAddress: UILabel!
    @IBOutlet weak var endAddress: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }

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
        startAddress.text = item.startAddress
        endAddress.text = item.endAddress
        modeImageView.layer.cornerRadius = 16
        if let modeStr = item.mode, let mode = Mode(rawValue: modeStr) {
            modeImageView.image = UIImage(systemName: mode.image)
        }
        containerView.layer.cornerRadius = 16
        distanceLabel.text = item.distanceString
    }

}
