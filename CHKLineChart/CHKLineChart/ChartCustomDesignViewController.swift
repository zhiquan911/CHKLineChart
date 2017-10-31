//
//  ChartCustomSectionViewController.swift
//  CHKLineChart
//
//  Created by Chance on 2017/6/13.
//  Copyright © 2017年 bitbank. All rights reserved.
//

import UIKit
import CHKLineChartKit

class ChartCustomDesignViewController: UIViewController {

    @IBOutlet var chartView: CHKLineChartView!
    @IBOutlet var contentView: UIView!
    @IBOutlet var segTimes: UISegmentedControl!
    @IBOutlet var loadingView: UIActivityIndicatorView!
    
    var klineDatas = [AnyObject]()
    
    let times: [String] = ["15min", "1min", "1day", "15min"] //选择时间，最后一个时分
    let exPairs: [String] = ["btccny", "ethbtc"] //选择交易对
    var selectTime: String = ""
    var selectexPair: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.chartView.delegate = self
        self.chartView.style = .customDark
        //使用代码创建K线图表
        //self.createChartView()
        
        //        self.getDataByFile()        //读取文件
        self.selectTime = self.times[0]
        self.selectexPair = self.exPairs[0]
        self.getRemoteServiceData(size: "1000")       //读取网络
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     使用代码创建K线图表
     */
    func createChartView() {
        self.chartView = CHKLineChartView()
        self.chartView.translatesAutoresizingMaskIntoConstraints = false
        self.chartView.delegate = self
        self.chartView.style = CHKLineChartStyle.customDark
        self.chartView.enableTap = false
        self.contentView.addSubview(self.chartView)
        
        //水平布局
        self.contentView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|-0-[chartView]-0-|",
                options: NSLayoutFormatOptions(),
                metrics: nil,
                views:["chartView": self.chartView]))
        
        //垂直布局
        self.contentView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-0-[chartView]-0-|",
                options: NSLayoutFormatOptions(),
                metrics: nil,
                views:["chartView": self.chartView]))
    }
    
    func getRemoteServiceData(size: String) {
        self.loadingView.startAnimating()
        self.loadingView.isHidden = false
        // 快捷方式获得session对象
        let session = URLSession.shared
        
        let url = URL(string: "https://www.btc123.com/kline/klineapi?symbol=chbtc\(self.selectexPair)&type=\(self.selectTime)&size=\(size)")
        // 通过URL初始化task,在block内部可以直接对返回的数据进行处理
        let task = session.dataTask(with: url!, completionHandler: {
            (data, response, error) in
            if let data = data {
                
                DispatchQueue.main.async {
                    /*
                     对从服务器获取到的数据data进行相应的处理.
                     */
                    do {
                        //                        NSLog("\(NSString(data: data, encoding: String.Encoding.utf8.rawValue))")
                        let dict = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableLeaves) as! [String: AnyObject]
                        
                        let isSuc = dict["isSuc"] as? Bool ?? false
                        if isSuc {
                            let datas = dict["datas"] as! [AnyObject]
                            NSLog("chart.datas = \(datas.count)")
                            self.klineDatas = datas
                            
                            self.chartView.reloadData(toPosition: .end)
                            
                            
                        }
                        
                    } catch _ {
                        
                    }
                    
                    self.loadingView.stopAnimating()
                    self.loadingView.isHidden = true
                }
                
                
            }
        })
        
        // 启动任务
        task.resume()
    }
    
    func getDataByFile() {
        let data = try? Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "data", ofType: "json")!))
        let dict = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as! [String: AnyObject]
        
        let isSuc = dict["isSuc"] as? Bool ?? false
        if isSuc {
            let datas = dict["datas"] as! [AnyObject]
            NSLog("chart.datas = \(datas.count)")
            self.klineDatas = datas
            self.chartView.reloadData()
        }
    }
    
    
    /// 切换时间
    ///
    /// - parameter sender:
    @IBAction func handleTimeSegmentChange(sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        self.selectTime = self.times[index]
        self.getRemoteServiceData(size: "800")
        
        //最后如果是选择了时分，就不显示蜡烛图，MA/EM等等
        if index == self.times.count - 1 {
            self.chartView.setSerie(hidden: false, by: CHSeriesKey.timeline, inSection: 0)
            self.chartView.setSerie(hidden: true, by: CHSeriesKey.candle, inSection: 0)
            self.chartView.setSerie(hidden: true, by: CHSeriesKey.ma, inSection: 0)
        } else {
            self.chartView.setSerie(hidden: true, by: CHSeriesKey.timeline, inSection: 0)
            self.chartView.setSerie(hidden: false, by: CHSeriesKey.candle, inSection: 0)
            self.chartView.setSerie(hidden: false, by: CHSeriesKey.ma, inSection: 0)
        }
    }
    
    
    /// 切换图表风格
    ///
    /// - Parameter sender: 
    @IBAction func handleStylesSegmentChange(sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex

        //最后如果是选择了时分，就不显示蜡烛图，MA/EM等等
        if index == 0 {
            self.chartView.resetStyle(style: .customDark)
        } else {
            self.chartView.resetStyle(style: .customLight)
        }
    }
    
    @IBAction func handleClosePress(sender: AnyObject?) {
        self.dismiss(animated: true, completion: nil)
    }
}


// MARK: - 实现K线图表的委托方法
extension ChartCustomDesignViewController: CHKLineChartDelegate {
    
    func numberOfPointsInKLineChart(chart: CHKLineChartView) -> Int {
        return self.klineDatas.count
    }
    
    func kLineChart(chart: CHKLineChartView, valueForPointAtIndex index: Int) -> CHChartItem {
        let data = self.klineDatas[index] as! [Double]
        let item = CHChartItem()
        item.time = Int(data[0] / 1000)
        item.openPrice = CGFloat(data[1])
        item.highPrice = CGFloat(data[2])
        item.lowPrice = CGFloat(data[3])
        item.closePrice = CGFloat(data[4])
        item.vol = CGFloat(data[5])
        return item
    }
    
    func kLineChart(chart: CHKLineChartView, labelOnYAxisForValue value: CGFloat, atIndex index: Int, section: CHSection) -> String {
        var strValue = ""
        if value / 10000 > 1 {
            strValue = (value / 10000).ch_toString(maxF: section.decimal) + "万"
        } else {
            strValue = value.ch_toString(maxF: section.decimal)
        }
        return strValue
    }
    
    func kLineChart(chart: CHKLineChartView, labelOnXAxisForIndex index: Int) -> String {
        let data = self.klineDatas[index] as! [Double]
        let timestamp = Int(data[0])
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
        if section == 1 {
            return 2
        } else {
            if self.selectexPair == "btccny" {
                return 2
            } else {
                return 8
            }
        }
    }
    
    
    /// 调整Y轴标签宽度
    ///
    /// - parameter chart:
    ///
    /// - returns:
    func widthForYAxisLabelInKLineChart(in chart: CHKLineChartView) -> CGFloat {
        if self.selectexPair == "btccny" {
            return chart.kYAxisLabelWidth
        } else {
            return 65
        }
    }
    
    func heightForXAxisInKLineChart(in chart: CHKLineChartView) -> CGFloat {
        return 60
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

// MARK: - 竖屏切换重载方法实现
extension ChartCustomDesignViewController {
    
    
    override func willAnimateRotation(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        if toInterfaceOrientation.isPortrait {
            //竖屏时，交易量的y轴只以4间断显示
            self.chartView.sections[1].yAxis.tickInterval = 3
            self.chartView.sections[2].yAxis.tickInterval = 3
        } else {
            //竖屏时，交易量的y轴只以2间断显示
            self.chartView.sections[1].yAxis.tickInterval = 1
            self.chartView.sections[2].yAxis.tickInterval = 1
        }
        self.chartView.reloadData()
    }
    
}
