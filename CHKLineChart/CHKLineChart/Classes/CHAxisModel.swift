//
//  YAxis.swift
//  CHKLineChart
//
//  Created by 麦志泉 on 16/8/31.
//  Copyright © 2016年 bitbank. All rights reserved.
//

import Foundation
import UIKit


/**
 *  Y轴数据模型
 */
public struct CHYAxis {
    
    var frame: CGRect = CGRectZero
    var max: CGFloat = 0                //Y轴的最大值
    var min: CGFloat = 0                //Y轴的最小值
    var ext: CGFloat = 0.05             //上下边界溢出值的比例
    var baseValue: CGFloat = 0          //固定的基值
    var baseValueSticky = false         //是否以固定基值显示最小或最大值，若超过范围
    var symmetrical = false             //是否以固定基值为中位数，对称显示最大最小值
    var tickInterval: Int = 6           //间断显示个数
    var pos: Int = 0
    var decimal: Int = 2                //约束小数位
    
}

/**
 *  X轴数据模型
 */
public struct CHXAxis {
    
    var tickInterval: Int = 6           //间断显示个数
}