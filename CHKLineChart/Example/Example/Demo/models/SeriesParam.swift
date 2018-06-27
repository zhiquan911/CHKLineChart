//
//  ChartIndex.swift
//  Example
//
//  Created by Chance on 2018/3/1.
//  Copyright © 2018年 Chance. All rights reserved.
//

import Foundation
import CHKLineChartKit

class SeriesParamControl: NSObject, Codable {
    var value: Double = 0
    var note: String = ""
    var min: Double = 0
    var max: Double = 0
    var step: Double = 0
    
    convenience init(value: Double, note: String, min: Double, max: Double, step: Double) {
        self.init()
        self.value = value
        self.note = note
        self.min = min
        self.max = max
        self.step = step
    }
}

/// 指标线参数设置
class SeriesParam: NSObject, Codable {
    
    var seriesKey: String = ""
    var name: String = ""
    var params: [SeriesParamControl] = [SeriesParamControl]()
    var order: Int = 0
    var hidden: Bool = false
    
    convenience init(seriesKey: String, name: String, params: [SeriesParamControl], order: Int, hidden: Bool) {
        self.init()
        self.seriesKey = seriesKey
        self.name = name
        self.params = params
        self.order = order
        self.hidden = hidden
    }
 
    /// 获取算法组
    func getAlgorithms() -> [CHChartAlgorithmProtocol] {
        var algorithms: [CHChartAlgorithmProtocol] = [CHChartAlgorithmProtocol]()
        switch seriesKey {
        case CHSeriesKey.ma:
            for p in self.params {
                let a = CHChartAlgorithm.ma(Int(p.value))
                algorithms.append(a)
            }
            
        case CHSeriesKey.ema:
            for p in self.params {
                let a = CHChartAlgorithm.ema(Int(p.value))
                algorithms.append(a)
            }
        case CHSeriesKey.kdj:
            let a = CHChartAlgorithm.kdj(Int(self.params[0].value), Int(self.params[1].value), Int(self.params[2].value))
            algorithms.append(a)
        case CHSeriesKey.macd:
            
            let p1 = CHChartAlgorithm.ema(Int(self.params[0].value))
            algorithms.append(p1)
            
            let p2 = CHChartAlgorithm.ema(Int(self.params[1].value))
            algorithms.append(p2)
            
            let a = CHChartAlgorithm.macd(Int(self.params[0].value), Int(self.params[1].value), Int(self.params[2].value))
            algorithms.append(a)
        case CHSeriesKey.boll:
            let ma = CHChartAlgorithm.ma(Int(self.params[0].value))        //计算BOLL，必须先计算到同周期的MA
            algorithms.append(ma)
            let a = CHChartAlgorithm.boll(Int(self.params[0].value), Int(self.params[1].value))
            algorithms.append(a)
        case CHSeriesKey.sar:
            let a = CHChartAlgorithm.sar(Int(self.params[0].value), CGFloat(self.params[1].value), CGFloat(self.params[2].value))
            algorithms.append(a)
        case CHSeriesKey.sam:
            let a = CHChartAlgorithm.sam(Int(self.params[0].value))
            algorithms.append(a)
        case CHSeriesKey.rsi:
            for p in self.params {
                let a = CHChartAlgorithm.rsi(Int(p.value))
                algorithms.append(a)
            }
        default:
            let a = CHChartAlgorithm.none
            algorithms.append(a)
        }
        return algorithms
    }
    
    /// 获取指标线段组
    func appendIn(masterSection: CHSection,
                   assistSections: CHSection...) {
        
        let styleParam = StyleParam.shared
        
        //分区点线样式
        let upcolor = (UIColor(hex: styleParam.upColor), true)
        let downcolor = (UIColor(hex: styleParam.downColor), true)
        
        let lineColors = [
            UIColor(hex: styleParam.lineColors[0]),
            UIColor(hex: styleParam.lineColors[1]),
            UIColor(hex: styleParam.lineColors[2]),
        ]
        
        switch seriesKey {
        case CHSeriesKey.ma:
            
            var maColor = [UIColor]()
            for i in 0..<self.params.count {
                maColor.append(lineColors[i])
            }
            
            let series = CHSeries.getPriceMA(
                isEMA: false,
                num: self.params.map {Int($0.value)},
                colors: maColor,
                section: masterSection)
            
            
            masterSection.series.append(series)
            
            for assistSection in assistSections {
                
                let volWithMASeries = CHSeries.getVolumeWithMA(upStyle: upcolor,
                                                               downStyle: downcolor,
                                                               isEMA: false,
                                                               num: self.params.map {Int($0.value)},
                                                               colors: maColor,
                                                               section: assistSection)
                
                assistSection.series.append(volWithMASeries)
            }
            
        case CHSeriesKey.ema:
            
            var emaColor = [UIColor]()
            for i in 0..<self.params.count {
                emaColor.append(lineColors[i])
            }
            
            let series = CHSeries.getPriceMA(
                isEMA: true,
                num: self.params.map {Int($0.value)},
                colors: emaColor,
                section: masterSection)
            
            
            masterSection.series.append(series)
            
        case CHSeriesKey.kdj:
            
            for assistSection in assistSections {
                
                let kdjSeries = CHSeries.getKDJ(
                    lineColors[0],
                    dc: lineColors[1],
                    jc: lineColors[2],
                    section: assistSection)
                kdjSeries.title = "KDJ(\(self.params[0].value.toString()),\(self.params[1].value.toString()),\(self.params[2].value.toString()))"
                
                assistSection.series.append(kdjSeries)
            }
            
        case CHSeriesKey.macd:
            for assistSection in assistSections {
                
                let macdSeries = CHSeries.getMACD(
                    lineColors[0],
                    deac: lineColors[1],
                    barc: lineColors[2],
                    upStyle: upcolor, downStyle: downcolor,
                    section: assistSection)
                macdSeries.title = "MACD(\(self.params[0].value.toString()),\(self.params[1].value.toString()),\(self.params[2].value.toString()))"
                macdSeries.symmetrical = true
                
                assistSection.series.append(macdSeries)
            }
        case CHSeriesKey.boll:
            
            let priceBOLLSeries = CHSeries.getBOLL(
                lineColors[0],
                ubc: lineColors[1],
                lbc: lineColors[2],
                section: masterSection)
            
            priceBOLLSeries.hidden = true
            
            masterSection.series.append(priceBOLLSeries)
            
        case CHSeriesKey.sar:
            
            let priceSARSeries = CHSeries.getSAR(
                upStyle: upcolor,
                downStyle: downcolor,
                titleColor: lineColors[0],
                section: masterSection)
            
            priceSARSeries.hidden = true
            
            masterSection.series.append(priceSARSeries)
            
        case CHSeriesKey.sam:
            
            let priceSAMSeries = CHSeries.getPriceSAM(num: Int(self.params[0].value), barStyle: (UIColor.yellow, false), lineColor: UIColor(white: 0.4, alpha: 1), section: masterSection)
            
            priceSAMSeries.hidden = true
            
            masterSection.series.append(priceSAMSeries)
            
            for assistSection in assistSections {
                
                let volWithSAMSeries = CHSeries.getVolumeWithSAM(upStyle: upcolor,
                                                                 downStyle: downcolor,
                                                                 num: Int(self.params[0].value),
                                                                 barStyle: (UIColor.yellow, false),
                                                                 lineColor: UIColor(white: 0.4, alpha: 1),
                                                                 section: assistSection)
                
                assistSection.series.append(volWithSAMSeries)
            }
            
        case CHSeriesKey.rsi:
        
            var maColor = [UIColor]()
            for i in 0..<self.params.count {
                maColor.append(lineColors[i])
            }
            
            for assistSection in assistSections {
                let series = CHSeries.getRSI(
                num: self.params.map {Int($0.value)},
                colors: maColor,
                section: assistSection)
                assistSection.series.append(series)
            }
            
        default:break
        }
    }

}

class SeriesParamList: NSObject, Codable{
    
    var results: [SeriesParam] = [SeriesParam]()
    let error: Bool = false
    
    static var shared: SeriesParamList = {
        let instance = SeriesParamList()
        return instance
    }()
    
    /// 读取用户指标配置
    ///
    /// - Returns:
    func loadUserData() -> [SeriesParam] {
        
        guard results.isEmpty else {
            return self.results
        }
        
        guard let json = UserDefaults.standard.value(forKey: "SeriesParamList") as? String else {
            self.results = SeriesParamList.shared.defaultList
            return self.results
        }
        
        guard let jsonData = json.data(using: String.Encoding.utf8) else {
            self.results = SeriesParamList.shared.defaultList
            return self.results
        }
        
        let jsonDecoder = JSONDecoder()
        do {
            let sp = try jsonDecoder.decode(SeriesParamList.self, from: jsonData)
            self.results = sp.results.sorted { $0.order < $1.order }
            return self.results
        } catch _ {
            self.results = SeriesParamList.shared.defaultList
            return self.results
        }
    }
    
    /// 重置为默认
    func resetDefault() {
        self.results = SeriesParamList.shared.defaultList
        _ = self.saveUserData()
    }
    
    /// 保存用户设置指标数据
    ///
    /// - Parameter data:
    /// - Returns:
    func saveUserData() -> Bool {
        
        if results.isEmpty {
            return false
        }
    
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(self)
            let jsonString = String(data: jsonData, encoding: .utf8)
            UserDefaults.standard.set(jsonString, forKey: "SeriesParamList")
            UserDefaults.standard.synchronize()
            return true
        } catch _ {
            return false
        }
        
        
    }
}

extension SeriesParamList {
    
    /// 默认值
    var defaultList: [SeriesParam] {
        let ma = SeriesParam(seriesKey: CHSeriesKey.ma,
                             name: CHSeriesKey.ma,
                             params: [
                                SeriesParamControl(value: 5, note: "周期均线", min: 5, max: 120, step: 1),
                                SeriesParamControl(value: 10, note: "周期均线", min: 5, max: 120, step: 1),
                                SeriesParamControl(value: 30, note: "周期均线", min: 5, max: 120, step: 1),
                                ],
                             order: 0,
                             hidden: false)
        
        let ema = SeriesParam(seriesKey: CHSeriesKey.ema,
                              name: CHSeriesKey.ema,
                              params: [
                                SeriesParamControl(value: 5, note: "周期均线", min: 5, max: 120, step: 1),
                                SeriesParamControl(value: 10, note: "周期均线", min: 5, max: 120, step: 1),
                                SeriesParamControl(value: 30, note: "周期均线", min: 5, max: 120, step: 1),
                                ],
                              order: 1,
                              hidden: false)
        
        let boll = SeriesParam(seriesKey: CHSeriesKey.boll,
                               name: CHSeriesKey.boll,
                               params: [
                                SeriesParamControl(value: 20, note: "日布林线", min: 2, max: 120, step: 1),
                                SeriesParamControl(value: 2, note: "倍宽度", min: 1, max: 100, step: 1),
                                ],
                               order: 2,
                               hidden: false)
        
        let sar = SeriesParam(seriesKey: CHSeriesKey.sar,
                              name: CHSeriesKey.sar,
                              params: [
                                SeriesParamControl(value: 4, note: "基准周期", min: 4, max: 12, step: 2),
                                SeriesParamControl(value: 0.02, note: "最小加速", min: 0.02, max: 0.2, step: 0.01),
                                SeriesParamControl(value: 0.2, note: "最大加速", min: 0.02, max: 0.2, step: 0.01),
                                ],
                              order: 3,
                              hidden: false)
        
        let sam = SeriesParam(seriesKey: CHSeriesKey.sam,
                              name: CHSeriesKey.sam,
                              params: [
                                SeriesParamControl(value: 60, note: "统计周期", min: 10, max: 120, step: 1),
                                ],
                              order: 4,
                              hidden: false)
        
        let kdj = SeriesParam(seriesKey: CHSeriesKey.kdj,
                              name: CHSeriesKey.kdj,
                              params: [
                                SeriesParamControl(value: 9, note: "周期", min: 2, max: 90, step: 1),
                                SeriesParamControl(value: 3, note: "周期", min: 2, max: 30, step: 1),
                                SeriesParamControl(value: 3, note: "周期", min: 2, max: 30, step: 1),
                                ],
                              order: 5,
                              hidden: false)
        
        let macd = SeriesParam(seriesKey: CHSeriesKey.macd,
                               name: CHSeriesKey.macd,
                               params: [
                                SeriesParamControl(value: 12, note: "快线移动平均", min: 2, max: 60, step: 1),
                                SeriesParamControl(value: 26, note: "慢线移动平均", min: 2, max: 90, step: 1),
                                SeriesParamControl(value: 9, note: "移动平均", min: 2, max: 60, step: 1),
                                ],
                               order: 6,
                               hidden: false)
        
        let rsi = SeriesParam(seriesKey: "RSI",
                     name: "RSI",
                     params: [
                        SeriesParamControl(value: 6, note: "相对强弱指数", min: 5, max: 120, step: 1),
                        SeriesParamControl(value: 12, note: "相对强弱指数", min: 5, max: 120, step: 1),
                        SeriesParamControl(value: 24, note: "相对强弱指数", min: 5, max: 120, step: 1),
                        ],
                     order: 7,
                     hidden: false)
        return [
            ma,
            ema,
            boll,
            sar,
            sam,
            kdj,
            macd,
            rsi
        ]
    }
    
}

