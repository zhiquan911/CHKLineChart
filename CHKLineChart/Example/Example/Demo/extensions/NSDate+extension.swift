//
//  NSDate+extension.swift
//  chbtc
//
//  Created by Chance on 15/12/17.
//  Copyright © 2015年 atall.io. All rights reserved.
//

import Foundation

extension Date {
    
    /*!
     * @method 把时间戳转换为用户格式时间
     * @abstract
     * @discussion
     * @param   timestamp     时间戳
     * @param   format        格式
     * @result                时间
     */
    static func getTimeByStamp(timestamp: Int, format: String) -> String {
        var time = ""
        if (timestamp == 0) {
            return ""
        }
        let confromTimesp = NSDate(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateFormat = format
        time = formatter.string(from: confromTimesp as Date)
        return time;
    }
    
    /*!
     * @method 返回2分钟前、2小时前、2天前、2月前、2年前等近似的时间表示
     * @abstract
     * @discussion
     * @param 时间戳
     * @result 近似的时间
     */
    static func getShortTimeByStamp(timestamp: Int) -> String {
        let compareDate = NSDate(timeIntervalSince1970: TimeInterval(timestamp))
        var timeInterval: Double = compareDate.timeIntervalSinceNow
        timeInterval = -timeInterval;
        var temp: Double = 0;
        var result = ""
        if (timeInterval < 60) {
            result = "刚刚"
        } else if((timeInterval / 60) < 60){
            temp = timeInterval / 60
            result = "\(Int(temp))分钟前"
        } else if((timeInterval / 60 / 60) < 24){
            temp = timeInterval / 60 / 60
            result = "\(Int(temp))小时前"
        } else if((timeInterval / 60 / 60 / 24) < 30){
            temp = timeInterval / 60 / 60 / 24
            result = "\(Int(temp))天前"
        } else if((timeInterval / 60 / 60 / 24 / 30) < 12){
            temp = timeInterval / 60 / 60 / 24 / 30
            result = "\(Int(temp))个月前"
        } else {
            temp = timeInterval / 60 / 60 / 24 / 30 / 12;
            result = "\(Int(temp))年前"
        }
        
        return result
    }
}
