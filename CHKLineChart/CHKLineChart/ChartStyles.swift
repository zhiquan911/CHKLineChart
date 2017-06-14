//
//  ChartStyles.swift
//  CHKLineChart
//
//  Created by Chance on 2017/6/12.
//  Copyright © 2017年 bitbank. All rights reserved.
//

import UIKit

// MARK: - 扩展样式
public extension CHKLineChartStyle {
    
    //实现一个最基本的样式，开发者可以自由扩展配置样式
    public static var strange: CHKLineChartStyle {
        let style = CHKLineChartStyle()
        style.labelFont = UIFont.systemFont(ofSize: 10)
        style.lineColor = UIColor.clear
        style.dashColor = UIColor.clear
        style.textColor = UIColor(white: 0.8, alpha: 1)
        style.selectedBGColor = UIColor(white: 0.4, alpha: 1)
        style.selectedTextColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        style.padding = UIEdgeInsets(top: 0, left: 2, bottom: 20, right: 2)
        style.backgroundColor = UIColor.ch_hex(0x1D1C1C)
        style.isInnerYAxis = true
        style.autoShowXAxisOnLastSection = false
//        style.showSelection = false
//        style.enablePan = false
//        style.enablePinch = false
        
        
        
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
        priceSection.backgroundColor = UIColor.ch_hex(0x1D1C1C)
        priceSection.titleShowOutSide = false
        priceSection.showTitle = false
        priceSection.showXAxis = true
        priceSection.valueType = .price
        priceSection.hidden = false
        priceSection.ratios = 0
        priceSection.fixHeight = 236
        priceSection.padding = UIEdgeInsets(top: 20, left: 0, bottom: 80, right: 0)
        
        /// 时分线
        let timelineSeries = CHSeries.getTimelinePrice(color: UIColor.ch_hex(0xAE475C), section: priceSection)
        timelineSeries.hidden = true
        timelineSeries.chartModels.first?.ultimateValueStyle = .circle(true)
        timelineSeries.chartModels.first?.showMaxVal = true
        timelineSeries.chartModels.first?.showMinVal = true
        timelineSeries.chartModels.first?.lineWidth = 2
        
        /// 蜡烛线
        let priceSeries = CHSeries.getCandlePrice(upColor: upcolor,
                                                  downColor: downcolor,
                                                  titleColor: UIColor(white: 0.8, alpha: 1),
                                                  section: priceSection)
        priceSeries.chartModels.first?.ultimateValueStyle = .tag
        
        let priceMASeries = CHSeries.getMA(isEMA: false, num: [5,10,30],
                                           colors: [
                                            UIColor.ch_hex(0xDDDDDD),
                                            UIColor.ch_hex(0xF9EE30),
                                            UIColor.ch_hex(0xF600FF),
                                            ], section: priceSection)
        priceMASeries.hidden = false
        let priceEMASeries = CHSeries.getMA(isEMA: true, num: [5,10,30],
                                            colors: [
                                                UIColor.ch_hex(0xDDDDDD),
                                                UIColor.ch_hex(0xF9EE30),
                                                UIColor.ch_hex(0xF600FF),
                                                ], section: priceSection)
        priceEMASeries.hidden = true
        priceSection.series = [timelineSeries, priceSeries, priceMASeries, priceEMASeries]
        
        let volumeSection = CHSection()
        volumeSection.backgroundColor = UIColor.ch_hex(0x1D1C1C)
        volumeSection.valueType = .volume
        volumeSection.hidden = false
        volumeSection.showTitle = false
        volumeSection.ratios = 1
        volumeSection.yAxis.tickInterval = 2
        volumeSection.padding = UIEdgeInsets(top: 10, left: 0, bottom: 4, right: 0)
        let volumeSeries = CHSeries.getDefaultVolume(upColor: upcolor, downColor: downcolor, section: volumeSection)
        let volumeMASeries = CHSeries.getMA(isEMA: false, num: [5,10,30],
                                            colors: [
                                                UIColor.ch_hex(0xDDDDDD),
                                                UIColor.ch_hex(0xF9EE30),
                                                UIColor.ch_hex(0xF600FF),
                                                ], section: volumeSection)
        let volumeEMASeries = CHSeries.getMA(isEMA: true, num: [5,10,30],
                                             colors: [
                                                UIColor.ch_hex(0xDDDDDD),
                                                UIColor.ch_hex(0xF9EE30),
                                                UIColor.ch_hex(0xF600FF),
                                                ], section: volumeSection)
        volumeEMASeries.hidden = true
        volumeSection.series = [volumeSeries, volumeMASeries, volumeEMASeries]
        
        let trendSection = CHSection()
        trendSection.backgroundColor = UIColor.ch_hex(0x1D1C1C)
        trendSection.valueType = .analysis
        trendSection.hidden = false
        trendSection.showTitle = false
        trendSection.ratios = 1
        trendSection.paging = true
        trendSection.yAxis.tickInterval = 2
        trendSection.padding = UIEdgeInsets(top: 10, left: 0, bottom: 4, right: 0)
        let kdjSeries = CHSeries.getKDJ(UIColor.ch_hex(0xDDDDDD),
                                        dc: UIColor.ch_hex(0xF9EE30),
                                        jc: UIColor.ch_hex(0xF600FF),
                                        section: trendSection)
        kdjSeries.title = "KDJ(9,3,3)"
        
        let macdSeries = CHSeries.getMACD(UIColor.ch_hex(0xDDDDDD),
                                          deac: UIColor.ch_hex(0xF9EE30),
                                          barc: UIColor.ch_hex(0xF600FF),
                                          upColor: upcolor, downColor: downcolor,
                                          section: trendSection)
        macdSeries.title = "MACD(12,26,9)"
        macdSeries.symmetrical = true
        trendSection.series = [
            macdSeries,
            kdjSeries,
        ]
        
        style.sections = [priceSection, volumeSection, trendSection]
        style.showYLabel = .right
        
        return style
    }
}
