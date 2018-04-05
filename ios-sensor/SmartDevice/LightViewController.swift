//
//  LightViewController.swift
//  ios-sensor
//
//  Created by Brian Giori on 11/22/17.
//  Copyright © 2017 Brian Giori. All rights reserved.
//

import UIKit

class LightViewController: UIViewController {

    @IBOutlet weak var lightSwitch: UISwitch!
    @IBOutlet weak var lightValueLabel: UILabel!
    
    // Variables passed from previous controllers
    var selectedDevice: OcResource!
    
    // Timer for polling the light resource
    var pollLightTimer: Timer!
    var updateLightSwitch: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set value label
        lightValueLabel.text = "N/A"
        lightSwitch.isOn = false
        lightSwitch.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.pollLightTimer = Timer.init(timeInterval: 2.0, target: self, selector: #selector(self.getLight), userInfo: nil, repeats: true)
        RunLoop.current.add(self.pollLightTimer, forMode: RunLoopMode.defaultRunLoopMode)
        self.pollLightTimer.fire()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.pollLightTimer.invalidate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func switchValueChanged(_ sender: Any) {
        setLight()
    }
    
    func getLight() {
        // Do any additional setup after loading the view.
        selectedDevice.get({ [unowned self] (representation: OcRepresentation?) in
            if let values = representation?.values {
                if let value = values["value"] as? Bool {
                    ViewControllerUtils.synced(self, closure: {
                        if self.updateLightSwitch {
                            self.lightSwitch.isOn = value
                            self.setLightValueLabel(value: value)
                            self.lightSwitch.isEnabled = true
                        }
                    })
                    
                }
            }
        })
        
    }
    
    func setLight() {
        ViewControllerUtils.synced(self) {
            updateLightSwitch = false
            lightSwitch.isUserInteractionEnabled = false
            let value = OcRepresentationValue(name: "value", boolValue: lightSwitch.isOn)
            selectedDevice.put([value!], callback: { [unowned self] (representation: OcRepresentation?) in
                print("PUT CALLBACK")
                if representation?.result != OC_STACK_RESOURCE_CHANGED {
                    print(representation!.result)
                    self.setLight()
                    return
                }
                ViewControllerUtils.synced(self, closure: {
                    self.updateLightSwitch = true
                    self.setLightValueLabel(value: self.lightSwitch.isOn)
                    self.lightSwitch.isUserInteractionEnabled = true
                })
                
            })
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1), execute: {
                ViewControllerUtils.synced(self, closure: {
                    self.lightSwitch.isUserInteractionEnabled = true
                    self.updateLightSwitch = true
                })
            })
        }
    }
    
    func setLightValueLabel(value: Bool) {
        self.lightValueLabel.text = (value) ? "On" : "Off"
    }

}
