//
//  CHExtension.swift
//  CHKLineChart
//
//  Created by Chance on 16/9/8.
//  Copyright © 2016年 Chance. All rights reserved.
//

import Foundation
import UIKit

//String类扩展
public extension String {
    
    /**
     计算文字的宽度
     
     - parameter width:
     - parameter font:
     
     - returns:
     */
    func ch_sizeWithConstrained(_ font: UIFont,
                                constraintRect: CGSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)) -> CGSize {
        let boundingBox = self.boundingRect(
            with: constraintRect,
            options: NSStringDrawingOptions.usesLineFragmentOrigin,
            attributes: [NSAttributedStringKey.font: font],
            context: nil)
        return boundingBox.size
    }
    
    /// 字符串长度
    var ch_length: Int {
        return self.count;
    }
}


public extension UIColor {
    
    /**
     16进制表示颜色
     
     - parameter hex:
     
     - returns:
     */
    class func ch_hex(_ hex: UInt, alpha: Float = 1.0) -> UIColor {
        return UIColor(red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
                       green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
                       blue: CGFloat(hex & 0x0000FF) / 255.0,
                       alpha: CGFloat(alpha))
    }
    
}

public extension Date {
    
    /*!
     * @method 把时间戳转换为用户格式时间
     * @abstract
     * @discussion
     * @param   timestamp     时间戳
     * @param   format        格式
     * @result                时间
     */
    static func ch_getTimeByStamp(_ timestamp: Int, format: String) -> String {
        var time = ""
        if (timestamp == 0) {
            return ""
        }
        let confromTimesp = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateFormat = format
        time = formatter.string(from: confromTimesp)
        return time;
    }
}


public extension CGFloat {
    
    /**
     转化为字符串格式
     
     - parameter minF:
     - parameter maxF:
     - parameter minI:
     
     - returns:
     */
    func ch_toString(_ minF: Int = 2, maxF: Int = 6, minI: Int = 1) -> String {
        let valueDecimalNumber = NSDecimalNumber(value: Double(self) as Double)
        let twoDecimalPlacesFormatter = NumberFormatter()
        twoDecimalPlacesFormatter.maximumFractionDigits = maxF
        twoDecimalPlacesFormatter.minimumFractionDigits = minF
        twoDecimalPlacesFormatter.minimumIntegerDigits = minI
        return twoDecimalPlacesFormatter.string(from: valueDecimalNumber)!
    }
}

public extension Array where Element: Equatable {
    
    subscript (safe index: Int) -> Element? {
        return (0..<count).contains(index) ? self[index] : nil
    }
    
    mutating func ch_removeObject(_ object: Element) {
        if let index = self.index(of: object) {
            self.remove(at: index)
        }
    }
    
    mutating func ch_removeObjectsInArray(_ array: [Element]) {
        for object in array {
            self.ch_removeObject(object)
        }
    }
}
