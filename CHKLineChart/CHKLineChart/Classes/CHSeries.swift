//
//  CHSeries.swift
//  CHKLineChart
//
//  Created by 麦志泉 on 16/9/13.
//  Copyright © 2016年 bitbank. All rights reserved.
//

import UIKit

open class CHSeries: NSObject {
    
    open var title: String = ""
    open var chartModels = [CHChartModel]()                       //每个系列包含多个点线模型
}

// MARK: - 工厂方法
extension CHSeries {
    
    /**
     返回一个标准的价格系列样式
     */
    class func getDefaultPrice(upColor: UIColor, downColor: UIColor, section: CHSection) -> CHSeries {
        let series = CHSeries()
        let candle = CHChartModel.getCandle(upColor: upColor, downColor: downColor)
        candle.section = section
        let ma5 = CHChartModel.getLine(UIColor.ch_hex(0xDDDDDD), title: "EMA5", key: "EMA5_\(section.valueType.key)")
        ma5.section = section
        let ma10 = CHChartModel.getLine(UIColor.ch_hex(0xF9EE30), title: "EMA10", key: "EMA10_\(section.valueType.key)")
        ma10.section = section
        let ma30 = CHChartModel.getLine(UIColor.ch_hex(0xF600FF), title: "EMA30", key: "EMA30_\(section.valueType.key)")
        ma30.section = section
        series.chartModels = [candle, ma5, ma10, ma30]
        return series
    }
    
    /**
     返回一个标准的交易量系列样式
     */
    class func getDefaultVolume(upColor: UIColor, downColor: UIColor, section: CHSection) -> CHSeries {
        let series = CHSeries()
        let vol = CHChartModel.getVolume(upColor: upColor, downColor: downColor)
        vol.section = section
        let ma5 = CHChartModel.getLine(UIColor.ch_hex(0xDDDDDD), title: "EMA5", key: "EMA5_\(section.valueType.key)")
        ma5.section = section
        let ma10 = CHChartModel.getLine(UIColor.ch_hex(0xF9EE30), title: "EMA10", key: "EMA10_\(section.valueType.key)")
        ma10.section = section
        let ma30 = CHChartModel.getLine(UIColor.ch_hex(0xF600FF), title: "EMA30", key: "EMA30_\(section.valueType.key)")
        ma30.section = section
        series.chartModels = [vol, ma5, ma10, ma30]
        return series
    }
    
    /**
     返回一个KDJ系列样式
     */
    class func getKDJ(_ kc: UIColor, dc: UIColor, jc: UIColor, section: CHSection) -> CHSeries {
        let series = CHSeries()
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
    class func getMACD(_ difc: UIColor, deac: UIColor, barc: UIColor, section: CHSection) -> CHSeries {
        let series = CHSeries()
        let dif = CHChartModel.getLine(difc, title: "DIF", key: "MACD_DIF")
        dif.section = section
        let dea = CHChartModel.getLine(deac, title: "DEA", key: "MACD_DEA")
        dea.section = section
        let bar = CHChartModel.getLine(barc, title: "BAR", key: "MACD_BAR")
        bar.section = section
        series.chartModels = [dif, dea, bar]
        return series
    }
}
