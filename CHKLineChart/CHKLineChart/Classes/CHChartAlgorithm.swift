//
//  CHChartAlgorithm.swift
//  CHKLineChart
//
//  Created by 麦志泉 on 16/9/14.
//  Copyright © 2016年 bitbank. All rights reserved.
//

import UIKit

/**
 技术指标算法
 */
public enum CHChartAlgorithm {
    
    case None                                   //无算法
    case MA(Int)                                //简单移动平均数
    case EMA(Int)                               //指数移动平均数
    case KDJ(Int, Int, Int)                     //随机指标
    case MACD(Int, Int, Int)                    //指数平滑异同平均线
    
    /**
     获取Key值的名称
     
     - parameter name: 可选的二级key
     
     - returns:
     */
    public func key(name: String = "") -> String {
        switch self {
        case .None:
            return ""
        case let .MA(num):
            return "MA\(num)_\(name)"
        case let .EMA(num):
            return "EMA\(num)_\(name)"
        case .KDJ(_, _, _):
            return "KDJ_\(name)"
        case .MACD(_, _, _):
            return "MACD_\(name)"
        
        }
    }
    
    /**
     处理算法
     
     - parameter datas:
     
     - returns:
     */
    public func handleAlgorithm(datas: [CHChartItem]) -> [CHChartItem] {
        switch self {
        case .None:
            return datas
        case let .MA(num):
            return self.handleMA(num, datas: datas)
        case let .EMA(num):
            //TODO
            return datas
        case let .KDJ(p1, p2, p3):
            return self.handleKDJ(p1, p2: p2, p3: p3, datas: datas)
        case .MACD(_, _, _):
            //TODO
            return datas
            
        }
    }
    
    
}

// MARK: - 《MA简单移动平均数》 处理算法
extension CHChartAlgorithm {
    
    /**
     处理MA运算
     
     - parameter num:   天数
     - parameter datas: 数据集
     */
    private func handleMA(num: Int, datas: [CHChartItem]) -> [CHChartItem] {
        for (index, data) in datas.enumerate() {
            let value = self.getMAValue(num, index: index, datas: datas)
            data.extVal["\(self.key(CHSectionValueType.Price.key))"] = value.0
            data.extVal["\(self.key(CHSectionValueType.Volume.key))"] = value.1
        }
        return datas
    }
    
    /**
     计算移动平均数MA
     
     - parameter num:   N
     - parameter index: 数据的位置
     
     - returns: MA数（价格，交易量）
     */
    private func getMAValue(num: Int, index: Int, datas: [CHChartItem]) -> (CGFloat?, CGFloat?) {
        var priceVal: CGFloat = 0
        var volVal: CGFloat = 0
        if index + 1 >= num {
            for i in index.stride(through: index + 1 - num, by: -1) {
                volVal += datas[i].vol
                priceVal += datas[i].closePrice
            }
            volVal = volVal / CGFloat(num)
            priceVal = priceVal / CGFloat(num)
            return (priceVal, volVal)
        } else {
            return (nil, nil)
        }
        
    }
    
}

// MARK: - 《KDJ随机指标》 处理算法
extension CHChartAlgorithm {
    
    /**
     处理KDJ运算
     
     - parameter p1:    指标分析周期
     - parameter p2:    指标分析周期
     - parameter p3:    指标分析周期
     - parameter datas: 未处理的集合
     
     - returns: 处理好的集合
     */
    private func handleKDJ(p1: Int, p2: Int,p3: Int, datas: [CHChartItem]) -> [CHChartItem] {
        var prev_k: CGFloat = 50;
        var prev_d: CGFloat = 50;
        for (index, data) in datas.enumerate() {
            //计算RSV值
            if let rsv = self.getRSV(p1, index: index, datas: datas) {
                //计算K,D,J值
                let k: CGFloat = (2 * prev_k + rsv) / 3
                let d: CGFloat = (2 * prev_d + k) / 3
                let j: CGFloat = 3 * k - 2 * d
                
                prev_k = k
                prev_d = d
                
                data.extVal["\(self.key("K"))"] = k
                data.extVal["\(self.key("D"))"] = d
                data.extVal["\(self.key("J"))"] = j
            }
        }
        return datas
    }
    
    /**
     RSV计算
     
     - parameter num:   计算天数范围
     - parameter index: 当前的索引位
     
     - returns:
     */
    private func getRSV(num: Int, index: Int, datas: [CHChartItem]) -> CGFloat? {
        var rsv: CGFloat = 0
        if index + 1 >= num {
            let c = datas[index].closePrice
            var h = datas[index].highPrice
            var l = datas[index].lowPrice
            //计算num天数内最低价，最高价
            for i in index.stride(through: index + 1 - num, by: -1) {
                let item = datas[i]
                
                if item.highPrice > h {
                    h = item.highPrice
                }
                
                if item.lowPrice < l {
                    l = item.lowPrice
                }
            }
            
            if h != l {
                rsv = (c - l) / (h - l) * 100
            }
            return rsv
        } else {
            return nil
        }
    }
    
}