//
//  ChartDemoViewController.swift
//  CHKLineChart
//
//  Created by Chance on 16/9/19.
//  Copyright © 2016年 bitbank. All rights reserved.
//

import UIKit

class ChartDemoViewController: UIViewController {
    
    @IBOutlet var chartView: CHKLineChartView!
    @IBOutlet var contentView: UIView!
    @IBOutlet var segPrice: UISegmentedControl!
    @IBOutlet var segAnalysis: UISegmentedControl!
    @IBOutlet var segTimes: UISegmentedControl!
    @IBOutlet var loadingView: UIActivityIndicatorView!
    
    var klineDatas = [AnyObject]()
    
    let times: [String] = ["1min", "15min", "1day"] //选择时间
    let exPairs: [String] = ["btccny", "ethbtc"] //选择交易对
    var selectTime: String = ""
    var selectexPair: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.chartView.delegate = self
        self.chartView.style = .base
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
        self.chartView.style = CHKLineChartStyle.base
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
    
    
    @IBAction func handleSegmentChange(sender: UISegmentedControl) {
        
        if sender === self.segPrice {
            switch sender.selectedSegmentIndex {
            case 0:
                self.chartView.setSerie(hidden: true, by: CHSeriesKey.ma)
                self.chartView.setSerie(hidden: true, by: CHSeriesKey.ema)
            case 1:
                self.chartView.setSerie(hidden: false, by: CHSeriesKey.ma)
                self.chartView.setSerie(hidden: true, by: CHSeriesKey.ema)
            case 2:
                self.chartView.setSerie(hidden: true, by: CHSeriesKey.ma)
                self.chartView.setSerie(hidden: false, by: CHSeriesKey.ema)
            default:
                break
            }
        } else {
            switch sender.selectedSegmentIndex {
            case 0:
                self.chartView.setSection(hidden: true, by: CHSectionValueType.analysis.key)
                self.chartView.setSerie(hidden: true, by: CHSeriesKey.kdj)
                self.chartView.setSerie(hidden: true, by: CHSeriesKey.macd)
            case 1:
                self.chartView.setSection(hidden: false, by: CHSectionValueType.analysis.key)
                self.chartView.setSerie(hidden: false, by: CHSeriesKey.kdj)
                self.chartView.setSerie(hidden: true, by: CHSeriesKey.macd)
            case 2:
                self.chartView.setSection(hidden: false, by: CHSectionValueType.analysis.key)
                self.chartView.setSerie(hidden: true, by: CHSeriesKey.kdj)
                self.chartView.setSerie(hidden: false, by: CHSeriesKey.macd)
            default:
                break
            }
        }
        
    }
    
    
    /// 切换时间
    ///
    /// - parameter sender:
    @IBAction func handleTimeSegmentChange(sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        self.selectTime = self.times[index]
        self.getRemoteServiceData(size: "800")
    }
    
    
    /// 选择叫一对
    ///
    /// - parameter sender:
    @IBAction func handleExPairsSegmentChange(sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        self.selectexPair = self.exPairs[index]
        self.getRemoteServiceData(size: "800")
    }
}


// MARK: - 实现K线图表的委托方法
extension ChartDemoViewController: CHKLineChartDelegate {
    
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
    
    func kLineChart(chart: CHKLineChartView, labelOnYAxisForValue value: CGFloat, section: CHSection) -> String {
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
        return Date.ch_getTimeByStamp(timestamp, format: "HH:mm")
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
    func widthForYAxisLabel(in chart: CHKLineChartView) -> CGFloat {
        if self.selectexPair == "btccny" {
            return chart.kYAxisLabelWidth
        } else {
            return 65
        }
    }
    
}


// MARK: - 竖屏切换重载方法实现
extension ChartDemoViewController {
    
    
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
