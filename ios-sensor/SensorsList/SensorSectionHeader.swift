//
//  SensorSectionHeader.swift
//  ios-sensor
//
//  Created by Brian Giori on 11/18/17.
//  Copyright © 2017 Brian Giori. All rights reserved.
//

import UIKit

class SensorSectionHeader: UITableViewCell {
    
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var icon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
