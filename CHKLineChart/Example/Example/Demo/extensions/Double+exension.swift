//
//  Double+exension.swift
//  Exx
//
//  Created by mqt on 2017/7/7.
//  Copyright © 2017年 mqt. All rights reserved.
//


import Foundation

extension Double {
    
    /**
     向下取第几位小数
     
     - parameter places: 第几位小数 ，1
     
     15.96 * 10.0 = 159.6
     floor(159.6) = 159.0
     159.0 / 10.0 = 15.9
     
     - returns:  15.96 =  15.9
     */
    func f(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return floor(self * divisor) / divisor
    }
    
    /**
     截取到第几位小数
     */
    func toFloor(_ places:Int) -> String {
        let divisor = pow(10.0, Double(places))
        return (floor(self * divisor) / divisor).toString(maxF: places)
    }
    
    /**
     转化为字符串格式
     
     - parameter minF:
     - parameter maxF:
     - parameter minI:
     
     - returns:
     */
    func toString(_ minF: Int = 0, maxF: Int = 10, minI: Int = 1) -> String {
        let valueDecimalNumber = NSDecimalNumber(value: self)
        let twoDecimalPlacesFormatter = NumberFormatter()
        twoDecimalPlacesFormatter.maximumFractionDigits = maxF
        twoDecimalPlacesFormatter.minimumFractionDigits = minF
        twoDecimalPlacesFormatter.minimumIntegerDigits = minI
        return twoDecimalPlacesFormatter.string(from: valueDecimalNumber)!
    }
    
    /**
     缩倍数
     
     - parameter multiole:除数（不为零）
     - parameter def:保留小数位
     */
    public func toMultiple(multiole:Int = 1,def:Int = 6)->String{
        var str = "0"
        if self > 1000 {
           str =  String(format: "%.\(def)fk", self / 1000)
        }else{
            str = self.toString().subString(def: def)
        }
        return str
    }
    /**
     除法结果转换为string
     
     - parameter divisor:除数（不为零）
     - parameter dec:保留小数位
     */
    func divideResultToString(divisor:Double?,dec:Int = 3)->String{
        guard let divisor = divisor,divisor != 0,self != 0 else {
            return ""
        }
        return String(format: "%.\(dec)f", self / divisor)
    }
    
    /**
     
     乘积换成String
     - parameter multi:乘数
     - parameter dec:保留小数位
     */
    func multiResultToString(multi:Double?,dec:Int = 3)->String{
        guard let multi = multi,self != 0,multi != 0 else {
            return ""
        }
        return String(format: "%.\(dec)f", self * multi)
    }
    
    /// 转为非0字符串
    /// 如果数值为0用replace替代
    func toNonZeroString(_ replace: String = "", minF: Int = 0, maxF: Int = 10, minI: Int = 1) -> String {
        if self == 0 {
            return replace
        } else {
            return toString(minF, maxF: maxF, minI: minI)
        }
    }
    
}
