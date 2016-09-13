//
//  CHSeries.swift
//  CHKLineChart
//
//  Created by 麦志泉 on 16/9/13.
//  Copyright © 2016年 bitbank. All rights reserved.
//

import UIKit

class CHSeries: NSObject {
    
    var title: String = ""
    var chartModels = [CHChartModel]()                  //每个系列包含多个点线模型

}

// MARK: - 工厂方法
extension CHSeries {
    
    /**
     返回一个标准的价格系列样式
     */
    class func getDefaultPrice(upColor upColor: UIColor, downColor: UIColor, section: CHSection) -> CHSeries {
        let series = CHSeries()
        let candle = CHChartModel.getCandle(upColor: upColor, downColor: downColor)
        candle.section = section
        let ma5 = CHChartModel.getMA(UIColor.chHex(0xDDDDDD), num: 5)
        ma5.section = section
        let ma10 = CHChartModel.getMA(UIColor.chHex(0xF9EE30), num: 10)
        ma10.section = section
        let ma30 = CHChartModel.getMA(UIColor.chHex(0xF600FF), num: 30)
        ma30.section = section
        series.chartModels = [candle, ma5, ma10, ma30]
        return series
    }
    
    /**
     返回一个标准的交易量系列样式
     */
    class func getDefaultVolume(upColor upColor: UIColor, downColor: UIColor, section: CHSection) -> CHSeries {
        let series = CHSeries()
        let vol = CHChartModel.getVolume(upColor: upColor, downColor: downColor)
        vol.section = section
        let ma5 = CHChartModel.getMA(UIColor.chHex(0xDDDDDD), num: 5)
        ma5.section = section
        let ma10 = CHChartModel.getMA(UIColor.chHex(0xF9EE30), num: 10)
        ma10.section = section
        let ma30 = CHChartModel.getMA(UIColor.chHex(0xF600FF), num: 30)
        ma30.section = section
        series.chartModels = [vol, ma5, ma10, ma30]
        return series
    }
    
    /**
     返回一个KDJ系列样式
     */
    class func getKDJ(kc: UIColor, dc: UIColor, jc: UIColor, section: CHSection) -> CHSeries {
        let series = CHSeries()
        let k = CHChartModel.getKDJ(kc,name: "K")
        k.section = section
        let d = CHChartModel.getKDJ(dc,name: "D")
        d.section = section
        let j = CHChartModel.getKDJ(jc,name: "J")
        j.section = section
        series.chartModels = [k, d, j]
        return series
    }
}