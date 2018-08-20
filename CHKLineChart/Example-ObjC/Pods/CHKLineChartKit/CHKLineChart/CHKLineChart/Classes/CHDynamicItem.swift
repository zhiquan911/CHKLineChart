//
//  CHDynamicItem.swift
//  CHKLineChart
//
//  Created by Chance on 2017/6/21.
//  Copyright © 2017年 bitbank. All rights reserved.
//

import UIKit

class CHDynamicItem: NSObject, UIDynamicItem {

    var center: CGPoint = .zero
    var bounds: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1)
    var transform: CGAffineTransform = CGAffineTransform.identity
    
}
