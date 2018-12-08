//
//  String+extension.swift
//  
//
//  Created by Chance on 15/8/29.
//  Copyright (c) 2015年 atall.io All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    
    /// 字符串长度
    var length: Int {
        return self.count
    }
    
    /**
     截取数字字符串，小数位大于8位则截取小数8位后的数字
     
     - parameter string: 要截取的字符串
     
     - returns: 返回新的字符串
     */
    func subString(def:Int = 8) -> String{
        let stringArr = self.components(separatedBy: ".")
        var newString = ""
        if stringArr.count == 2 {
            if stringArr[1].length > def{
                newString = String(format: "%.\(def)f", (self.toDouble()))
            }else{
                newString = self
            }
            if newString.toDouble() == 0{
                newString = "0"
            }
        }else{
            newString = self
        }
        
        
        
        return newString
    }
    
    /**
     计算文字的高度
     
     - parameter font:
     - parameter size:
     
     - returns:
     */
    func textSizeWithFont(_ font: UIFont, constrainedToSize size:CGSize) -> CGSize {
        var textSize:CGSize!
        let newStr = NSString(string: self)
        if size.equalTo(CGSize.zero) {
            let attributes = [NSAttributedString.Key.font: font]
            textSize = newStr.size(withAttributes: attributes)
        } else {
            let option = NSStringDrawingOptions.usesLineFragmentOrigin
            let attributes = [NSAttributedString.Key.font: font]
            let stringRect = newStr.boundingRect(with: size, options: option, attributes: attributes, context: nil)
            textSize = stringRect.size
        }
        return textSize
    }
    
    // MARK: Trim API
    
    /// 去掉字符串前后的空格，根据参数确定是否过滤换行符
    ///
    /// - parameter trimNewline 是否过滤换行符，默认为false
    ///
    /// - returns:   处理后的字符串
    func trim(_ trimNewline: Bool = false) ->String {
        if trimNewline {
            return self.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        return self.trimmingCharacters(in: .whitespaces)
    }
    
    // MARK: Substring API
    
    /// 获取子串的起始位置。
    ///
    /// - parameter substring 待查找的子字符串
    ///
    /// - returns:  如果找不到子串，返回NSNotFound，否则返回其所在起始位置
    func location(_ substring: String) ->Int {
        return (self as NSString).range(of: substring).location
    }
    
    /// 根据起始位置和长度获取子串。
    ///
    /// - parameter location  获取子串的起始位置
    /// - parameter length    获取子串的长度
    ///
    /// - returns:  如果位置和长度都合理，则返回子串，否则返回nil
    func substring(_ location: Int, length: Int) ->String? {
        if location < 0 && location >= self.length {
            return nil
        }
        
        if length <= 0 || length >= self.length {
            return nil
        }
        
        return (self as NSString).substring(with: NSMakeRange(location, length))
    }
    
    /// 根据下标获取对应的字符。若索引正确，返回对应的字符，否则返回nil
    ///
    /// - parameter index 索引位置
    ///
    /// - returns: 如果位置正确，返回对应的字符，否则返回nil
    subscript(index: Int) ->Character? {
        get {
            if let str = substring(index, length: 1) {
                return Character(str)
            }
            
            return nil
        }
    }
    
    /// 判断字符串是否包含子串。
    ///
    /// - parameter substring 子串
    ///
    /// - returns:  如果找到，返回true,否则返回false
    func isContain(_ substring: String) ->Bool {
        return (self as NSString).contains(substring)
    }
    
    // MARK: Alphanum API
    
    /// 判断字符串是否全是数字组成
    ///
    /// - returns:  若为全数字组成，返回true，否则返回false
    func isOnlyNumbers() ->Bool {
        let set = CharacterSet.decimalDigits.inverted
        let range = (self as NSString).rangeOfCharacter(from: set)
        let flag = range.location != NSNotFound
        return flag
    }
    
    /// 判断字符串是否全是字母组成
    ///
    /// - returns:  若为全字母组成，返回true，否则返回false
    func isOnlyLetters() ->Bool {
        let set = CharacterSet.letters.inverted
        let range = (self as NSString).rangeOfCharacter(from: set)
        
        return range.location != NSNotFound
    }
    
    /// 判断字符串是否全是字母和数字组成
    ///
    /// - returns:  若为全字母和数字组成，返回true，否则返回false
    func isAlphanum() ->Bool {
        let set = CharacterSet.alphanumerics.inverted
        let range = (self as NSString).rangeOfCharacter(from: set)
        
        return range.location != NSNotFound
    }
    
    // MARK: Validation API
    
    /// 判断字符串是否是有效的邮箱格式
    ///
    /// - returns:  若为有效的邮箱格式，返回true，否则返回false
    func isValidEmail() ->Bool {
        let regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regEx)
        
        return predicate.evaluate(with: self)
    }
    
    // MARK: Format API
    
    /**
     
     插入字符分隔字符串
     - parameter char:     要插入的字符
     - parameter interval: 间隔数
     */
    func insertCharByInterval(_ char: String, interval: Int) -> String {
        var text = self as NSString
        var newString = ""
        while (text.length > 0) {
            let subString = text.substring(to: min(text.length,interval))
            newString = newString + subString
            if (subString.length == interval) {
                newString = newString + char
            }
            text = text.substring(from: min(text.length,interval)) as NSString
        }
        return newString
    }
    
    
    // MARK: CAST TO OTHER TYPE API
    
    /// 转double
    ///
    /// - Parameters:
    ///   - def: 默认值
    ///   - decimal: 舍弃小数位精度
    /// - Returns:
    func toDouble(_ def: Double = 0.0, decimal: Int? = nil) -> Double {
        if !self.isEmpty {
            var doubleValue = Double(self) ?? def
            if let dec = decimal {
                doubleValue = doubleValue.f(places: dec)
            }
            return doubleValue
        } else {
            return def
        }
    }
    
    func toFloat(_ def: Float = 0.0) -> Float {
        if !self.isEmpty {
            return Float(self) ?? def
        } else {
            return def
        }
    }
    
    func toInt(_ def: Int = 0) -> Int {
        if !self.isEmpty {
            return Int(self)!
        } else {
            return def
        }
    }
    
    func toBool(_ def: Bool = false) -> Bool {
        if !self.isEmpty {
            let value = Int(self)!
            if value > 0 {
                return true
            } else {
                return false
            }
        } else {
            return def
        }
    }
    
    
}
