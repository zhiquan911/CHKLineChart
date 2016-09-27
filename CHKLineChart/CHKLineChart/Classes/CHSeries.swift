//
//  CHSeries.swift
//  CHKLineChart
//
//  Created by Chance on 16/9/13.
//  Copyright © 2016年 bitbank. All rights reserved.
//

import UIKit

/**
 系列对应的key值
 */
public struct CHSeriesKey {
    public static let candle = "Candle"
    public static let timeline = "Timeline"
    public static let volume = "Volume"
    public static let ma = "MA"
    public static let ema = "EMA"
    public static let kdj = "KDJ"
    public static let macd = "MACD"
}

/**
 点线系列
 */
open class CHSeries: NSObject {
 
    open var key = ""
    open var title: String = ""
    open var chartModels = [CHChartModel]()          //每个系列包含多个点线模型
    open var hidden: Bool = false
    open var baseValueSticky = false                 //是否以固定基值显示最小或最大值，若超过范围
    open var symmetrical = false                     //是否以固定基值为中位数，对称显示最大最小值
    
}

// MARK: - 工厂方法
extension CHSeries {
    
    /**
     返回一个标准的价格系列样式
     */
    public class func getDefaultPrice(upColor: UIColor, downColor: UIColor, section: CHSection) -> CHSeries {
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
    public class func getDefaultVolume(upColor: UIColor, downColor: UIColor, section: CHSection) -> CHSeries {
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
    public class func getMA(isEMA: Bool = false, num: [Int], colors: [UIColor], section: CHSection) -> CHSeries {
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
    public class func getKDJ(_ kc: UIColor, dc: UIColor, jc: UIColor, section: CHSection) -> CHSeries {
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
    public class func getMACD(_ difc: UIColor, deac: UIColor, barc: UIColor,
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
