//
//  KChartCell.swift
//  CHKLineChart
//
//  Created by Chance on 2017/6/24.
//  Copyright © 2017年 bitbank. All rights reserved.
//

import UIKit
import CHKLineChartKit

class KChartCell: UITableViewCell {
    
    @IBOutlet var labelCurrency: UILabel!
    @IBOutlet var chartView: CHKLineChartView!
    @IBOutlet var segTimes: UISegmentedControl!
    @IBOutlet var loadingView: UIActivityIndicatorView!
    
    static let identifier = "KChartCell"
    
    var datas = [AnyObject]()
    
    var currency: String = "" {
        didSet {
            self.labelCurrency.text = self.currency.uppercased()
        }
    }
    
    var time: String = "15min"
    
    //传入选择时段索引位，返回是否显示时分线
    typealias UpdateTime = (Int) -> Void
    var updateTime: UpdateTime?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.chartView.style = .chartInCell
        self.chartView.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    /// 刷新数据
    ///
    /// - Parameter datas:
    func reloadData(datas: [AnyObject], isTime: Bool) {
        self.datas = datas
        
        //最后如果是选择了时分，就不显示蜡烛图，MA/EM等等
        if isTime {
            self.chartView.setSerie(hidden: false, by: CHSeriesKey.timeline, inSection: 0)
            self.chartView.setSerie(hidden: true, by: CHSeriesKey.candle, inSection: 0)
            self.chartView.setSerie(hidden: true, by: CHSeriesKey.ma, inSection: 0)
        } else {
            self.chartView.setSerie(hidden: true, by: CHSeriesKey.timeline, inSection: 0)
            self.chartView.setSerie(hidden: false, by: CHSeriesKey.candle, inSection: 0)
            self.chartView.setSerie(hidden: false, by: CHSeriesKey.ma, inSection: 0)
        }
        
        self.chartView.reloadData()
    }

    /// 切换时间
    ///
    /// - parameter sender:
    @IBAction func handleTimeSegmentChange(sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        self.updateTime?(index)
    }
    
}

// MARK: - 自定义风格
extension CHKLineChartStyle {
    
    
    //实现一个点线简单图表用于图片显示
    static var chartInCell: CHKLineChartStyle {
        
        
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
        style.padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        //Y轴是否内嵌式
        style.isInnerYAxis = false
        //Y轴显示在右边
        style.showYAxisLabel = .right
        //是否显示X轴
        style.showXAxisLabel = true
        //边界宽度
        style.borderWidth = (0.5, 0, 0.5, 0)
        
        //是否把所有点都显示
        style.isShowAll = true
        //禁止所有手势操作
        style.enablePan = false
        style.enableTap = false
        style.enablePinch = false
        
        
        //配置图表处理算法
        style.algorithms = [
            CHChartAlgorithm.timeline,
            CHChartAlgorithm.ma(5),
            CHChartAlgorithm.ma(10),
            CHChartAlgorithm.ma(30),
        ]
        
        //分区点线样式
        //表示上涨的颜色
        let upcolor = (UIColor.ch_hex(0x5BA267), true)
        //表示下跌的颜色
        let downcolor = (UIColor.ch_hex(0xB1414C), true)
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
        priceSection.yAxis.referenceStyle = .solid(color: UIColor(white: 0.9, alpha: 1))
        //X轴辅助线的样式，实线
        priceSection.xAxis.referenceStyle = .solid(color: UIColor(white: 0.9, alpha: 1))
        //分区内边距
        priceSection.padding = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        
        /// 时分线
        let timelineSeries = CHSeries.getTimelinePrice(
            color: UIColor.ch_hex(0xAE475C),
            section: priceSection,
            showGuide: true,
            ultimateValueStyle: .circle(UIColor.ch_hex(0xAE475C), true),
            lineWidth: 2)
        
        timelineSeries.hidden = true
        
        
        let maColor = [
            UIColor.ch_hex(0x4E9CC1),
            UIColor.ch_hex(0xF7A23B),
            UIColor.ch_hex(0xF600FF),
            ]
        
        /// 蜡烛线
        let priceSeries = CHSeries.getCandlePrice(
            upStyle: upcolor,
            downStyle: downcolor,
            titleColor: UIColor(white: 0.5, alpha: 1),
            section: priceSection,
            showGuide: true,
            ultimateValueStyle: .arrow(UIColor(white: 0.5, alpha: 1)))
        
        //MA线
        let priceMASeries = CHSeries.getPriceMA(
            isEMA: false,
            num: [5,10,30],
            colors:maColor,
            section: priceSection)
        
        priceMASeries.hidden = false
        
        //EMA线
        let priceEMASeries = CHSeries.getPriceMA(
            isEMA: true,
            num: [5,10,30],
            colors: maColor,
            section: priceSection)
        
        priceEMASeries.hidden = true
        priceSection.series = [timelineSeries, priceSeries, priceMASeries, priceEMASeries]
        
        
        style.sections = [priceSection]
        
        
        return style
    }
    
}


// MARK: - 实现委托方法
extension KChartCell: CHKLineChartDelegate {
    
    func numberOfPointsInKLineChart(chart: CHKLineChartView) -> Int {
        return self.datas.count
    }
    
    func kLineChart(chart: CHKLineChartView, valueForPointAtIndex index: Int) -> CHChartItem {
        let data = self.datas[index] as! [Double]
        let item = CHChartItem()
        item.time = Int(data[0] / 1000)
        item.openPrice = CGFloat(data[1])
        item.highPrice = CGFloat(data[2])
        item.lowPrice = CGFloat(data[3])
        item.closePrice = CGFloat(data[4])
        item.vol = CGFloat(data[5])
        return item
    }
    
    /// 调整Y轴标签宽度
    ///
    /// - parameter chart:
    ///
    /// - returns:
    func widthForYAxisLabelInKLineChart(in chart: CHKLineChartView) -> CGFloat {
        return chart.kYAxisLabelWidth
    }
    
    func kLineChart(chart: CHKLineChartView, labelOnYAxisForValue value: CGFloat, atIndex index: Int, section: CHSection) -> String {
        let strValue = value.ch_toString(maxF: section.decimal)
        return strValue
    }
    
    func kLineChart(chart: CHKLineChartView, labelOnXAxisForIndex index: Int) -> String {
        let data = self.datas[index] as! [Double]
        let timestamp = Int(data[0])
        var time = Date.ch_getTimeByStamp(timestamp, format: "HH:mm")
        if time == "00:00" {
            time = Date.ch_getTimeByStamp(timestamp, format: "MM-dd")
        }
        return time
    }
    
    func heightForXAxisInKLineChart(in chart: CHKLineChartView) -> CGFloat {
        return 16
    }
    
}

