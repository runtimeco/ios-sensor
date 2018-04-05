//
//  AmbTempViewController.swift
//  ios-sensor
//
//  Created by Brian Giori on 11/21/17.
//  Copyright © 2017 Brian Giori. All rights reserved.
//

import UIKit
import Charts

class MynewtSensorLineChartView: UIView, ChartViewDelegate {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var chartLabel: UILabel!
    @IBOutlet weak var chartView: LineChartView!
    
    let MAX_X_ENTRIES = 50
    
    var selectedSensor: MynewtSensor!
    var xOffset = 0.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initChart()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initChart()
    }
    
    func initChart() {
        // Load our nib
        Bundle.main.loadNibNamed("MynewtSensorLineChartView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        // Initialize the chartView
        chartView.delegate = self
        chartView.chartDescription?.enabled = false

        
        // Configure left y-axis
        let yLeftAxis = chartView.leftAxis
        yLeftAxis.enabled = true
        yLeftAxis.drawGridLinesEnabled = false
        
        // Configure right y-axis
        let yRightAxis = chartView.rightAxis
        yRightAxis.drawGridLinesEnabled = true
        yRightAxis.drawZeroLineEnabled = true
        yRightAxis.zeroLineWidth = 2.0
        yRightAxis.zeroLineColor = UIColor.darkGray
        
        // Configure x-axis
        let xAxis = chartView.xAxis
        xAxis.drawGridLinesEnabled = true
        xAxis.drawLabelsEnabled = true
    }
    
    func initChartData(sensorValues: [MynewtSensorValue]) {
        // Set the initial xOffset for this graph
        if !sensorValues.isEmpty {
            xOffset = timestampFromMynewtSensorValue(sensorValues[0])
        }
        
        let colors = MynewtColor.chartColors
        // Create a ChartDataEntry and LineChartDataSet for each MynewtSensorValue
        var dataSets = [LineChartDataSet]()
        for (i, sensorValue) in sensorValues.enumerated() {
            
            // Create ChartDataEntry
            let xVal = timestampFromMynewtSensorValue(sensorValue) - xOffset
            let chartEntry = ChartDataEntry(x: Double(xVal), y: sensorValue.value, data: sensorValue as AnyObject)
            // Create LineChartDataSet
            let dataSet = LineChartDataSet(values: [chartEntry], label: sensorValue.name)
            // Configure LineChartDataSet
            dataSet.setColor(colors[i])
            dataSet.drawValuesEnabled = false
            dataSet.setCircleColor(colors[i])
            dataSet.drawCircleHoleEnabled = false
            dataSet.circleRadius = 2.5
            dataSet.axisDependency = YAxis.AxisDependency.right
            dataSet.mode = LineChartDataSet.Mode.cubicBezier
            dataSet.cubicIntensity = 0.05
            dataSet.lineWidth = 2.5
            dataSets.append(dataSet)
        }
        // Create the line chart data using the data sets
        let chartData = LineChartData(dataSets: dataSets)
        // Add the chart data to the chart
        chartView.data = chartData
    }
    
    func addValue(sensorValues: [MynewtSensorValue]) {
        ViewControllerUtils.synced(self, closure: {
            // If the chartView's data is nil, initialize
            if chartView.data == nil {
                initChartData(sensorValues: sensorValues)
            }
            
            // If our input data count does not match the data set count, return
            if sensorValues.count != chartView.data?.dataSetCount {
                NSLog("ERROR: number of input sensor values does not match data set count.")
                return
            }
            // Add each sensor value to it's data set
            for (i, sensorValue) in sensorValues.enumerated() {
                let dataSet = chartView.data?.dataSets[i]
                
                // Create ChartDataEntry
                let xVal = timestampFromMynewtSensorValue(sensorValue) - xOffset
                let chartEntry = ChartDataEntry(x: Double(xVal), y: sensorValue.value, data: sensorValue as AnyObject)
                _ = dataSet?.addEntryOrdered(chartEntry)
            }
            var moveChart = false
            if let xmax = chartView.data?.xMax {
                print("Chart highestVisibleX = \(chartView.highestVisibleX), xMax = \(xmax)")
            }
            var xRange = 10.0
            let highX = chartView.highestVisibleX;
            let lowX = chartView.lowestVisibleX;
            if let highIndex = chartView.data?.getDataSetByIndex(0).entryIndex(x: highX, closestToY: 0, rounding: .closest),
                let lowIndex = chartView.data?.getDataSetByIndex(0).entryIndex(x: lowX, closestToY: 0, rounding: .closest) {
            let distance = highIndex - lowIndex;
                if (distance > MAX_X_ENTRIES) {
                    xRange = highX - lowX;
                }
            }
            if (chartView.highestVisibleX >= (chartView.data?.xMax)! - 0.0001) {
                moveChart = true;
            }
            
            chartView.data?.notifyDataChanged()
            // Notify the chartView that it's data set has changed and shift the graph to the new data point
            chartView.notifyDataSetChanged()
            chartView.setVisibleXRangeMaximum(xRange)
            if moveChart {
                chartView.moveViewToX((chartView.data?.xMax)!)
            }
        })
    }
    
    func setDataSetVisibility(index: Int, isVisible: Bool) {
        chartView.data?.dataSets[index].visible = isVisible
        chartView.notifyDataSetChanged()
    }
    
    func timestampFromMynewtSensorValue(_ val: MynewtSensorValue) -> Double {
        let usecDecimal = Double(val.usecs)/1_000_000.0
        return Double(val.secs) + usecDecimal
    }
}
