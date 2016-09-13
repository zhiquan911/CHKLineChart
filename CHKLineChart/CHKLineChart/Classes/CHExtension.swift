//
//  CHExtension.swift
//  CHKLineChart
//
//  Created by 麦志泉 on 16/9/8.
//  Copyright © 2016年 bitbank. All rights reserved.
//

import Foundation
import UIKit

//String类扩展
extension String {
    
    /**
     计算文字的宽度
     
     - parameter width:
     - parameter font:
     
     - returns:
     */
    func ch_heightWithConstrainedWidth(font: UIFont) -> CGSize {
        let constraintRect = CGSize(width: CGFloat.max, height: CGFloat.max)
        let boundingBox = self.boundingRectWithSize(constraintRect, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        return boundingBox.size
    }
    
}


extension UIColor {
    
    /**
     16进制表示颜色
     
     - parameter hex:
     
     - returns:
     */
    class func chHex(hex: UInt, alpha: Float = 1.0) -> UIColor {
        return UIColor(red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(hex & 0x0000FF) / 255.0,
                  alpha: CGFloat(alpha))
    }

}

extension NSDate {
    
    /*!
     * @method 把时间戳转换为用户格式时间
     * @abstract
     * @discussion
     * @param   timestamp     时间戳
     * @param   format        格式
     * @result                时间
     */
    class func getTimeByStamp(timestamp: Int, format: String) -> String {
        var time = ""
        if (timestamp == 0) {
            return ""
        }
        let confromTimesp = NSDate(timeIntervalSince1970: NSTimeInterval(timestamp))
        let formatter = NSDateFormatter()
        formatter.dateFormat = format
        time = formatter.stringFromDate(confromTimesp)
        return time;
    }
}


extension CGFloat {
    
    /**
     转化为字符串格式
     
     - parameter minF:
     - parameter maxF:
     - parameter minI:
     
     - returns:
     */
    func ch_toString(minF: Int = 2, maxF: Int = 6, minI: Int = 1) -> String {
        let valueDecimalNumber = NSDecimalNumber(double: Double(self))
        let twoDecimalPlacesFormatter = NSNumberFormatter()
        twoDecimalPlacesFormatter.maximumFractionDigits = maxF
        twoDecimalPlacesFormatter.minimumFractionDigits = minF
        twoDecimalPlacesFormatter.minimumIntegerDigits = minI
        return twoDecimalPlacesFormatter.stringFromNumber(valueDecimalNumber)!
    }
}