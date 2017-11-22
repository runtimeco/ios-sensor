//
//  SensorsTableView.swift
//  ios-sensor
//
//  Created by Brian Giori on 11/17/17.
//  Copyright © 2017 Brian Giori. All rights reserved.
//

import UIKit

struct MynewtSensorHost {
    var name: String
    var adapter: OCTransportAdapter
    var address: String
    var bleAdvertisedName: String
}

protocol SensorsTableViewDelegate {
    func didSelectSensor(sensor: MynewtSensor)
}

class SensorsTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
    
    var heightConstraint: NSLayoutConstraint?
    
    var sectionHeaders = [MynewtSensorHost]()
    var sensorResources = [[MynewtSensor]]()
    var sensorsDelegate: SensorsTableViewDelegate?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sensorResources.isEmpty {
            return 0
        }
        return sensorResources[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionHeaders.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sensorsDelegate?.didSelectSensor(sensor: sensorResources[indexPath.section][indexPath.row])
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
        
        let sensorHost = sectionHeaders[section]
        if sensorHost.adapter == OC_ADAPTER_IP {
            cell.icon.image = #imageLiteral(resourceName: "ic_wifi_black_24px")
        } else if sensorHost.adapter == OC_ADAPTER_GATT_BTLE {
            cell.icon.image = #imageLiteral(resourceName: "ic_bluetooth_black_36px")
        }
        cell.title.text = sensorHost.name
        if sensorHost.adapter == OC_ADAPTER_IP {
            cell.subtitle.text = "Host: \(sensorHost.address)"
        } else if sensorHost.adapter == OC_ADAPTER_GATT_BTLE {
            cell.subtitle.text = "Host: \(sensorHost.bleAdvertisedName) - \(sensorHost.address)"
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
        } else if indexPath.row >= sensorResources[indexPath.section].count {
            print("index out of bounds")
            return cell
        }

        let sensorResource = sensorResources[indexPath.section][indexPath.row]
        cell.name.text = MynewtSensor.getReadableName(resource: sensorResource.resource)
        return cell
    }

    func add(_ element: MynewtSensor) {
        synced(self, closure: {
            if !MynewtSensor.isMynewtSensor(resource: element.resource) {
                return
            }
            // Get host sensor from uri
            let sensorHostHeader = MynewtSensorHost(name: getHostSensor(sensor: element), adapter: element.resource.adapterType, address: element.resource.address, bleAdvertisedName: element.peripheral?.name ?? "Unknown")
            if let section = sectionHeaders.index(where: { $0.address == sensorHostHeader.address && $0.adapter == sensorHostHeader.adapter && $0.bleAdvertisedName == sensorHostHeader.bleAdvertisedName && $0.name == sensorHostHeader.name}) {
                if !(sensorResources[section].contains(where: { $0.resource.isEqual(to: element.resource) })) {
                    sensorResources[section].append(element)
                    updateConstraints()
                    reloadData()
                    updateConstraints()
                } else {
                }
            } else {
                if sectionHeaders.count == sensorResources.count {
                    sectionHeaders.append(sensorHostHeader)
                    sensorResources.append([element])
                    updateConstraints()
                    reloadData()
                    updateConstraints()
                } else {
                    NSLog("ERROR: Sensor Table View internal arrays are offset")
                }
            }
        })
    }
    
//    private func update(_ element: MynewtSensor) {
//        for (index, elementInList) in sensorResources.enumerated() {
//            if elementInList.resource.isEqual(to: element.resource) {
//                sensorResources[index] = element
//                updateConstraints()
//                reloadData()
//                updateConstraints()
//                return
//            }
//        }
//    }
    
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
    
    func getHostSensor(sensor: MynewtSensor) -> String {
        return String(sensor.resource.uri.split(separator: "/", maxSplits: 1, omittingEmptySubsequences: true)[0])
    }
    
    
    //============================================
    // Sensor Manager
    //============================================

//    static func getSensorsForAddress(_ address: String) -> [String:OcResource]? {
//        return resources[address]
//    }
//
//    static func getResourceWithAddress(_ address: String, andUri: String) -> OcResource?{
//        return resources[address]?[andUri]
//    }
//
//    /// Put an OcResource into the dictionary
//    static func putResource(_ resource: OcResource) {
//        if var resDictForAddr = resources[resource.address] {
//            resDictForAddr.updateValue(resource, forKey: resource.uri)
//        } else {
//            var resDictForAddr = [String:OcResource]()
//            resDictForAddr.updateValue(resource, forKey: resource.uri)
//            resources.updateValue(resDictForAddr, forKey: resource.address)
//        }
//    }
    
    // MARK: - Synchronization Helper
    func synced(_ lock: Any, closure: () -> ()) {
        objc_sync_enter(lock)
        closure()
        objc_sync_exit(lock)
    }
}
