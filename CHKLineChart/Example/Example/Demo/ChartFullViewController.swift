//
//  ChartFullViewController.swift
//  CHKLineChart
//
//  Created by Chance on 2017/6/19.
//  Copyright © 2017年 atall.io. All rights reserved.
//

import UIKit
import CHKLineChartKit

class ChartFullViewController: UIViewController {

    @IBOutlet var chartView: CHKLineChartView!
    @IBOutlet var loadingView: UIActivityIndicatorView!
    
    var klineDatas = [KlineChartData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.chartView.delegate = self
        self.chartView.style = .simpleLineDark
        self.fetchChartDatas(symbol: "BTC-USD", type: "15m")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// 拉取数据
    func fetchChartDatas(symbol: String, type: String) {
        
        self.loadingView.startAnimating()
        self.loadingView.isHidden = false
        
        ChartDatasFetcher.shared.getRemoteChartData(
            symbol: symbol,
            timeType: type,
            size: 70) {
                [weak self](flag, chartsData) in
                if flag && chartsData.count > 0 {
                    self?.klineDatas = chartsData
                    self?.chartView.reloadData(toPosition: .end)
                    
                }
                
                self?.loadingView.stopAnimating()
                self?.loadingView.isHidden = true
        }
    }
    
}


// MARK: - 实现K线图表的委托方法
extension ChartFullViewController: CHKLineChartDelegate {
    
    func numberOfPointsInKLineChart(chart: CHKLineChartView) -> Int {
        return self.klineDatas.count
    }
    
    func kLineChart(chart: CHKLineChartView, valueForPointAtIndex index: Int) -> CHChartItem {
        let data = self.klineDatas[index]
        let item = CHChartItem()
        item.time = data.time
        item.closePrice = CGFloat(data.closePrice)
        return item
    }
    
    func kLineChart(chart: CHKLineChartView, labelOnYAxisForValue value: CGFloat, atIndex index: Int, section: CHSection) -> String {
        let strValue = value.ch_toString(maxF: section.decimal)
        return strValue
    }
    
    func kLineChart(chart: CHKLineChartView, labelOnXAxisForIndex index: Int) -> String {
        let data = self.klineDatas[index]
        let timestamp = data.time
        var time = Date.ch_getTimeByStamp(timestamp, format: "HH:mm")
        if time == "00:00" {
            time = Date.ch_getTimeByStamp(timestamp, format: "MM-dd")
        }
        return time
    }
    
    
    /// 调整每个分区的小数位保留数
    ///
    /// - parameter chart:
    /// - parameter section:
    ///
    /// - returns:
    func kLineChart(chart: CHKLineChartView, decimalAt section: Int) -> Int {
        return 2
    }
    
    
    /// 调整Y轴标签宽度
    ///
    /// - parameter chart:
    ///
    /// - returns:
    func widthForYAxisLabelInKLineChart(in chart: CHKLineChartView) -> CGFloat {
        return chart.kYAxisLabelWidth
    }
    
    func heightForXAxisInKLineChart(in chart: CHKLineChartView) -> CGFloat {
        return 16
    }
    
    
    /// 点击图标返回点击的位置和数据对象
    ///
    /// - Parameters:
    ///   - chart:
    ///   - index:
    ///   - item:
    func kLineChart(chart: CHKLineChartView, didSelectAt index: Int, item: CHChartItem) {
        NSLog("selected index = \(index)")
        NSLog("selected item closePrice = \(item.closePrice)")
    }
    
}
