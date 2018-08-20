//
//  YAxis.swift
//  CHKLineChart
//
//  Created by Chance on 16/8/31.
//  Copyright © 2016年 Chance. All rights reserved.
//

import Foundation
import UIKit




/**
 Y轴显示的位置
 
 - Left:  左边
 - Right: 右边
 - None:  不显示
 */
public enum CHYAxisShowPosition {
    case left, right, none
}

/// 坐标轴辅助线样式风格
///
/// - none: 不显示
/// - dash: 虚线
/// - solid: 实线
public enum CHAxisReferenceStyle {
    case none
    case dash(color: UIColor, pattern: [NSNumber])
    case solid(color: UIColor)
}

/**
 *  Y轴数据模型
 */
public struct CHYAxis {
    
    public var max: CGFloat = 0                //Y轴的最大值
    public var min: CGFloat = 0                //Y轴的最小值
    public var ext: CGFloat = 0.00             //上下边界溢出值的比例
    public var baseValue: CGFloat = 0          //固定的基值
    public var tickInterval: Int = 4           //间断显示个数
    public var pos: Int = 0
    public var decimal: Int = 2                //约束小数位
    public var isUsed = false
    
    /// 辅助线样式
    public var referenceStyle: CHAxisReferenceStyle = .dash(color: UIColor(white: 0.2, alpha: 1), pattern: [5])
    
}

/**
 *  X轴数据模型
 */
public struct CHXAxis {
    
    public var tickInterval: Int = 6           //间断显示个数
    
    /// 辅助线样式
    public var referenceStyle: CHAxisReferenceStyle = .none
}
