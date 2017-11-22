//
//  SensorListViewController.swift
//  ocf-sample
//
//  Created by Brian Giori on 9/6/17.
//  Copyright © 2017 Brian Giori. All rights reserved.
//

import UIKit
import CoreBluetooth


class SensorListViewController: UIViewController, BluetoothManagerDelegate, SensorsTableViewDelegate {
    
    @IBOutlet weak var sensorsTableView: SensorsTableView!
    @IBOutlet weak var sensorsTableViewHeight: NSLayoutConstraint!
    

    // MARK: - Properties
    
    // User selected sensor to send to next View Controller
    var selectedSensor: MynewtSensor!
    
    // Bluetooth
    var centralManager: CBCentralManager?
    var peripherals = [String: CBPeripheral]()
    var bluetoothManager: BluetoothManager!
    
    //MARK: - View Controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Start bluetoothManager
        bluetoothManager = BluetoothManager()
        bluetoothManager.addDelegate(self)
        
        sensorsTableView.delegate = sensorsTableView
        sensorsTableView.dataSource = sensorsTableView
        sensorsTableView.sensorsDelegate = self
        sensorsTableView.heightConstraint = sensorsTableViewHeight
                
        // Give Iotivity time to set up it's internal BLE client
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1), execute: {
            // Perform Multicast discovery over IP
//            IotivityClient.shared().discoverMulticast(CT_ADAPTER_IP, callback: self.discoverCallback)
            // Start scanning
            self.bluetoothManager.startScan()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Bluetooth Manager
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {

    }
    
    func didScanPeripheral(_ peripheral: CBPeripheral) {
        peripherals.updateValue(peripheral, forKey: peripheral.identifier.uuidString)
        printLog("Peripheral found: name=\(peripheral.name ?? "Unknown"), id=\(peripheral.identifier.uuidString)")
        printLog("Discovering resources for new OCF host...")
        IotivityClient.shared().discoverUnicast(peripheral.identifier.uuidString, connType:CT_ADAPTER_GATT_BTLE, qos:OC_LOW_QOS, callback:discoverCallback)
    }
    
    func didDisconnectPeripheral(_ peripheral: CBPeripheral) {
        printLog("didDisconnectPeripheral")
    }
    
    // MARK: - Iotivity Callbacks
    
    // Discovery callback. This will be called every time a new OCF hosts is discovered.
    lazy var discoverCallback: DiscoverCallback = { [unowned self] (resources: [OcResource]!) in
        self.printLog("Resources discovered!")
        // Loop through and log each discovered resource
        for resource in resources {
            
            self.printLog(resource.description);
            ResourceManager.putResource(resource)
            if MynewtSensor.isMynewtSensor(resource: resource) {
                var mynewtSensor = MynewtSensor(resource: resource, peripheral: self.bluetoothManager.getScannedPeripheral(address: resource.address))
                self.sensorsTableView.add(mynewtSensor)
            }
        }
    }
    
    // GET Callback
    lazy var getCallback: GetCallback = { [unowned self] (representation: OcRepresentation?) in
        // Check for an Iotivity stack error
        if (representation?.result.rawValue)! > OC_STACK_RESOURCE_CHANGED.rawValue {
            self.printLog("GET Callback - Iotivity Error: \(representation!.result)", withTransport: representation?.ocDevAddr.adapter)
            return
        }
        // Get values from the resource's representation
        if let values = representation?.values {
            
        } else {
            self.printLog("GET Callback - representation does not contain any values", withTransport: representation?.ocDevAddr.adapter)
        }
    }
    
    // OBSERVE Callback
    lazy var observeCallback: ObserveCallback = { [unowned self] (representation: OcRepresentation?) in
        // Check for an Iotivity stack error. Error codes start after OC_STACK_RESOURCE_CHANGED (4).
        if (representation?.result.rawValue)! > OC_STACK_RESOURCE_CHANGED.rawValue {
            self.printLog("OBSERVE Callback - Iotivity Error: \(representation!.result)", withTransport: representation?.ocDevAddr.adapter)
            return
        }
        // Get values from the resource's representation
        if let values = representation?.values {
            
        } else {
            self.printLog("OBSERVE Callback - representation does not contain any values", withTransport: representation?.ocDevAddr.adapter)
        }
    }
    
    //PUT CALLBACK
    lazy var putCallback: PutCallback = { [unowned self] (representation: OcRepresentation?) in
        // Check for an Iotivity stack error
        if (representation?.result.rawValue)! > OC_STACK_RESOURCE_CHANGED.rawValue {
            self.printLog("PUT Callback - Iotivity Error: \(representation!.result)", withTransport: representation?.ocDevAddr.adapter)
            return
        }
        self.printLog("PUT Callback - Success.", withTransport: representation?.ocDevAddr.adapter)
    }
    
    // MARK: - Logging Function
    func printLog(_ text:String, withTransport: OCTransportAdapter? = nil) {
        print(text)
//        var transport = ""
//        if withTransport == OC_ADAPTER_IP {
//            transport = "IP: "
//        } else if withTransport == OC_ADAPTER_GATT_BTLE {
//            transport = "BLE: "
//        }
//        self.log.text.append("\(transport)\(text)\n")
    }
    
    // MARK: - Navigation
    
    func didSelectSensor(sensor: MynewtSensor) {
        selectedSensor = sensor
        performSegue(withIdentifier: "sensorSelected", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let sensorViewController = segue.destination as? SensorViewController {
            sensorViewController.selectedSensor = selectedSensor
        }
    }

}

