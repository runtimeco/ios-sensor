//
//  SmartDeviceTableView.swift
//  ios-sensor
//
//  Created by Brian Giori on 11/21/17.
//  Copyright © 2017 Brian Giori. All rights reserved.
//

import UIKit

protocol SmartDeviceTableViewDelegate {
    func didSelectDevice(resource: OcResource)
}

struct SmartDeviceHost {
    var name: String
    var adapter: OCTransportAdapter
    var address: String
    var bleAdvertisedName: String?
}

class SmartDeviceTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
    
    let OIC_RT_BINARY_SWITCH = "oic.r.switch.binary"

    var heightConstraint: NSLayoutConstraint?
    
    var sectionHeaders = [SmartDeviceHost]()
    var smartDeviceResources = [[OcResource]]()
    var deviceDelegate: SmartDeviceTableViewDelegate?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if smartDeviceResources.isEmpty {
            return 0
        }
        return smartDeviceResources[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionHeaders.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        deviceDelegate?.didSelectDevice(resource: smartDeviceResources[indexPath.section][indexPath.row])
        let cell = cellForRow(at: indexPath)
        cell?.isSelected = false
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if sectionHeaders.isEmpty {
            return nil
        }
        let cellIdentifier = "SensorSectionHeader"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? SensorSectionHeader else {
            fatalError("The dequeued cell is not an instance of SensorTableViewCell")
        }
        
        if section >= sectionHeaders.count  {
            print("index out of bounds")
            return cell
        }
        
        let deviceHost = sectionHeaders[section]
        if deviceHost.adapter == OC_ADAPTER_IP {
            cell.icon.image = #imageLiteral(resourceName: "ic_wifi_black_24px")
        } else if deviceHost.adapter == OC_ADAPTER_GATT_BTLE {
            cell.icon.image = #imageLiteral(resourceName: "ic_bluetooth_black_36px")
        }
        
        cell.title.text = deviceHost.name
        if deviceHost.adapter == OC_ADAPTER_IP {
            cell.subtitle.text = deviceHost.address
        } else if deviceHost.adapter == OC_ADAPTER_GATT_BTLE {
            cell.subtitle.text = "Address: \(deviceHost.address)"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "SensorTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? SensorTableViewCell else {
            fatalError("The dequeued cell is not an instance of SensorTableViewCell")
        }
        if indexPath.section >= sectionHeaders.count  {
            print("index out of bounds")
            return cell
        } else if indexPath.row >= smartDeviceResources[indexPath.section].count {
            print("index out of bounds")
            return cell
        }
        
        let resource = smartDeviceResources[indexPath.section][indexPath.row]
        if resource.resourceTypes.contains(OIC_RT_BINARY_SWITCH) {
            cell.name.text = "Light"
        } else {
            return cell
        }
        return cell
    }
    
    func add(_ element: OcResource) {
        synced(self, closure: {
            var sensorHostHeader: SmartDeviceHost!
            
            // Create a SmartDeviceHostHeader based on the element's adapterType
            if element.adapterType == OC_ADAPTER_GATT_BTLE {
                let bleName = BluetoothManager.getInstance().getScannedPeripheral(address: element.address)?.name ?? "Unknown"
                sensorHostHeader = SmartDeviceHost(name: bleName, adapter: element.adapterType, address: element.address, bleAdvertisedName: bleName)
            } else { // IP Adapter
                sensorHostHeader = SmartDeviceHost(name: element.address, adapter: element.adapterType, address: "N/A", bleAdvertisedName: nil)
            }
            
            if let section = sectionHeaders.index(where: { $0.address == sensorHostHeader.address && $0.adapter == sensorHostHeader.adapter && $0.bleAdvertisedName == sensorHostHeader.bleAdvertisedName && $0.name == sensorHostHeader.name}) {
                if !(smartDeviceResources[section].contains(where: { $0.isEqual(to: element) })) {
                    smartDeviceResources[section].append(element)
                    updateConstraints()
                    reloadData()
                    updateConstraints()
                } else {
                }
            } else {
                if sectionHeaders.count == smartDeviceResources.count {
                    sectionHeaders.append(sensorHostHeader)
                    smartDeviceResources.append([element])
                    updateConstraints()
                    reloadData()
                    updateConstraints()
                } else {
                    NSLog("ERROR: Sensor Table View internal arrays are offset")
                }
            }
        })
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
    
    // MARK: - Synchronization Helper
    func synced(_ lock: Any, closure: () -> ()) {
        objc_sync_enter(lock)
        closure()
        objc_sync_exit(lock)
    }
}
