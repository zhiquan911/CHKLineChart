//
//  DepthChartDemoViewController.swift
//  CHKLineChart
//
//  Created by Chance on 2017/6/27.
//  Copyright © 2017年 atall.io. All rights reserved.
//

import UIKit
import CHKLineChartKit

class DepthChartDemoViewController: UIViewController {
    
    @IBOutlet var depthChart: CHDepthChartView!
    @IBOutlet var loadingView: UIActivityIndicatorView!
    
    var depthDatas: [CHKDepthChartItem] = [CHKDepthChartItem]()
    var maxAmount: Float = 0          //最大深度

    override func viewDidLoad() {
        super.viewDidLoad()
        self.depthChart.delegate = self
        self.depthChart.style = .depthStyle
        self.depthChart.yAxis.referenceStyle = .none
        self.getDataByFile()
    }

    @IBAction func handleClosePress(sender: AnyObject?) {
        self.dismiss(animated: true, completion: nil)
    }

    func getDataByFile() {
        let data = try? Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "depth", ofType: "json")!))
        let dict = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as! [String: AnyObject]
        
        let isSuc = dict["result"] as? String ?? "false"
        if isSuc == "true" {
            //print(dict)
            let asks = dict["asks"] as! [[Double]]
            let bids = dict["bids"] as! [[Double]]
            if self.depthChart.style.bidChartOnDirection == .left{
                self.decodeDatasToAppend(datas: asks.reversed(), type: .ask)
                self.decodeDatasToAppend(datas: bids.reversed(), type: .bid)
            }else{
                self.decodeDatasToAppend(datas: asks, type: .ask)
                self.decodeDatasToAppend(datas: bids, type: .bid)
            }
            self.depthChart.reloadData()
        }
    }
    
    
    /// 解析数据
    func decodeDatasToAppend(datas: [[Double]], type: CHKDepthChartItemType) {
        var total: Float = 0
        if datas.count > 0 {
            for data in datas {
                let item = CHKDepthChartItem()
                item.value = CGFloat(data[0])
                item.amount = CGFloat(data[1])
                item.type = type
                
                self.depthDatas.append(item)
                
                total += Float(item.amount)
            }
        }
        
        if total > self.maxAmount {
            self.maxAmount = total
        }
    }
}

extension DepthChartDemoViewController: CHKDepthChartDelegate {
    
    /// 价格的小数位
    func depthChartOfDecimal(chart: CHDepthChartView) -> Int {
        return 4
    }
    
    /// 量的小数位
    func depthChartOfVolDecimal(chart: CHDepthChartView) -> Int {
        return 6
    }
    
    
    
    /// 图表的总条数
    /// 总数 = 买方 + 卖方
    /// - Parameter chart:
    /// - Returns:
    func numberOfPointsInDepthChart(chart: CHDepthChartView) -> Int {
        return self.depthDatas.count
    }
    
    
    /// 每个点显示的数值项
    ///
    /// - Parameters:
    ///   - chart:
    ///   - index:
    /// - Returns:
    func depthChart(chart: CHDepthChartView, valueForPointAtIndex index: Int) -> CHKDepthChartItem {
        return self.depthDatas[index]
    }
    
    
    /// y轴以基底值建立
    ///
    /// - Parameter depthChart:
    /// - Returns:
    func baseValueForYAxisInDepthChart(in depthChart: CHDepthChartView) -> Double {
        return 0
    }
    
    
    /// y轴以基底值建立后，每次段的增量
    ///
    /// - Parameter depthChart:
    /// - Returns:
    func incrementValueForYAxisInDepthChart(in depthChart: CHDepthChartView) -> Double {
        
        //计算一个显示4个辅助线的友好效果
        var step = self.maxAmount / 4
        var j = 0
        while step / 10 > 1 {
            j += 1
            step = step / 10
        }
        
        //幂运算
        var pow: Int = 1
        if j > 0 {
            for _ in 1...j {
                pow = pow * 10
            }
        }
        
        step = Float(lroundf(step) * pow)
        
        return Double(step)
    }
    
    func depthChart(chart: CHDepthChartView, labelOnYAxisForValue value: CGFloat) -> String {
        if value == 0 {
            return ""
        }
        let strValue = value.ch_toString(maxF: 0)
        return strValue
    }
}


// MARK: - 扩展样式
extension CHKLineChartStyle {
    
    
    /// 深度图样式
    static var depthStyle: CHKLineChartStyle = {
    
        let style = CHKLineChartStyle()
        //字体大小
        style.labelFont = UIFont.systemFont(ofSize: 10)
        //分区框线颜色
        style.lineColor = UIColor(white: 0.7, alpha: 1)
        //背景颜色
        style.backgroundColor = UIColor.white
        //文字颜色
        style.textColor = UIColor(white: 0.5, alpha: 1)
        //整个图表的内边距
        style.padding = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        //Y轴是否内嵌式
        style.isInnerYAxis = true
        //Y轴显示在右边
        style.showYAxisLabel = .right
        //边界宽度
        style.ch_borderWidth = (0, 0, 0.5, 0)
        
        style.bidChartOnDirection = .right
        
        style.enableTap = true
        //买方深度图层的颜色 UIColor(hex:0xAD6569) UIColor(hex:0x469777)
        style.bidColor = (UIColor(hex:0xAD6569), UIColor(hex:0xAD6569), 1)
        //        style.askColor = (UIColor(hex:0xAD6569), UIColor(hex:0xAD6569), 1)
        //买方深度图层的颜色
        style.askColor = (UIColor(hex:0x469777), UIColor(hex:0x469777), 1)
        //        style.bidColor = (UIColor(hex:0x469777), UIColor(hex:0x469777), 1)

        return style
    
    }()
}
