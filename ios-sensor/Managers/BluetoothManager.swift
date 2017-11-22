//
//  BluetoothManager.swift
//  mobilegateway
//
//  Created by Brian Giori on 10/23/17.
//  Copyright © 2017 Brian Giori. All rights reserved.
//

import Foundation
import CoreBluetooth

class BluetoothManager: NSObject, CBCentralManagerDelegate {
    
    var centralManager: CBCentralManager!
    var scannedPeripherals = [String: CBPeripheral]()
    var delegates = [BluetoothManagerDelegate]()
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Bluetooth Manager: centralManagerDidUpdateState - \(central.state.rawValue)")
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Bluetooth Manager: didDiscoverPeripheral - \(peripheral)")
        scannedPeripherals.updateValue(peripheral, forKey: peripheral.identifier.uuidString)
        for delegate in delegates {
            delegate.didScanPeripheral(peripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Bluetooth Manager: didDisconnectPeripheral - \(peripheral.name!), \(peripheral.identifier.uuidString)")
        _ = removeScannedPeripheral(address: peripheral.identifier.uuidString)
        for delegate in delegates {
            delegate.didDisconnectPeripheral(peripheral)
        }
    }
    
    // Add delegate
    func addDelegate(_ delegate: BluetoothManagerDelegate) {
        delegates.append(delegate)
    }
    
    // Getters
    func getScannedPeripherals() -> [String: CBPeripheral] {
        return scannedPeripherals
    }
    func getScannedPeripheral(address: String) -> CBPeripheral? {
        return scannedPeripherals[address]
    }
    
    // Remove
    func removeScannedPeripheral(address: String) -> CBPeripheral? {
        if let peripheral = getScannedPeripheral(address: address) {
            centralManager.cancelPeripheralConnection(peripheral)
        }
        return scannedPeripherals.removeValue(forKey: address)
    }
    
    
    // Actions
    func connectPeripheal(_ peripheral: CBPeripheral) {
        centralManager.connect(peripheral, options: nil)
    }
    func disconnectPeripheral(_ peripheral: CBPeripheral) {
        centralManager.cancelPeripheralConnection(peripheral)
    }
    func startScan() {
        centralManager.scanForPeripherals(withServices: [CBUUID(string: IOTIVITY_UUID)], options: nil)
    }
    func stopScan() {
        centralManager.stopScan()
    }
    
    // Utils
    func printScannedPeripherals() {
        print("BluetoothManager: printing scanned peripherals")
        for (address, peripheral) in scannedPeripherals {
            print("\(peripheral.name ?? "Unknown")\t - \(address)")
        }
    }
}

protocol BluetoothManagerDelegate {
    func didScanPeripheral(_ peripheral: CBPeripheral)
    func didDisconnectPeripheral(_ peripheral: CBPeripheral)
}
