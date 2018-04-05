//
//  MynewtSensor.swift
//  ios-sensor
//
//  Created by Brian Giori on 11/17/17.
//  Copyright © 2017 Brian Giori. All rights reserved.
//

import Foundation
import CoreBluetooth


protocol MynewtSensorDelegate {
    func didReadSensorValues(representation: OcRepresentation, sensorValues: [MynewtSensorValue])
    func didFailRead(representation: OcRepresentation)
    func didObserveSensorValues(representation: OcRepresentation, sensorValues: [MynewtSensorValue])
    func didFailObserve(representation: OcRepresentation)
}


struct MynewtSensorValue {
    var name: String
    var value: Double
    var valueStr: String
    var units: String
    var secs: Int64
    var usecs: Int64
    var cputime: Int64
}

class MynewtSensor {
    static let MYNEWT_SENSOR_RT_PREFIX = "x.mynewt.snsr.";
    
    /* OIC resource types for sensors exposed over the Mynewt sensor framwork */
    static let RT_LINEAR_ACCELEROMETER = "x.mynewt.snsr.lacc";
    static let RT_ACCELEROMETER = "x.mynewt.snsr.acc";
    static let RT_MAGNETOMETER = "x.mynewt.snsr.mag";
    static let RT_LIGHT_SENSOR = "x.mynewt.snsr.lt";
    static let RT_TEMPERATURE_SENSOR = "x.mynewt.snsr.tmp";
    static let RT_AMBIENT_TEMPERATURE_SENSOR = "x.mynewt.snsr.ambtmp";
    static let RT_RELATIVE_HUMIDITY_SENSOR = "x.mynewt.snsr.rhmty";
    static let RT_PRESSURE_SENSOR = "x.mynewt.snsr.psr";
    static let RT_COLOR_SENSOR = "x.mynewt.snsr.col";
    static let RT_GYROSCOPE = "x.mynewt.snsr.gyr";
    static let RT_EULER = "x.mynewt.snsr.eul";
    static let RT_GRAVITY = "x.mynewt.snsr.grav";
    static let RT_ROTATION_VECTOR = "x.mynewt.snsr.quat";
    static let RT_QUALCOMM_TEMP = "oic.r.temp"
    static let RT_QUALCOMM_COMPASS = "oic.r.3"

    /* Human readable names for each sensor type */
    static let TITLE_LINEAR_ACCELEROMETER = "Linear Accelerometer";
    static let TITLE_ACCELEROMETER = "Accelerometer";
    static let TITLE_MAGNETOMETER = "Magnetometer";
    static let TITLE_LIGHT_SENSOR = "Light Sensor";
    static let TITLE_TEMPERATURE_SENSOR = "Temperature Sensor";
    static let TITLE_AMBIENT_TEMPERATURE_SENSOR = "Ambient Temperature Sensor";
    static let TITLE_RELATIVE_HUMIDITY_SENSOR = "Relative Humidity Sensor";
    static let TITLE_PRESSURE_SENSOR = "Pressure Sensor";
    static let TITLE_COLOR_SENSOR = "Color Sensor";
    static let TITLE_GYROSCOPE = "Gyroscope";
    static let TITLE_EULER = "Euler Sensor";
    static let TITLE_GRAVITY = "Gravity Sensor";
    static let TITLE_ROTATION_VECTOR = "Rotation Vector (Quaternion)";
    static let TITLE_COMPASS = "Compass";
    
    static func isMynewtSensor(resource: OcResource) -> Bool {
        return (resource.resourceTypes as! [String]).contains(where: {$0.hasPrefix(MYNEWT_SENSOR_RT_PREFIX)}) || (resource.resourceTypes as! [String]).contains(where: {$0 == RT_QUALCOMM_COMPASS})
    }
    
    static func isMynewtSensor(representation: OcRepresentation) -> Bool {
        return (representation.resourceTypes as! [String]).contains(where: {$0.hasPrefix(MYNEWT_SENSOR_RT_PREFIX)}) ||
            (representation.resourceTypes as! [String]).contains(where: {$0 == RT_QUALCOMM_COMPASS})
    }
    
    static func getSensorType(resource: OcResource) -> String? {
        for resType in resource.resourceTypes as! [String] {
            if resType.hasPrefix(MYNEWT_SENSOR_RT_PREFIX) {
                return resType
            } else if resType == RT_QUALCOMM_COMPASS {
                return resType
            }
        }
        return nil
    }
    
    static func getSensorType(representation: OcRepresentation) -> String? {
        for resType in representation.resourceTypes as! [String] {
            if resType.hasPrefix(MYNEWT_SENSOR_RT_PREFIX) {
                return resType
            } else if resType == RT_QUALCOMM_COMPASS {
                return resType
            }
        }
        return nil
    }
    
    static func getReadableName(resource: OcResource) -> String {
        let sensorType = getSensorType(resource: resource)
        if sensorType == nil {
            return "Unknown"
        }
        switch sensorType! {
        case RT_LINEAR_ACCELEROMETER:
            return TITLE_LINEAR_ACCELEROMETER
        case RT_ACCELEROMETER:
            return TITLE_ACCELEROMETER
        case RT_MAGNETOMETER:
            return TITLE_MAGNETOMETER
        case RT_LIGHT_SENSOR:
            return TITLE_LIGHT_SENSOR
        case RT_TEMPERATURE_SENSOR:
            return TITLE_TEMPERATURE_SENSOR
        case RT_AMBIENT_TEMPERATURE_SENSOR:
            return TITLE_AMBIENT_TEMPERATURE_SENSOR
        case RT_RELATIVE_HUMIDITY_SENSOR:
            return TITLE_RELATIVE_HUMIDITY_SENSOR
        case RT_PRESSURE_SENSOR:
            return TITLE_PRESSURE_SENSOR
        case RT_COLOR_SENSOR:
            return TITLE_COLOR_SENSOR
        case RT_GYROSCOPE:
            return TITLE_GYROSCOPE
        case RT_EULER:
            return TITLE_EULER
        case RT_GRAVITY:
            return TITLE_GRAVITY
        case RT_ROTATION_VECTOR:
            return TITLE_ROTATION_VECTOR
        case RT_QUALCOMM_COMPASS:
            return TITLE_COMPASS
        default:
            return "Unknown Sensor"
        }
    }
    
    static func getSensorValues(type: String, values: [String:Any]) -> [MynewtSensorValue] {
        var keys = [(String, String)]()
        var mynewtSensorValues = [MynewtSensorValue]()
        switch type {
        case RT_LINEAR_ACCELEROMETER:
            keys = [("x", "m/s2"), ("y", "m/s2"), ("z", "m/s2")]
            break
        case RT_ACCELEROMETER:
            keys = [("x", "m/s2"), ("y", "m/s2"), ("z", "m/s2")]
            break
        case RT_MAGNETOMETER:
            keys = [("x", "m/s2"), ("y", "m/s2"), ("z", "m/s2")]
            break
        case RT_LIGHT_SENSOR:
            keys = [("lux", "lumens"), ("ir", "lumens"), ("full", "lumens")]
            break
        case RT_TEMPERATURE_SENSOR:
            keys = [("temp", "ºC")]
            break
        case RT_AMBIENT_TEMPERATURE_SENSOR:
            keys = [("temp", "ºC")]
            break
        case RT_RELATIVE_HUMIDITY_SENSOR:
            keys = [("humid", "% rh")]
            break
        case RT_PRESSURE_SENSOR:
            keys = [("press", "Pa")]
            break
        case RT_COLOR_SENSOR:
            keys = [("r", ""), ("g", ""), ("b", ""), ("c", ""), ("lux", "lumens"), ("ir", "lumens"), ("colortemp", "ºK"), ("cratio", ""), ("saturation", ""), ("ir_sat", "")]
            break
        case RT_GYROSCOPE:
            keys = [("x", "m/s2"), ("y", "m/s2"), ("z", "m/s2")]
            break
        case RT_EULER:
            keys = [("r", "º (roll)"), ("p", "º (pitch)"), ("h", "º (yaw)")]
            break
        case RT_GRAVITY:
            keys = [("x", "m/s2"), ("y", "m/s2"), ("z", "m/s2")]
            break
        case RT_ROTATION_VECTOR:
            keys = [("x", ""), ("y", ""), ("z", ""), ("w", "")]
            break
        case RT_QUALCOMM_TEMP:
            keys = [("temperature", "ºC")]
        case RT_QUALCOMM_COMPASS:
            keys = [("orientation", "")]
        default:
            return []
        }
        print(values)
        for (key, units) in keys {
            let value = values[key]
            if let secs = values["ts_secs"] as? Int64, let usecs = values["ts_usecs"] as? Int64, let cputime = values["ts_cputime"] as? Int64 {
                if let doubleValue = value as? Double {
                    let doubleValueString = String(format: "%.3f", doubleValue)
                    let sensorValue = MynewtSensorValue(name: key, value: doubleValue, valueStr: doubleValueString, units: units, secs: secs, usecs: usecs, cputime: cputime)
                    mynewtSensorValues.append(sensorValue)
                } else if let intValue = value as? Int64 {
                    let sensorValue = MynewtSensorValue(name: key, value: Double(intValue), valueStr: intValue.description, units: units, secs: secs, usecs: usecs, cputime: cputime)
                    mynewtSensorValues.append(sensorValue)
                }
            } else {
                // QUALCOMM HACK
                print("value: \(value ?? "fucking nil bitch") type: \(type(of: value))")
                if let doubleValue = value as? Double {
                    let doubleValueString = String(format: "%.3f", doubleValue)
                    let secs = Int64(NSDate().timeIntervalSince1970)
                    let sensorValue = MynewtSensorValue(name: key, value: doubleValue, valueStr: doubleValueString, units: units, secs: secs, usecs: secs * 1_000_000, cputime: 0)
                    mynewtSensorValues.append(sensorValue)
                } else if let intValue = value as? Int64 {
                    let secs = Int64(NSDate().timeIntervalSince1970)
                    let sensorValue = MynewtSensorValue(name: key, value: Double(intValue), valueStr: intValue.description, units: units, secs: secs, usecs: secs * 1_000_000, cputime: 0)
                    mynewtSensorValues.append(sensorValue)
                } else if let stringValue = value as? String {
                    let doubleValue = Double(stringValue) ?? 0.0
                    let secs = Int64(NSDate().timeIntervalSince1970)
                    let sensorValue = MynewtSensorValue(name: key, value: doubleValue, valueStr: stringValue, units: units, secs: secs, usecs: secs * 1_000_000, cputime: 0)
                    mynewtSensorValues.append(sensorValue)
                } else if let arrayValue = value as? [Int64] {
                    let secs = Int64(NSDate().timeIntervalSince1970)
                    for intValue in arrayValue {
                        let sensorValue = MynewtSensorValue(name: key, value: Double(intValue), valueStr: arrayValue.description, units: units, secs: secs, usecs: secs * 1_000_000, cputime: 0)
                        mynewtSensorValues.append(sensorValue)
                    }
                } else {
                    print("FUCK")
                }
            }
        }
        return mynewtSensorValues
    }
    
    var resource: OcResource
    var sensorType: String?
    var peripheral: CBPeripheral?
    
    init(resource: OcResource, peripheral: CBPeripheral? = nil) {
        self.resource = resource
        self.sensorType = MynewtSensor.getSensorType(resource: resource)
        self.peripheral = peripheral
    }
    
    func read(delegate: MynewtSensorDelegate) {
        resource.get({ [unowned self] (representation: OcRepresentation?) in
            // Check for an Iotivity stack error
            if (representation?.result.rawValue)! > OC_STACK_RESOURCE_CHANGED.rawValue {
                NSLog("GET Callback - Iotivity Error: \(representation!.result)")
                delegate.didFailRead(representation: representation!)
                return
            }
            // Get values from the resource's representation
            if let values = representation?.values {
                let sensorValues = MynewtSensor.getSensorValues(type: self.sensorType!, values: values as! [String : Any])
                delegate.didReadSensorValues(representation: representation!, sensorValues: sensorValues)
            } else {
                NSLog("GET Callback - representation does not contain any values")
                delegate.didFailRead(representation: representation!)
            }
        })
    }
    
    func observe(delegate: MynewtSensorDelegate) {
        resource.observe(OC_HIGH_QOS, callback: { [unowned self] (representation: OcRepresentation?) in
            // Check for an Iotivity stack error
            if (representation?.result.rawValue)! > OC_STACK_RESOURCE_CHANGED.rawValue {
                NSLog("OBSERVE Callback - Iotivity Error: \(representation!.result)")
                delegate.didFailObserve(representation: representation!)
                return
            }
            // Get values from the resource's representation
            if let values = representation?.values {
                let sensorValues = MynewtSensor.getSensorValues(type: self.sensorType!, values: values as! [String : Any])
                delegate.didObserveSensorValues(representation: representation!, sensorValues: sensorValues)
            } else {
                NSLog("OBSERVE Callback - representation does not contain any values")
                delegate.didFailObserve(representation: representation!)
            }
        })
    }
    
    func cancelObserve() {
        print("CANCEL OBSERVE")
        resource.cancelObserve()
    }
}
