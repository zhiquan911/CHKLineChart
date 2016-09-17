//
//  CHSeries.swift
//  CHKLineChart
//
//  Created by 麦志泉 on 16/9/13.
//  Copyright © 2016年 bitbank. All rights reserved.
//

import UIKit

/**
 系列对应的key值
 */
public struct CHSeriesKey {
    static let candle = "Candle"
    static let timeline = "Timeline"
    static let volume = "Volume"
    static let ma = "MA"
    static let ema = "EMA"
    static let kdj = "KDJ"
    static let macd = "MACD"
}

/**
 点线系列
 */
open class CHSeries: NSObject {
 
    var key = ""
    var title: String = ""
    var chartModels = [CHChartModel]()          //每个系列包含多个点线模型
    var hidden: Bool = false
    var baseValueSticky = false                 //是否以固定基值显示最小或最大值，若超过范围
    var symmetrical = false                     //是否以固定基值为中位数，对称显示最大最小值
    
}

// MARK: - 工厂方法
extension CHSeries {
    
    /**
     返回一个标准的价格系列样式
     */
    class func getDefaultPrice(upColor: UIColor, downColor: UIColor, section: CHSection) -> CHSeries {
        let series = CHSeries()
        series.key = CHSeriesKey.candle
        let candle = CHChartModel.getCandle(upColor: upColor, downColor: downColor)
        candle.section = section
        candle.useTitleColor = false
        series.chartModels = [candle]
        return series
    }
    
    /**
     返回一个标准的交易量系列样式
     */
    class func getDefaultVolume(upColor: UIColor, downColor: UIColor, section: CHSection) -> CHSeries {
        let series = CHSeries()
        series.key = CHSeriesKey.volume
        let vol = CHChartModel.getVolume(upColor: upColor, downColor: downColor)
        vol.section = section
        vol.useTitleColor = false
        series.chartModels = [vol]
        return series
    }
    
    /**
     返回一个移动平均线系列样式
     */
    class func getMA(isEMA: Bool = false, num: [Int], colors: [UIColor], section: CHSection) -> CHSeries {
        var key = ""
        if isEMA {
            key = CHSeriesKey.ema
        } else {
            key = CHSeriesKey.ma
        }
        
        let series = CHSeries()
        series.key = key
        for (i, n) in num.enumerated() {
            
            let ma = CHChartModel.getLine(colors[i], title: "\(key)\(n)", key: "\(key)\(n)_\(section.valueType.key)")
            ma.section = section
            series.chartModels.append(ma)
        }
        return series
    }
    
    /**
     返回一个KDJ系列样式
     */
    class func getKDJ(_ kc: UIColor, dc: UIColor, jc: UIColor, section: CHSection) -> CHSeries {
        let series = CHSeries()
        series.key = CHSeriesKey.kdj
        let k = CHChartModel.getLine(kc, title: "K", key: "KDJ_K")
        k.section = section
        let d = CHChartModel.getLine(dc, title: "D", key: "KDJ_D")
        d.section = section
        let j = CHChartModel.getLine(jc, title: "J", key: "KDJ_J")
        j.section = section
        series.chartModels = [k, d, j]
        return series
    }
    
    /**
     返回一个MACD系列样式
     */
    class func getMACD(_ difc: UIColor, deac: UIColor, barc: UIColor,
                       upColor: UIColor, downColor: UIColor, section: CHSection) -> CHSeries {
        let series = CHSeries()
        series.key = CHSeriesKey.macd
        let dif = CHChartModel.getLine(difc, title: "DIF", key: "MACD_DIF")
        dif.section = section
        let dea = CHChartModel.getLine(deac, title: "DEA", key: "MACD_DEA")
        dea.section = section
        let bar = CHChartModel.getBar(upColor: upColor, downColor: downColor, titleColor: barc, title: "BAR", key: "MACD_BAR")
        bar.section = section
        series.chartModels = [dif, dea, bar]
        return series
    }
}
