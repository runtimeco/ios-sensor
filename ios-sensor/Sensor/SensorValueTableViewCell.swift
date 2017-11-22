//
//  SensorValueTableViewCell.swift
//  ios-sensor
//
//  Created by Brian Giori on 11/20/17.
//  Copyright © 2017 Brian Giori. All rights reserved.
//

import UIKit

protocol SensorValueCellDelegate {
    func didToggleSwitch(indexPath: IndexPath, isChecked: Bool)
}

class SensorValueTableViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var value: UILabel!
    @IBOutlet weak var units: UILabel!
    @IBOutlet weak var chartIcon: UIImageView!
    @IBOutlet weak var chartSwitch: UISwitch!
    
    var delegate: SensorValueCellDelegate!
    var indexPath: IndexPath!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        chartIcon.image = #imageLiteral(resourceName: "ic_timeline_black_24px")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func chartToggle(_ sender: UISwitch) {
        delegate?.didToggleSwitch(indexPath: indexPath, isChecked: sender.isOn)
    }
    
}
