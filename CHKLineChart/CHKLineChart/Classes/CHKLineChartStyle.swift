//
//  CHKLineChartStyle.swift
//  CHKLineChart
//
//  Created by 麦志泉 on 16/9/19.
//  Copyright © 2016年 Chance. All rights reserved.
//

import Foundation
import UIKit


/// 最大最小值显示风格
///
/// - none: 不显示
/// - arrow: 箭头风格
/// - circle: 空心圆风格
/// - tag: 标签风格
public enum CHUltimateValueStyle {
    
    case none
    case arrow(UIColor)
    case circle(UIColor, Bool)
    case tag(UIColor)
}

// MARK: - 图表样式配置类
open class CHKLineChartStyle {
    
    /**
     分区样式配置
     
     - returns:
     */
    open var sections: [CHSection]!
    
    /**
     要处理的算法
     
     - returns:
     */
    open var algorithms: [CHChartAlgorithmProtocol]!
    
    /**
     背景颜色
     
     - returns:
     */
    open var backgroundColor: UIColor!
    
    /**
     边距
     
     - returns:
     */
    open var padding: UIEdgeInsets!
    
    //字体大小
    open var labelFont: UIFont!
    
    //线条颜色
    open var lineColor: UIColor!
    
    //线条颜色
    open var dashColor: UIColor!
    
    
    //文字颜色
    open var textColor: UIColor!
    
    //选中点的显示的框背景颜色
    open var selectedBGColor: UIColor!
    
    //选中点的显示的文字颜色
    open var selectedTextColor: UIColor!
    
    //显示y的位置，默认右边
    open var showYLabel = CHYAxisShowPosition.right
    
    /// 是否把y坐标内嵌到图表仲
    open var isInnerYAxis: Bool = false
    
    //是否可缩放
    open var enablePinch: Bool = true
    //是否可滑动
    open var enablePan: Bool = true
    //是否可点选
    open var enableTap: Bool = true
    
    /// 是否显示选中的内容
    open var showSelection: Bool = true
    
    /// 把X坐标内容显示到哪个索引分区上，默认为-1，表示最后一个，如果用户设置溢出的数值，也以最后一个
    open var showXAxisOnSection: Int = -1
    
    public init() {
        
    }
}

// MARK: - 扩展样式
public extension CHKLineChartStyle {
    
    //实现一个最基本的样式，开发者可以自由扩展配置样式
    public static var base: CHKLineChartStyle {
        let style = CHKLineChartStyle()
        style.labelFont = UIFont.systemFont(ofSize: 10)
        style.lineColor = UIColor(white: 0.2, alpha: 1)
        style.dashColor = UIColor(white: 0.2, alpha: 1)
        style.textColor = UIColor(white: 0.8, alpha: 1)
        style.selectedBGColor = UIColor(white: 0.4, alpha: 1)
        style.selectedTextColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        style.padding = UIEdgeInsets(top: 16, left: 8, bottom: 4, right: 0)
        style.backgroundColor = UIColor.ch_hex(0x1D1C1C)
        style.showYLabel = .right
        
        //配置图表处理算法
        style.algorithms = [
            CHChartAlgorithm.timeline,
            CHChartAlgorithm.ma(5),
            CHChartAlgorithm.ma(10),
            CHChartAlgorithm.ma(30),
            CHChartAlgorithm.ema(5),
            CHChartAlgorithm.ema(10),
            CHChartAlgorithm.ema(12),       //计算MACD，必须先计算到同周期的EMA
            CHChartAlgorithm.ema(26),       //计算MACD，必须先计算到同周期的EMA
            CHChartAlgorithm.ema(30),
            CHChartAlgorithm.macd(12, 26, 9),
            CHChartAlgorithm.kdj(9, 3, 3),
        ]
        
        //分区点线样式
        let upcolor = UIColor.ch_hex(0xF80D1F)
        let downcolor = UIColor.ch_hex(0x1E932B)
        let priceSection = CHSection()
        priceSection.titleShowOutSide = true
        priceSection.valueType = .price
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
            upColor: upcolor,
            downColor: downcolor,
            titleColor: UIColor(white: 0.8, alpha: 1),
            section: priceSection,
            showGuide: true,
            ultimateValueStyle: .arrow(UIColor(white: 0.8, alpha: 1)))
        
        priceSeries.chartModels.first?.ultimateValueStyle = .arrow(UIColor(white: 0.8, alpha: 1))
        
        let priceMASeries = CHSeries.getMA(
            isEMA: false,
            num: [5,10,30],
            colors: [
                UIColor.ch_hex(0xDDDDDD),
                UIColor.ch_hex(0xF9EE30),
                UIColor.ch_hex(0xF600FF),
                ],
            section: priceSection)
        priceMASeries.hidden = false
        
        let priceEMASeries = CHSeries.getMA(
            isEMA: true,
            num: [5,10,30],
            colors: [
                UIColor.ch_hex(0xDDDDDD),
                UIColor.ch_hex(0xF9EE30),
                UIColor.ch_hex(0xF600FF),
                ],
            section: priceSection)
        
        priceEMASeries.hidden = true
        priceSection.series = [timelineSeries, priceSeries, priceMASeries, priceEMASeries]
        
        let volumeSection = CHSection()
        volumeSection.valueType = .volume
        volumeSection.hidden = false
        volumeSection.ratios = 1
        volumeSection.yAxis.tickInterval = 3
        volumeSection.padding = UIEdgeInsets(top: 16, left: 0, bottom: 8, right: 0)
        let volumeSeries = CHSeries.getDefaultVolume(upColor: upcolor, downColor: downcolor, section: volumeSection)
        
        let volumeMASeries = CHSeries.getMA(
            isEMA: false,
            num: [5,10,30],
            colors: [
                UIColor.ch_hex(0xDDDDDD),
                UIColor.ch_hex(0xF9EE30),
                UIColor.ch_hex(0xF600FF),
                ],
            section: volumeSection)
        
        let volumeEMASeries = CHSeries.getMA(
            isEMA: true,
            num: [5,10,30],
            colors: [
                UIColor.ch_hex(0xDDDDDD),
                UIColor.ch_hex(0xF9EE30),
                UIColor.ch_hex(0xF600FF),
                ],
            section: volumeSection)
        
        volumeEMASeries.hidden = true
        volumeSection.series = [volumeSeries, volumeMASeries, volumeEMASeries]
        
        let trendSection = CHSection()
        trendSection.valueType = .analysis
        trendSection.hidden = false
        trendSection.ratios = 1
        trendSection.paging = true
        trendSection.yAxis.tickInterval = 3
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
            upColor: upcolor, downColor: downcolor,
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
