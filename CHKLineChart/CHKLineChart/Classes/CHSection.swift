//
//  CHSection.swift
//  CHKLineChart
//
//  Created by 麦志泉 on 16/8/31.
//  Copyright © 2016年 bitbank. All rights reserved.
//

import UIKit

/**
 *  K线的区域
 */
struct CHSection {
    var hidden: Bool = false
    var isInitialized: Bool = false
    var paging: Bool = false
    var selectedIndex: Int = 0
    var padding: UIEdgeInsets = UIEdgeInsetsZero
    var series = [String]()
    var yAxises = [CHYAxis]()
    var xAxises = [CHXAxis]()
    var tickInterval: Int = 0
}
