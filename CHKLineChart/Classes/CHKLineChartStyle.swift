//
//  CHKLineChartStyle.swift
//  CHKLineChart
//
//  Created by 麦志泉 on 16/9/19.
//  Copyright © 2016年 bitbank. All rights reserved.
//

import Foundation
import UIKit

// MARK: - 图表样式配置类
open class CHKLineChartStyle {
    
    /**
     分区样式配置
     
     - returns:
     */
    var sections: [CHSection]!
    
    /**
     要处理的算法
     
     - returns:
     */
    var algorithms: [CHChartAlgorithm]!
    
    /**
     背景颜色
     
     - returns:
     */
    var backgroundColor: UIColor!
    
    /**
     边距
     
     - returns:
     */
    var padding: UIEdgeInsets!
    
    //字体大小
    var labelFont: UIFont!
    
    //线条颜色
    var lineColor: UIColor!
    
    //线条颜色
    var dashColor: UIColor!
    
    
    //文字颜色
    var textColor: UIColor!
    
    
    
}

// MARK: - 扩展样式
extension CHKLineChartStyle {
    
    //实现一个最基本的样式，开发者可以自由扩展配置样式
    class var base: CHKLineChartStyle {
        let style = CHKLineChartStyle()
        style.labelFont = UIFont.systemFont(ofSize: 10)
        style.lineColor = UIColor(white: 0.2, alpha: 1)
        style.dashColor = UIColor(white: 0.2, alpha: 1)
        style.textColor = UIColor(white: 0.8, alpha: 1)
        style.padding = UIEdgeInsets(top: 16, left: 8, bottom: 20, right: 0)
        style.backgroundColor = UIColor.ch_hex(0x1D1C1C)
        
        //配置图表处理算法
        style.algorithms = [
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
        let priceSeries = CHSeries.getDefaultPrice(upColor: upcolor, downColor: downcolor, section: priceSection)
        
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
        priceSection.series = [priceSeries, priceMASeries, priceEMASeries]
        
        let volumeSection = CHSection()
        volumeSection.valueType = .volume
        volumeSection.hidden = false
        volumeSection.ratios = 1
        volumeSection.yAxis.tickInterval = 3
        volumeSection.padding = UIEdgeInsets(top: 16, left: 0, bottom: 8, right: 0)
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
        trendSection.valueType = .analysis
        trendSection.hidden = false
        trendSection.ratios = 1
        trendSection.paging = true
        trendSection.yAxis.tickInterval = 3
        trendSection.padding = UIEdgeInsets(top: 16, left: 0, bottom: 8, right: 0)
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
            kdjSeries,
            macdSeries]
        
        style.sections = [priceSection, volumeSection, trendSection]
        
        return style
    }
}
