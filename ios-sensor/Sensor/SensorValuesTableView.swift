//
//  SensorValuesTableView.swift
//  ios-sensor
//
//  Created by Brian Giori on 11/20/17.
//  Copyright © 2017 Brian Giori. All rights reserved.
//

import UIKit

class SensorValuesTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
    
    var heightConstraint: NSLayoutConstraint?
    var cellDelegate: SensorValueCellDelegate?
    
    // Task stats
    var sensorValues = [MynewtSensorValue]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sensorValues.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = cellForRow(at: indexPath)
        cell?.isSelected = false
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "SensorValueTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? SensorValueTableViewCell else {
            fatalError("The dequeued cell is not an instance of SensorValueTableViewCell")
        }
        if indexPath.row >= sensorValues.count {
            print("index out of bounds")
            return cell
        }
        
        let sensorValue = sensorValues[indexPath.row]
        cell.name.text = sensorValue.name
        cell.value.text = sensorValue.valueStr
        cell.units.text = sensorValue.units
        // Set switch delegate and index for toggling data sets
        cell.delegate = cellDelegate
        cell.indexPath = indexPath
        return cell
    }
    
    func updateElement(_ element: MynewtSensorValue) {
        let snsrIdx = sensorValues.index(where: { $0.name == element.name })
        if snsrIdx == nil {
            sensorValues.append(element)
        } else {
            sensorValues[snsrIdx!] = element
        }
        updateConstraints()
        reloadData()
        updateConstraints()
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        layoutIfNeeded()
        UIView.animate(withDuration: 0.2, animations: {
            if self.contentSize.height == 0 {
                self.heightConstraint?.constant = self.contentSize.height
                var newFrame = self.frame
                newFrame.size.height = self.contentSize.height
                self.frame = newFrame
            } else {
                self.heightConstraint?.constant = self.contentSize.height - 1.0
                var newFrame = self.frame
                newFrame.size.height = self.contentSize.height - 1.0
                self.frame = newFrame
            }
        })
    }

}
