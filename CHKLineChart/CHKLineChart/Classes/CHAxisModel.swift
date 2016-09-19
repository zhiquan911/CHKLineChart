//
//  YAxis.swift
//  CHKLineChart
//
//  Created by Chance on 16/8/31.
//  Copyright © 2016年 bitbank. All rights reserved.
//

import Foundation
import UIKit


/**
 *  Y轴数据模型
 */
public struct CHYAxis {
    
    var max: CGFloat = 0                //Y轴的最大值
    var min: CGFloat = 0                //Y轴的最小值
    var ext: CGFloat = 0.00             //上下边界溢出值的比例
    var baseValue: CGFloat = 0          //固定的基值
    var tickInterval: Int = 4           //间断显示个数
    var pos: Int = 0
    var decimal: Int = 2                //约束小数位
    var isUsed = false
}

/**
 *  X轴数据模型
 */
public struct CHXAxis {
    
    var tickInterval: Int = 6           //间断显示个数
}
