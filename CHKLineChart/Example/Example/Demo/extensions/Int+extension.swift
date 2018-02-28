//
//  Int+extension.swift
//  Exx
//
//  Created by mqt on 2017/8/11.
//  Copyright © 2017年 mqt. All rights reserved.
//

import UIKit

extension Int {
    
    /**
     转化为字符串格式
     - returns:
     */
    func toString() -> String {
        return String(self)
    }
    
    /**
     把布尔变量转化为Int
     - returns:
     */
    init(_ value: Bool) {
        if value {
            self.init(1)
        } else {
            self.init(0)
        }
    }
    
    
    /// 转为bool型
    ///
    /// - Returns:
    func toBool() -> Bool {
        if self > 0 {
            return true
        } else {
            return false
        }
    }
}

