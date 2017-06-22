//
//  CHImageGenerator.swift
//  CHKLineChart
//
//  Created by Chance on 2017/6/22.
//  Copyright © 2017年 bitbank. All rights reserved.
//

import UIKit

class CHImageGenerator: NSObject {

    var values: [(Int, Double)] = [(Int, Double)]()
    var chartView: CHKLineChartView!
    var lineWidth: CGFloat = 1
    var size: CGSize = .zero
    var color: UIColor = UIColor.clear
    
    convenience init(values: [(Int, Double)], color: UIColor, lineWidth: CGFloat = 1, size: CGSize) {
        self.init()
        
        self.values = values
        self.lineWidth = lineWidth
        self.size = size
        self.color = color
        
        self.chartView = CHKLineChartView(frame: CGRect(origin: CGPoint.zero, size: size))
        self.chartView.style = self.lineIMG
        self.chartView.delegate = self
//        self.chartView.reloadData()
    }
    
    var image: UIImage {
        return self.chartView.image
    }
}


// MARK: - 自定义风格
extension CHImageGenerator {
   
    
    //实现一个点线简单图表用于图片显示
    var lineIMG: CHKLineChartStyle {
        
        
        let style = CHKLineChartStyle()
        //字体大小
        style.labelFont = UIFont.systemFont(ofSize: 10)
        //分区框线颜色
        style.lineColor = UIColor.clear
        //Y轴上虚线颜色
        style.dashColor = UIColor.clear
        //背景颜色
        style.backgroundColor = UIColor.white
        //文字颜色
        style.textColor = UIColor(white: 0.8, alpha: 1)
        //整个图表的内边距
        style.padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        //Y轴是否内嵌式
        style.isInnerYAxis = true
        //显示X轴坐标内容在哪个分区仲
        style.showXAxisOnSection = 0
        //Y轴显示在右边
        style.showYAxisLabel = .none
        //是否显示X轴
        style.showXAxisLabel = false
        
        //是否把所有点都显示
        style.isShowAll = true
        //禁止所有手势操作
        style.enablePan = false
        style.enableTap = false
        style.enablePinch = false
        
        
        //配置图表处理算法
        style.algorithms = [
            CHChartAlgorithm.timeline
        ]
        
        let priceSection = CHSection()
        priceSection.backgroundColor = style.backgroundColor
        //分区上显示选中点的数据文字是否在分区外显示
        priceSection.titleShowOutSide = false
        //是否显示选中点的数据文字
        priceSection.showTitle = false
        //分区的数值类型
        priceSection.valueType = .price
        //是否隐藏分区
        priceSection.hidden = false
        //分区所占图表的比重，0代表不使用比重，采用固定高度
        priceSection.ratios = 1
        //分区内边距
        priceSection.padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        /// 时分线
        let timelineSeries = CHSeries.getTimelinePrice(
            color: self.color,
            section: priceSection,
            showGuide: true,
            ultimateValueStyle: .none,
            lineWidth: self.lineWidth)
        
        priceSection.series = [timelineSeries]
        
        style.sections = [priceSection]
        
        
        return style
    }
    
}

extension CHImageGenerator: CHKLineChartDelegate {
    
    func numberOfPointsInKLineChart(chart: CHKLineChartView) -> Int {
        return self.values.count
    }
    
    func kLineChart(chart: CHKLineChartView, valueForPointAtIndex index: Int) -> CHChartItem {
        let data = self.values[index]
        let item = CHChartItem()
        item.time = Int(data.0 / 1000)
        item.closePrice = CGFloat(data.1)
        return item
    }
    
    /// 调整Y轴标签宽度
    ///
    /// - parameter chart:
    ///
    /// - returns:
    func widthForYAxisLabel(in chart: CHKLineChartView) -> CGFloat {
        return chart.kYAxisLabelWidth
    }
    
    func kLineChart(chart: CHKLineChartView, labelOnYAxisForValue value: CGFloat, section: CHSection) -> String {
        return ""
    }
    
    func hegihtForXAxis(in chart: CHKLineChartView) -> CGFloat {
        return 0
    }

}
