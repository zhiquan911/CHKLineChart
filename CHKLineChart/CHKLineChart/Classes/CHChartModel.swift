//
//  CHChartModel.swift
//  CHKLineChart
//
//  Created by 麦志泉 on 16/9/6.
//  Copyright © 2016年 bitbank. All rights reserved.
//

import UIKit



/**
 改数据的走势方向
 
 - Up:    升
 - Down:  跌
 - Equal: 相等
 */
public enum CHChartItemTrend {
    case Up
    case Down
    case Equal
}

/**
 *  数据元素
 */
public class CHChartItem: NSObject {
    
    var time: Int = 0
    var openPrice: CGFloat = 0
    var closePrice: CGFloat = 0
    var lowPrice: CGFloat = 0
    var highPrice: CGFloat = 0
    var vol: CGFloat = 0
    var value: CGFloat?
    var extVal: [String: CGFloat] = [String: CGFloat]()        //扩展值，用来记录各种技术指标
    
    var trend: CHChartItemTrend {
        if closePrice == openPrice {
            return .Equal
            
        }else{
            //收盘价比开盘低
            if closePrice < openPrice {
                return .Down
            } else {
                //收盘价比开盘高
                return .Up
            }
        }
    }
    
}

/**
 *  定义图表数据模型
 */
public class CHChartModel {
    
    /// MARK: - 成员变量
    public var upColor = UIColor.greenColor()                       //升的颜色
    public var downColor = UIColor.redColor()                       //跌的颜色
    public var titleColor = UIColor.whiteColor()                    //标题文本的颜色
    public var datas: [CHChartItem] = [CHChartItem]()               //数据值
    public var decimal: Int = 2                                     //小数位的长度
    public var showMaxVal: Bool = false                             //是否显示最大值
    public var showMinVal: Bool = false                             //是否显示最小值
    public var title: String = ""                                   //标题
    public var key: String = ""                                     //key的名字
    
    weak var section: CHSection!
    
    convenience init(upColor: UIColor,
                     downColor: UIColor,
                     title: String = "",
                     titleColor: UIColor,
                     datas: [CHChartItem] = [CHChartItem](),
                     decimal: Int = 2
        ) {
        self.init()
        self.upColor = upColor
        self.downColor = downColor
        self.titleColor = titleColor
        self.title = title
        self.datas = datas
        self.decimal = decimal
    }
    
    /**
     画点线
     
     - parameter startIndex:     起始索引
     - parameter endIndex:       结束索引
     - parameter plotPaddingExt: 点与点之间间断所占点宽的比例
     */
    public func drawSerie(startIndex: Int, endIndex: Int, plotPaddingExt: CGFloat = 0.25) { }
}


/**
 *  线点样式模型
 */
public class CHLineModel: CHChartModel {
    
    /**
     画点线
     
     - parameter startIndex:     起始索引
     - parameter endIndex:       结束索引
     - parameter plotPaddingExt: 点与点之间间断所占点宽的比例
     */
    public override func drawSerie(startIndex: Int, endIndex: Int,
                                   plotPaddingExt: CGFloat = 0.25) {
        
        //每个点的间隔宽度
        let plotWidth = (self.section.frame.size.width - self.section.padding.left - self.section.padding.right) / CGFloat(endIndex - startIndex)
        
        let context = UIGraphicsGetCurrentContext()
        CGContextSetShouldAntialias(context, false)
        CGContextSetLineWidth(context, 0.5)
        
        //循环起始到终结 - 1
        for i in startIndex.stride(to: endIndex - 1, by: 1) {
            
            let value = self[i].value           //开始的点
            let valueNext = self[i + 1].value   //下一个点
            
            if value == nil || valueNext == nil {
                continue  //无法计算的值不绘画
            }
            
            //开始X
            let ix = self.section.frame.origin.x + self.section.padding.left + CGFloat(i - startIndex) * plotWidth
            //结束X
            let iNx = self.section.frame.origin.x + self.section.padding.left + CGFloat(i + 1 - startIndex) * plotWidth
            
            //把具体的数值转为坐标系的y值
            let iys = self.section.getLocalY(value!)
            let iye = self.section.getLocalY(valueNext!)
            
            CGContextSetStrokeColorWithColor(context, self.upColor.CGColor)
            CGContextMoveToPoint(context, ix + plotWidth / 2, iys)      //移动到当前点
            CGContextAddLineToPoint(context, iNx + plotWidth / 2, iye) //画一条直线到下一个点
            
            CGContextStrokePath(context)
            
            
        }
    }
    
}

/**
 *  蜡烛样式模型
 */
public class CHCandleModel: CHChartModel {
    
    /**
     画点线
     
     - parameter startIndex:     起始索引
     - parameter endIndex:       结束索引
     - parameter plotPaddingExt: 点与点之间间断所占点宽的比例
     */
    public override func drawSerie(startIndex: Int, endIndex: Int,
                                   plotPaddingExt: CGFloat = 0.25) {
        
        //每个点的间隔宽度
        let plotWidth = (self.section.frame.size.width - self.section.padding.left - self.section.padding.right) / CGFloat(endIndex - startIndex)
        let plotPadding = plotWidth * plotPaddingExt
        
        let context = UIGraphicsGetCurrentContext()
        CGContextSetShouldAntialias(context, false)
        CGContextSetLineWidth(context, 0.5)
        
        var maxItem: CHChartItem?       //最大值的项
        var maxPoint: CGPoint?          //最大值所在坐标
        var minItem: CHChartItem?       //最小值的项
        var minPoint: CGPoint?          //最小值所在坐标
        
        //循环起始到终结
        for i in startIndex.stride(to: endIndex, by: 1) {
            let item = datas[i]
            //开始X
            let ix = self.section.frame.origin.x + self.section.padding.left + CGFloat(i - startIndex) * plotWidth
            //结束X
            let iNx = self.section.frame.origin.x + self.section.padding.left + CGFloat(i + 1 - startIndex) * plotWidth
            
            //把具体的数值转为坐标系的y值
            let iyo = self.section.getLocalY(item.openPrice)
            let iyc = self.section.getLocalY(item.closePrice)
            let iyh = self.section.getLocalY(item.highPrice)
            let iyl = self.section.getLocalY(item.lowPrice)
            
            if iyh > iyc || iyh > iyo {
                NSLog("highPrice = \(item.highPrice), closePrice = \(item.closePrice), openPrice = \(item.openPrice)")
            }
            
            switch item.trend {
            case .Equal:
                //开盘收盘一样，则显示横线
                CGContextSetStrokeColorWithColor(context, self.upColor.CGColor)
            case .Up:
                //收盘价比开盘高，则显示涨的颜色
                CGContextSetStrokeColorWithColor(context, self.upColor.CGColor)
                CGContextSetFillColorWithColor(context, self.upColor.CGColor)
            case .Down:
                //收盘价比开盘低，则显示跌的颜色
                CGContextSetStrokeColorWithColor(context, self.downColor.CGColor)
                CGContextSetFillColorWithColor(context, self.downColor.CGColor)
            }
            
            //1.先画最高和最低价格的线
            CGContextMoveToPoint(context, ix + plotWidth / 2, iyh)
            CGContextAddLineToPoint(context,ix + plotWidth / 2,iyl)
            CGContextStrokePath(context)
            
            //2.画蜡烛柱的矩形，空心的刚好覆盖上面的线
            switch item.trend {
            case .Equal:
                //开盘收盘一样，则显示横线
                CGContextMoveToPoint(context, ix + plotPadding, iyo)
                CGContextAddLineToPoint(context, iNx - plotPadding, iyo)
                CGContextStrokePath(context)
            case .Up:
                //收盘价比开盘高，则从收盘的Y值向下画矩形
                CGContextFillRect(context, CGRectMake(ix + plotPadding, iyc, plotWidth - 2 * plotPadding, iyo - iyc))
            case .Down:
                //收盘价比开盘低，则从开盘的Y值向下画矩形
                CGContextFillRect(context, CGRectMake(ix + plotPadding, iyo, plotWidth - 2 *  plotPadding, iyc - iyo))
            }
            
            
            //记录最大值信息
            if item.highPrice == section.yAxis.max {
                maxItem = item
                maxPoint = CGPoint(x: ix + plotWidth / 2, y: iyh - section.padding.top / 2)
            }
            
            //记录最小值信息
            if item.lowPrice == section.yAxis.min {
                minItem = item
                minPoint = CGPoint(x: ix + plotWidth / 2, y: iyl + section.padding.bottom / 2)
            }
            
        }
        
        //显示最大最小值
        if self.showMaxVal && maxItem != nil {
            let highPrice = maxItem!.highPrice.ch_toString(maxF: section.decimal)
            self.drawGuideValue(context!, value: highPrice, section: section, point: maxPoint!)
        }
        
        //显示最大最小值
        if self.showMinVal && minItem != nil {
            let lowPrice = minItem!.lowPrice.ch_toString(maxF: section.decimal)
            self.drawGuideValue(context!, value: lowPrice, section: section, point: minPoint!)
        }
    }
    
    /**
     绘画最大值
     */
    func drawGuideValue(context: CGContext, value: String, section: CHSection, point: CGPoint) {
        
        let fontSize = value.ch_heightWithConstrainedWidth(section.labelFont)
        var arrowLineWidth: CGFloat = 4
        
        //判断绘画完整时是否超过界限
        var maxPriceStartX = point.x + arrowLineWidth * 5
        if maxPriceStartX + fontSize.width > section.frame.origin.x + section.frame.size.width - section.padding.right {
            //超过了最右边界，则反方向画
            arrowLineWidth = -4
            maxPriceStartX = point.x + arrowLineWidth * 5 - fontSize.width
        }
        
        CGContextSetShouldAntialias(context, true)
        CGContextSetStrokeColorWithColor(context, self.titleColor.CGColor)
        
        //画小箭头
        CGContextMoveToPoint(context, point.x, point.y)
        CGContextAddLineToPoint(context,point.x + arrowLineWidth,point.y - arrowLineWidth)
        CGContextStrokePath(context)
        
        CGContextMoveToPoint(context, point.x, point.y)
        CGContextAddLineToPoint(context,point.x + arrowLineWidth,point.y + arrowLineWidth)
        CGContextStrokePath(context)
        
        CGContextMoveToPoint(context, point.x, point.y)
        CGContextAddLineToPoint(context,point.x + arrowLineWidth * 4,point.y)
        CGContextStrokePath(context)
        
        
        let fontAttributes = [
            NSFontAttributeName: section.labelFont,
            NSForegroundColorAttributeName: self.titleColor
        ]
        
        //计算画文字的位置
        let point = CGPointMake(maxPriceStartX, point.y - fontSize.height / 2)
        
        //画最大值数字
        NSString(string: value)
            .drawAtPoint(point,
                         withAttributes: fontAttributes)
        
        CGContextSetShouldAntialias(context, false)
        
    }
    
    
}

/**
 *  交易量样式模型
 */
public class CHColumnModel: CHChartModel {
    
    /**
     画点线
     
     - parameter startIndex:     起始索引
     - parameter endIndex:       结束索引
     - parameter plotPaddingExt: 点与点之间间断所占点宽的比例
     */
    public override func drawSerie(startIndex: Int, endIndex: Int,
                                   plotPaddingExt: CGFloat = 0.25) {
        
        //每个点的间隔宽度
        let plotWidth = (self.section.frame.size.width - self.section.padding.left - self.section.padding.right) / CGFloat(endIndex - startIndex)
        let plotPadding = plotWidth * plotPaddingExt
        
        let iybase = self.section.getLocalY(section.yAxis.baseValue)
        
        let context = UIGraphicsGetCurrentContext()
        CGContextSetShouldAntialias(context, false)
        CGContextSetLineWidth(context, 0.5)
        
        //循环起始到终结
        for i in startIndex.stride(to: endIndex, by: 1) {
//            let value = self[i].value
//            
//            if value == nil{
//                continue  //无法计算的值不绘画
//            }
            
            let item = datas[i]
            //开始X
            let ix = self.section.frame.origin.x + self.section.padding.left + CGFloat(i - startIndex) * plotWidth
            
            //把具体的数值转为坐标系的y值
            let iyv = self.section.getLocalY(item.vol)
            
            //收盘价比开盘低，则显示跌的颜色
            switch item.trend {
            case .Up, .Equal:
                //收盘价比开盘高，则显示涨的颜色
                CGContextSetStrokeColorWithColor(context, self.upColor.CGColor)
                CGContextSetFillColorWithColor(context, self.upColor.CGColor)
            case .Down:
                CGContextSetStrokeColorWithColor(context, self.downColor.CGColor)
                CGContextSetFillColorWithColor(context, self.downColor.CGColor)
            }
            
            //画交易量的矩形
            CGContextFillRect (context, CGRectMake(ix + plotPadding, iyv, plotWidth - 2 * plotPadding, iybase - iyv))
            
            
        }
    }
    
}

// MARK: - 工厂方法
extension CHChartModel {
    
    //生成一个点线样式
    class func getLine(color: UIColor, title: String, key: String) -> CHLineModel {
        let model = CHLineModel(upColor: color, downColor: color,
                                titleColor: color)
        model.title = title
        model.key = key
        return model
    }
    
    //生成一个蜡烛样式
    class func getCandle(upColor upColor: UIColor, downColor: UIColor) -> CHCandleModel {
        let model = CHCandleModel(upColor: upColor, downColor: downColor,
                                  titleColor: UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1))
        model.key = "CANDLE"
        model.showMaxVal = true
        model.showMinVal = true
        return model
    }
    
    //生成一个交易量样式
    class func getVolume(upColor upColor: UIColor, downColor: UIColor) -> CHColumnModel {
        let model = CHColumnModel(upColor: upColor, downColor: downColor,
                                  titleColor: upColor)
        model.title = NSLocalizedString("Vol", comment: "")
        model.key = "VOL"
        return model
    }
}

// MARK: - 扩展技术指标公式
extension CHChartModel {
    
    public subscript (index: Int) -> CHChartItem {
            var value: CGFloat?
            let item = self.datas[index]
            value = item.extVal[self.key]
            item.value = value
            return item
        }
    
}