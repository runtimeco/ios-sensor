//
//  SensorViewController.swift
//  ios-sensor
//
//  Created by Brian Giori on 11/20/17.
//  Copyright © 2017 Brian Giori. All rights reserved.
//

import UIKit

class SensorViewController: UIViewController, MynewtSensorDelegate, SensorValueCellDelegate {

    

    @IBOutlet weak var chartContainer: MynewtSensorLineChartView!
    @IBOutlet weak var sensorValuesTable: SensorValuesTableView!
    @IBOutlet weak var sensorValuesTableHeight: NSLayoutConstraint!
    
    // Observe States
    let NOT_OBSERVING = 0
    let OBSERVING = 1
    let OBSERVE_PENDNG = 3
    let CANCELLING_OBSERVE = 2
    
    var observeToggleBtn: UIBarButtonItem!
    var selectedSensor: MynewtSensor!
    var observeState = 1 // Start in the observing state
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let readableSensorName = MynewtSensor.getReadableName(resource: selectedSensor.resource)
        self.navigationItem.title = readableSensorName
        
        sensorValuesTable.delegate = sensorValuesTable
        sensorValuesTable.dataSource = sensorValuesTable
        sensorValuesTable.heightConstraint = sensorValuesTableHeight
        sensorValuesTable.cellDelegate = self
        
        observeToggleBtn = self.navigationItem.rightBarButtonItem
        chartContainer.selectedSensor = selectedSensor
        chartContainer.chartLabel.text = "\(readableSensorName.uppercased()) CHART"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if observeState == OBSERVING || observeState == OBSERVE_PENDNG && selectedSensor != nil {
            selectedSensor.observe(delegate: self)
            ViewControllerUtils.showActivityIndicator(uiView: self.view)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if observeState != NOT_OBSERVING && selectedSensor != nil {
            selectedSensor.cancelObserve()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Sensor Value Cell Delegate
    
    func didToggleSwitch(indexPath: IndexPath, isChecked: Bool) {
        chartContainer.setDataSetVisibility(index: indexPath.row, isVisible: isChecked)
    }
    
    // MARK: - Mynewt Sensor Delegate
    
    func didReadSensorValues(representation: OcRepresentation, sensorValues: [MynewtSensorValue]) {
        for sensorValue in sensorValues {
            sensorValuesTable.updateElement(sensorValue)
        }
        chartContainer.addValue(sensorValues: sensorValues)
    }
    
    func didFailRead(representation: OcRepresentation) {
        NSLog("failed to read sensor")
    }
    
    func didObserveSensorValues(representation: OcRepresentation, sensorValues: [MynewtSensorValue]) {
        synced(self, closure: {
            if observeState == OBSERVE_PENDNG {
                observeState = OBSERVING
                observeToggleBtn.isEnabled = true
            }
        })
        ViewControllerUtils.hideActivityIndicator(uiView: self.view)
        for sensorValue in sensorValues {
            sensorValuesTable.updateElement(sensorValue)
        }
        chartContainer.addValue(sensorValues: sensorValues)
    }
    
    func didFailObserve(representation: OcRepresentation) {
        NSLog("failed to observe sensor")
        synced(self, closure: {
            if observeState == OBSERVE_PENDNG {
                showPlayBtn()
                observeToggleBtn.isEnabled = true
            }
        })
    }
    
    // MARK: - Actions
    
    @IBAction func toggleObserve(_ sender: Any) {
        synced(self, closure: {
            if observeState == OBSERVING { // Pause button is showing
                observeState = CANCELLING_OBSERVE
                observeToggleBtn.isEnabled = false
                selectedSensor.cancelObserve()
                showPlayBtn()
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(500), execute: {
                    self.observeState = self.NOT_OBSERVING
                    self.observeToggleBtn.isEnabled = true
                })
            } else if observeState == NOT_OBSERVING { // Play button is showing
                observeState = OBSERVE_PENDNG
                observeToggleBtn.isEnabled = false
                selectedSensor.observe(delegate: self)
                showPauseBtn()
            }
        })
    }
    
    func showPlayBtn() {
        let isEnabled = observeToggleBtn.isEnabled
        let newObserveToggleBtn = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.play, target: self, action: #selector(SensorViewController.toggleObserve(_:)))
        newObserveToggleBtn.isEnabled = isEnabled
        self.navigationController?.navigationBar.topItem?.rightBarButtonItem = newObserveToggleBtn
        observeToggleBtn = newObserveToggleBtn
    }
    
    func showPauseBtn() {
        let isEnabled = observeToggleBtn.isEnabled
        let newObserveToggleBtn = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.pause, target: self, action: #selector(SensorViewController.toggleObserve(_:)))
        newObserveToggleBtn.isEnabled = isEnabled
        self.navigationController?.navigationBar.topItem?.rightBarButtonItem = newObserveToggleBtn
        observeToggleBtn = newObserveToggleBtn
    }
    
    // MARK: - Synchronization Helper
    
    func synced(_ lock: Any, closure: () -> ()) {
        objc_sync_enter(lock)
        closure()
        objc_sync_exit(lock)
    }
}
