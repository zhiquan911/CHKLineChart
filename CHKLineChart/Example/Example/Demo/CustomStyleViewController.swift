//
//  CustomStyleViewController.swift
//  CHKLineChart
//
//  Created by Chance on 2016/12/31.
//  Copyright © 2016年 Chance. All rights reserved.
//

import UIKit
import CHKLineChartKit

class CustomStyleViewController: UIViewController {

    @IBOutlet var chartView: CHKLineChartView!
    
    var style: CHKLineChartStyle = .base
    
    var klineDatas = [AnyObject]()
    
    var settingVC: StyleSettingViewController!
    
    lazy var mainSectionView: SectionHeaderView = {
        let view = SectionHeaderView(frame: CGRect(x: 0, y: 0, width: 200, height: 16))
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    lazy var subSectionView: SectionHeaderView = {
        let view = SectionHeaderView(frame: CGRect(x: 0, y: 0, width: 200, height: 16))
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.chartView.delegate = self
        self.chartView.style = self.style
        self.getDataByFile()        //读取文件
        
        
        settingVC = self.storyboard?.instantiateViewController(withIdentifier: "StyleSettingViewController") as! StyleSettingViewController
        settingVC.chartView = self.chartView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    @IBAction func handleStyleSettingPress(sender: AnyObject?) {
        self.present(self.settingVC, animated: true, completion: nil)
    }
    
    @IBAction func handleClosePress(sender: AnyObject?) {
        self.dismiss(animated: true, completion: nil)
    }

}

// MARK: - 实现K线图表的委托方法
extension CustomStyleViewController: CHKLineChartDelegate {
    
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
    
    func kLineChart(chart: CHKLineChartView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return self.mainSectionView
        } else if section  == 1 {
            return self.subSectionView
        } else {
            return nil
        }
    }
    
    func kLineChart(chart: CHKLineChartView, didSelectAt index: Int, item: CHChartItem) {
        //NSLog("select index = \(index)")
        self.mainSectionView.labelTitle.text = "price = \(item.closePrice)"
        self.subSectionView.labelTitle.text = "vol = \(item.vol)"
    }
}

