//
//  CHChartModel.swift
//  CHKLineChart
//
//  Created by 麦志泉 on 16/9/6.
//  Copyright © 2016年 bitbank. All rights reserved.
//

import UIKit

public enum CHChartModelType {
    case Line
    case Candle
    case Column
}

/**
 *  数据元素
 */
public struct CHChartItem {
    
    var time: Int = 0
    var openPrice: CGFloat = 0
    var closePrice: CGFloat = 0
    var lowPrice: CGFloat = 0
    var highPrice: CGFloat = 0
    var vol: CGFloat = 0
    
}

/**
 *  定义图表数据模型
 */
public class CHChartModel {
    
    /// MARK: - 成员变量
    public var upColor = UIColor.greenColor()                       //升的颜色
    public var downColor = UIColor.redColor()                       //跌的颜色
    public var datas: [CHChartItem] = [CHChartItem]()               //数据值
    public var decimal: Int = 2                                     //小数位的长度
    
    convenience init(upColor: UIColor,
                     downColor: UIColor,
                     datas: [CHChartItem],
                     decimal: Int = 2
        ) {
        self.init()
        self.upColor = upColor
        self.downColor = downColor
        self.datas = datas
        self.decimal = decimal
    }
    
    
}


/**
 *  线点样式模型
 */
public class CHLineModel: CHChartModel {
    

}

/**
 *  蜡烛样式模型
 */
public class CHCandleModel: CHChartModel {
                              

}

/**
 *  交易量样式模型
 */
public class CHColumnModel: CHChartModel {
    

}