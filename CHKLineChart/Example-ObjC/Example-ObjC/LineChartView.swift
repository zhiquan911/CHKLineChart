//
//  LineChartView.swift
//  Example-ObjC
//
//  Created by hongfei xu on 2018/8/19.
//  Copyright © 2018年 xuhongfei. All rights reserved.
//

import UIKit
import CHKLineChartKit

@objc
class LineChartView: UIView {
    
    @objc var klineData = [KlineInfo](){
        didSet {
            self.chartView.reloadData(toPosition: .end)
        }
    }
    
    lazy var chartView: CHKLineChartView = {
        let chartView = CHKLineChartView(frame: self.bounds)
        let style = CHKLineChartStyle.base
        chartView.style = style
        chartView.delegate = self
        self.addSubview(chartView)
        return chartView
    }()
    
    var chartXAxisPrevDay: String?
    
    override func layoutSubviews() {
        self.chartView.frame = self.bounds
    }
}

extension LineChartView: CHKLineChartDelegate {
    func numberOfPointsInKLineChart(chart: CHKLineChartView) -> Int {
        return self.klineData.count
    }
    
    func kLineChart(chart: CHKLineChartView, valueForPointAtIndex index: Int) -> CHChartItem {
        let data = self.klineData[index]
        let item = CHChartItem()
        item.time = Int(data.time)!
        item.openPrice = CGFloat(Double(data.openPrice)!)
        item.closePrice = CGFloat(Double(data.closePrice)!)
        item.lowPrice = CGFloat(Double(data.lowPrice)!)
        item.highPrice = CGFloat(Double(data.highPrice)!)
        item.vol = CGFloat(Double(data.vol)!)
        return item
    }
    
    func kLineChart(chart: CHKLineChartView, labelOnYAxisForValue value: CGFloat, atIndex index: Int, section: CHSection) -> String {
        //        return String.init(format: "%.2f", arguments: [value])
        var strValue = ""
        if section.key == "volumn" {
            if value / 1000 > 1 {
                strValue = (value / 1000).ch_toString(maxF: section.decimal) + "K"
            } else {
                strValue = value.ch_toString(maxF: section.decimal)
            }
        } else {
            strValue = value.ch_toString(maxF: section.decimal)
        }
        
        return strValue
    }
    
    func kLineChart(chart: CHKLineChartView, labelOnXAxisForIndex index: Int) -> String {
        let data = self.klineData[index]
        let timestamp = Int(data.time)
        let dayText = Date.ch_getTimeByStamp(timestamp!, format: "MM-dd")
        let timeText = Date.ch_getTimeByStamp(timestamp!, format: "HH:mm")
        var text = ""
        //跨日，显示日期
        if dayText != self.chartXAxisPrevDay && index > 0 {
            text = dayText
        } else {
            text = timeText
        }
        self.chartXAxisPrevDay = dayText
        return text
    }
    
    func kLineChart(chart: CHKLineChartView, decimalAt section: Int) -> Int {
        return 2
    }
}
