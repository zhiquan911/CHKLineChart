//
//  CHImageGenerator.swift
//  CHKLineChart
//
//  Created by Chance on 2017/6/22.
//  Copyright © 2017年 bitbank. All rights reserved.
//

import UIKit

/// 简单走势图生成器
public class CHChartImageGenerator: NSObject {

    public var values: [(Int, Double)] = [(Int, Double)]()
    public var chartView: CHKLineChartView!
    public var style: CHKLineChartStyle = CHKLineChartStyle.lineIMG
    
    
    /// 创建一个全局单例用于生成图表的截图
    public static let share: CHChartImageGenerator = {
        let generator = CHChartImageGenerator()
        return generator
    }()
    
    public override init() {
        super.init()
        self.chartView = CHKLineChartView(frame: CGRect.zero)
        self.chartView.style = CHKLineChartStyle.lineIMG
        self.chartView.delegate = self
    }
    
    
    /// 通过 数据源，图表样式 生成一张图表截图
    ///
    /// - Parameters:
    ///   - values: 数据源
    ///   - lineWidth: 线粗
    ///   - backgroundColor: 背景颜色
    ///   - lineColor: 线颜色
    ///   - size: 图片大小
    /// - Returns: 图表图片
    public func getImage(by values: [(Int, Double)],
                  lineWidth: CGFloat = 1,
                  backgroundColor: UIColor = UIColor.white,
                  lineColor: UIColor = UIColor.lightGray,
                  size: CGSize) -> UIImage {
        self.values = values
        self.style.backgroundColor = backgroundColor
        let section = self.style.sections[0]
        let model = section.series[0].chartModels[0]
        section.backgroundColor = backgroundColor
        model.upStyle = (lineColor, true)
        model.downStyle = (lineColor, true)
        model.lineWidth = lineWidth
        var frame = self.chartView.frame
        frame.size.width = size.width
        frame.size.height = size.height
        self.chartView.frame = frame
        self.chartView.style = self.style
        self.chartView.reloadData()
        return self.chartView.image
    }
    
}


// MARK: - 自定义风格
extension CHKLineChartStyle {
   
    
    //实现一个点线简单图表用于图片显示
    public static var lineIMG: CHKLineChartStyle {
        
        
        let style = CHKLineChartStyle()
        //字体大小
        style.labelFont = UIFont.systemFont(ofSize: 10)
        //分区框线颜色
        style.lineColor = UIColor.clear
        //背景颜色
        style.backgroundColor = UIColor.ch_hex(0xF5F5F5)
        //文字颜色
        style.textColor = UIColor(white: 0.8, alpha: 1)
        //整个图表的内边距
        style.padding = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
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
        //分区的类型
        priceSection.valueType = .master
        //分区唯一键值
        priceSection.key = "price"
        //是否隐藏分区
        priceSection.hidden = false
        //分区所占图表的比重，0代表不使用比重，采用固定高度
        priceSection.ratios = 1
        //Y轴辅助线的样式，实线
        priceSection.yAxis.referenceStyle = .none
        //分区内边距
        priceSection.padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        /// 时分线
        let timelineSeries = CHSeries.getTimelinePrice(
            color: UIColor.ch_hex(0xA4AAB3),
            section: priceSection,
            showGuide: true,
            ultimateValueStyle: .none,
            lineWidth: 1)
        
        priceSection.series = [timelineSeries]
        
        style.sections = [priceSection]
        
        
        return style
    }
    
}


// MARK: - 实现委托方法
extension CHChartImageGenerator: CHKLineChartDelegate {
    
    public func numberOfPointsInKLineChart(chart: CHKLineChartView) -> Int {
        return self.values.count
    }
    
    public func kLineChart(chart: CHKLineChartView, valueForPointAtIndex index: Int) -> CHChartItem {
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
    public func widthForYAxisLabelInKLineChart(in chart: CHKLineChartView) -> CGFloat {
        return chart.kYAxisLabelWidth
    }
    
    public func kLineChart(chart: CHKLineChartView, labelOnYAxisForValue value: CGFloat, atIndex index: Int, section: CHSection) -> String {
//        let strValue = value.ch_toString(maxF: section.decimal)
        return ""
    }
    
    public func kLineChart(chart: CHKLineChartView, labelOnXAxisForIndex index: Int) -> String {
        return ""
    }
    
    public func heightForXAxisInKLineChart(in chart: CHKLineChartView) -> CGFloat {
        return 0
    }

}
