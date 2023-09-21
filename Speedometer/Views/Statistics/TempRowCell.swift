//
//  TempRowCell.swift
//  Speedometer
//
//  Created by TAEHYOUNG KIM on 2023/09/21.
//

import UIKit

class TempRowCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var modeImageView: UIImageView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var startAddress: UILabel!
    @IBOutlet weak var endAddress: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(item: SavedResult) {
        startAddress.text = item.startAddress
        endAddress.text = item.endAddress
        modeImageView.layer.cornerRadius = 16
        containerView.layer.cornerRadius = 16
        distanceLabel.text = item.distanceString
    }

}
