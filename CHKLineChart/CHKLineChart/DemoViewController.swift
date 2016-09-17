//
//  ViewController.swift
//  CHKLineChart
//
//  Created by 麦志泉 on 16/8/31.
//  Copyright © 2016年 bitbank. All rights reserved.
//

import UIKit

class DemoViewController: UIViewController {
    
    @IBOutlet var chartView: CHKLineChartView!
    @IBOutlet var segPrice: UISegmentedControl!
    @IBOutlet var segAnalysis: UISegmentedControl!
    
    var klineDatas = [AnyObject]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.chartView.delegate = self
        self.chartView.style = CHKLineChartStyle.base
        self.getDataByFile()
        //显示EMA线
        self.chartView.setSerie(hidden: false, by: CHSeriesKey.ema)
//        self.getRemoteServiceData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getRemoteServiceData() {
        // 快捷方式获得session对象
        let session = URLSession.shared
        
        let url = URL(string: "https://www.btc123.com/kline/klineapi?symbol=chbtcbtccny&type=1day&size=300")
        // 通过URL初始化task,在block内部可以直接对返回的数据进行处理
        let task = session.dataTask(with: url!, completionHandler: {
            (data, response, error) in
            if let data = data {
                /*
                 对从服务器获取到的数据data进行相应的处理.
                 */
                do {
                    NSLog("\(NSString(data: data, encoding: String.Encoding.utf8.rawValue))")
                    let dict = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableLeaves) as! [String: AnyObject]
                    
                    let isSuc = dict["isSuc"] as? Bool ?? false
                    if isSuc {
                        let datas = dict["datas"] as! [AnyObject]
                        NSLog("chart.datas = \(datas.count)")
                        self.klineDatas = datas
                        self.chartView.reloadData()
                    }
                    
                } catch _ {
                    
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

}

extension DemoViewController: CHKLineChartDelegate {
    
    func numberOfPointsInKLineChart(_ chart: CHKLineChartView) -> Int {
        return self.klineDatas.count
    }
    
    func kLineChart(_ chart: CHKLineChartView, valueForPointAtIndex index: Int) -> CHChartItem {
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
    
    func kLineChart(_ chart: CHKLineChartView, labelOnXAxisForIndex index: Int) -> String {
        let data = self.klineDatas[index] as! [Double]
        let timestamp = Int(data[0])
        return Date.getTimeByStamp(timestamp, format: "HH:mm")
    }
    
}


// MARK: - 竖屏切换重载方法实现
extension DemoViewController {
    
    
    override func willAnimateRotation(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        
        self.chartView.reloadData()
    }
    
}
