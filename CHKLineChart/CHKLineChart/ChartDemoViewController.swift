//
//  ChartDemoViewController.swift
//  CHKLineChart
//
//  Created by Chance on 16/9/19.
//  Copyright © 2016年 Chance. All rights reserved.
//

import UIKit
import CHKLineChartKit

class ChartDemoViewController: UIViewController {
    
    @IBOutlet var chartView: CHKLineChartView!
    @IBOutlet var contentView: UIView!
    @IBOutlet var segPrice: UISegmentedControl!
    @IBOutlet var segAnalysis: UISegmentedControl!
    @IBOutlet var segTimes: UISegmentedControl!
    @IBOutlet var loadingView: UIActivityIndicatorView!
    
    var klineDatas = [AnyObject]()
    
    let times: [String] = ["5min", "15min", "1hour", "1day", "1min"] //选择时间，最后一个时分
    let exPairs: [String] = ["btc_usdt", "eth_usdt"] //选择交易对
    var selectTime: String = ""
    var selectexPair: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.chartView.delegate = self
        self.chartView.style = .best
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
        let url = URL(string: "https://www.okex.com/api/v1/kline.do?symbol=\(self.selectexPair)&type=\(self.selectTime)&size=\(size)")
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
                        let datas = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableLeaves) as! [AnyObject]
                        
                        NSLog("chart.datas = \(datas.count)")
                        self.klineDatas = datas
                        
                        self.chartView.reloadData(toPosition: .end)
                        
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
                self.chartView.setSerie(hidden: true, by: CHSeriesKey.boll)
                self.chartView.setSerie(hidden: true, by: CHSeriesKey.sar)
                self.chartView.setSerie(hidden: true, by: CHSeriesKey.sam)
            case 1:
                self.chartView.setSerie(hidden: false, by: CHSeriesKey.ma)
                self.chartView.setSerie(hidden: true, by: CHSeriesKey.ema)
                self.chartView.setSerie(hidden: true, by: CHSeriesKey.boll)
                self.chartView.setSerie(hidden: true, by: CHSeriesKey.sar)
                self.chartView.setSerie(hidden: true, by: CHSeriesKey.sam)
            case 2:
                self.chartView.setSerie(hidden: true, by: CHSeriesKey.ma)
                self.chartView.setSerie(hidden: false, by: CHSeriesKey.ema)
                self.chartView.setSerie(hidden: true, by: CHSeriesKey.boll)
                self.chartView.setSerie(hidden: true, by: CHSeriesKey.sar)
                self.chartView.setSerie(hidden: true, by: CHSeriesKey.sam)
            case 3:
                self.chartView.setSerie(hidden: true, by: CHSeriesKey.ma)
                self.chartView.setSerie(hidden: true, by: CHSeriesKey.ema)
                self.chartView.setSerie(hidden: false, by: CHSeriesKey.boll)
                self.chartView.setSerie(hidden: true, by: CHSeriesKey.sar)
                self.chartView.setSerie(hidden: true, by: CHSeriesKey.sam)
            case 4:
                self.chartView.setSerie(hidden: true, by: CHSeriesKey.ma)
                self.chartView.setSerie(hidden: true, by: CHSeriesKey.ema)
                self.chartView.setSerie(hidden: true, by: CHSeriesKey.boll)
                self.chartView.setSerie(hidden: false, by: CHSeriesKey.sar)
                self.chartView.setSerie(hidden: true, by: CHSeriesKey.sam)
            case 5:
                self.chartView.setSerie(hidden: true, by: CHSeriesKey.ma)
                self.chartView.setSerie(hidden: true, by: CHSeriesKey.ema)
                self.chartView.setSerie(hidden: true, by: CHSeriesKey.boll)
                self.chartView.setSerie(hidden: true, by: CHSeriesKey.sar)
                self.chartView.setSerie(hidden: false, by: CHSeriesKey.sam)
            default:
                break
            }
            
        } else {
            switch sender.selectedSegmentIndex {
            case 0:
                self.chartView.setSection(hidden: true, byIndex: 2)
                self.chartView.setSerie(hidden: true, by: CHSeriesKey.kdj)
                self.chartView.setSerie(hidden: true, by: CHSeriesKey.macd)
            case 1:
                self.chartView.setSection(hidden: false, byIndex: 2)
                self.chartView.setSerie(hidden: false, by: CHSeriesKey.kdj)
                self.chartView.setSerie(hidden: true, by: CHSeriesKey.macd)
            case 2:
                self.chartView.setSection(hidden: false, byIndex: 2)
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
        
        //最后如果是选择了时分，就不显示蜡烛图，MA/EM等等
        if index == self.times.count - 1 {
            self.chartView.setSerie(hidden: false, by: CHSeriesKey.timeline)
            self.chartView.setSerie(hidden: true, by: CHSeriesKey.candle)
            self.chartView.setSerie(hidden: true, by: CHSeriesKey.ma)
            self.chartView.setSerie(hidden: true, by: CHSeriesKey.ema)
            self.segPrice.isEnabled = false
        } else {
            self.segPrice.isEnabled = true
            self.chartView.setSerie(hidden: true, by: CHSeriesKey.timeline)
            self.chartView.setSerie(hidden: false, by: CHSeriesKey.candle)
            self.handleSegmentChange(sender: self.segPrice)
        }
    }
    
    
    /// 选择叫一对
    ///
    /// - parameter sender:
    @IBAction func handleExPairsSegmentChange(sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        self.selectexPair = self.exPairs[index]
        self.getRemoteServiceData(size: "800")
    }
    
    @IBAction func handleClosePress(sender: AnyObject?) {
        self.dismiss(animated: true, completion: nil)
    }
}


// MARK: - 实现K线图表的委托方法
extension ChartDemoViewController: CHKLineChartDelegate {
    
    func numberOfPointsInKLineChart(chart: CHKLineChartView) -> Int {
        return self.klineDatas.count
    }
    
    func kLineChart(chart: CHKLineChartView, valueForPointAtIndex index: Int) -> CHChartItem {
        let data = self.klineDatas[index] as! [AnyObject]
        let item = CHChartItem()
        item.time = Int(data[0] as! Int / 1000)
        item.openPrice = CGFloat(Float(data[1] as! String)!)
        item.highPrice = CGFloat(Float(data[2] as! String)!)
        item.lowPrice = CGFloat(Float(data[3] as! String)!)
        item.closePrice = CGFloat(Float(data[4] as! String)!)
        item.vol = CGFloat(Float(data[5] as! String)!)
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
        let data = self.klineDatas[index] as! [AnyObject]
        let timestamp = data[0] as! Int
        return Date.ch_getTimeByStamp(timestamp, format: "HH:mm")
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


// MARK: - 扩展样式
public extension CHKLineChartStyle {
    
    //实现一个最基本的样式，开发者可以自由扩展配置样式
    public static var best: CHKLineChartStyle {
        let style = CHKLineChartStyle()
        style.labelFont = UIFont.systemFont(ofSize: 10)
        style.lineColor = UIColor(white: 0.2, alpha: 1)
        style.textColor = UIColor(white: 0.8, alpha: 1)
        style.selectedBGColor = UIColor(white: 0.4, alpha: 1)
        style.selectedTextColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        style.padding = UIEdgeInsets(top: 32, left: 8, bottom: 4, right: 0)
        style.backgroundColor = UIColor.ch_hex(0x1D1C1C)
        style.showYAxisLabel = .right
        
        //配置图表处理算法
        style.algorithms = [
            CHChartAlgorithm.timeline,
            CHChartAlgorithm.sar(4, 0.02, 0.2), //默认周期4，最小加速0.02，最大加速0.2
            CHChartAlgorithm.ma(5),
            CHChartAlgorithm.ma(10),
            CHChartAlgorithm.ma(20),        //计算BOLL，必须先计算到同周期的MA
            CHChartAlgorithm.ma(30),
            CHChartAlgorithm.ema(5),
            CHChartAlgorithm.ema(10),
            CHChartAlgorithm.ema(12),       //计算MACD，必须先计算到同周期的EMA
            CHChartAlgorithm.ema(26),       //计算MACD，必须先计算到同周期的EMA
            CHChartAlgorithm.ema(30),
            CHChartAlgorithm.boll(20, 2),
            CHChartAlgorithm.macd(12, 26, 9),
            CHChartAlgorithm.kdj(9, 3, 3),
            CHChartAlgorithm.sam(60),
        ]
        
        //分区点线样式
        let upcolor = (UIColor.ch_hex(0xF80D1F), true)
        let downcolor = (UIColor.ch_hex(0x1E932B), true)
        let priceSection = CHSection()
        priceSection.backgroundColor = style.backgroundColor
        priceSection.titleShowOutSide = true
        priceSection.valueType = .master
        priceSection.key = "master"
        priceSection.hidden = false
        priceSection.ratios = 3
        priceSection.padding = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        
        /// 时分线
        let timelineSeries = CHSeries.getTimelinePrice(
            color: UIColor.ch_hex(0xAE475C),
            section: priceSection,
            showGuide: true,
            ultimateValueStyle: .circle(UIColor.ch_hex(0xAE475C), true),
            lineWidth: 2)
        
        timelineSeries.hidden = true
        
        /// 蜡烛线
        let priceSeries = CHSeries.getCandlePrice(
            upStyle: upcolor,
            downStyle: downcolor,
            titleColor: UIColor(white: 0.8, alpha: 1),
            section: priceSection,
            showGuide: true,
            ultimateValueStyle: .arrow(UIColor(white: 0.8, alpha: 1)))
        
        priceSeries.showTitle = true
        
        priceSeries.chartModels.first?.ultimateValueStyle = .arrow(UIColor(white: 0.8, alpha: 1))
        
        let priceMASeries = CHSeries.getPriceMA(
            isEMA: false,
            num: [5,10,30],
            colors: [
                UIColor.ch_hex(0xDDDDDD),
                UIColor.ch_hex(0xF9EE30),
                UIColor.ch_hex(0xF600FF),
                ],
            section: priceSection)
        priceMASeries.hidden = false
        
        let priceEMASeries = CHSeries.getPriceMA(
            isEMA: true,
            num: [5,10,30],
            colors: [
                UIColor.ch_hex(0xDDDDDD),
                UIColor.ch_hex(0xF9EE30),
                UIColor.ch_hex(0xF600FF),
                ],
            section: priceSection)
        
        priceEMASeries.hidden = true
        
        let priceBOLLSeries = CHSeries.getBOLL(
            UIColor.ch_hex(0xDDDDDD),
            ubc: UIColor.ch_hex(0xF9EE30),
            lbc: UIColor.ch_hex(0xF600FF),
            section: priceSection)
        
        priceBOLLSeries.hidden = true
        
        let priceSARSeries = CHSeries.getSAR(
            upStyle: upcolor,
            downStyle: downcolor,
            titleColor: UIColor.ch_hex(0xDDDDDD),
            section: priceSection)
        
        priceSARSeries.hidden = true
        
        let priceSAMSeries = CHSeries.getPriceSAM(num: 60, barStyle: (UIColor.yellow, false), lineColor: UIColor(white: 0.4, alpha: 1), section: priceSection)
        
        priceSAMSeries.hidden = true
        
        priceSection.series = [
            timelineSeries,
            priceSeries,
            priceMASeries,
            priceEMASeries,
            priceBOLLSeries,
            priceSARSeries,
            priceSAMSeries,
        ]
        
        let volumeSection = CHSection()
        volumeSection.backgroundColor = style.backgroundColor
        volumeSection.valueType = .assistant
        volumeSection.key = "volume"
        volumeSection.hidden = false
        volumeSection.ratios = 1
        volumeSection.yAxis.tickInterval = 4
        volumeSection.padding = UIEdgeInsets(top: 16, left: 0, bottom: 8, right: 0)
        let volumeSeries = CHSeries.getDefaultVolume(upStyle: upcolor, downStyle: downcolor, section: volumeSection)
        
        let volumeMASeries = CHSeries.getVolumeMA(
            isEMA: false,
            num: [5,10,30],
            colors: [
                UIColor.ch_hex(0xDDDDDD),
                UIColor.ch_hex(0xF9EE30),
                UIColor.ch_hex(0xF600FF),
                ],
            section: volumeSection)
        
        let volumeEMASeries = CHSeries.getVolumeMA(
            isEMA: true,
            num: [5,10,30],
            colors: [
                UIColor.ch_hex(0xDDDDDD),
                UIColor.ch_hex(0xF9EE30),
                UIColor.ch_hex(0xF600FF),
                ],
            section: volumeSection)
        
        volumeEMASeries.hidden = true
        
        let volumeSAMSeries = CHSeries.getVolumeSAM(num: 60, barStyle: (UIColor.yellow, false), lineColor: UIColor(white: 0.4, alpha: 1), section: volumeSection)
        
        volumeSAMSeries.hidden = true
        
        volumeSection.series = [
            volumeSeries,
            volumeMASeries,
            volumeEMASeries,
            volumeSAMSeries
        ]
        
        let trendSection = CHSection()
        trendSection.backgroundColor = style.backgroundColor
        trendSection.valueType = .assistant
        trendSection.key = "analysis"
        trendSection.hidden = false
        trendSection.ratios = 1
        trendSection.paging = true
        trendSection.yAxis.tickInterval = 4
        trendSection.padding = UIEdgeInsets(top: 16, left: 0, bottom: 8, right: 0)
        let kdjSeries = CHSeries.getKDJ(
            UIColor.ch_hex(0xDDDDDD),
            dc: UIColor.ch_hex(0xF9EE30),
            jc: UIColor.ch_hex(0xF600FF),
            section: trendSection)
        kdjSeries.title = "KDJ(9,3,3)"
        
        let macdSeries = CHSeries.getMACD(
            UIColor.ch_hex(0xDDDDDD),
            deac: UIColor.ch_hex(0xF9EE30),
            barc: UIColor.ch_hex(0xF600FF),
            upStyle: upcolor, downStyle: downcolor,
            section: trendSection)
        macdSeries.title = "MACD(12,26,9)"
        macdSeries.symmetrical = true
        trendSection.series = [
            kdjSeries,
            macdSeries]
        
        style.sections = [priceSection, volumeSection, trendSection]
        
        
        return style
    }
}
