//
//  CHChartModel.swift
//  CHKLineChart
//
//  Created by Chance on 16/9/6.
//  Copyright © 2016年 Chance. All rights reserved.
//

import UIKit



/**
 改数据的走势方向
 
 - Up:    升
 - Down:  跌
 - Equal: 相等
 */
public enum CHChartItemTrend {
    case up
    case down
    case equal
}

/**
 *  数据元素
 */
open class CHChartItem: NSObject {
    
    open var time: Int = 0
    open var openPrice: CGFloat = 0
    open var closePrice: CGFloat = 0
    open var lowPrice: CGFloat = 0
    open var highPrice: CGFloat = 0
    open var vol: CGFloat = 0
    open var value: CGFloat?
    open var extVal: [String: CGFloat] = [String: CGFloat]()        //扩展值，用来记录各种技术指标
    
    open var trend: CHChartItemTrend {
        if closePrice == openPrice {
            return .equal
            
        }else{
            //收盘价比开盘低
            if closePrice < openPrice {
                return .down
            } else {
                //收盘价比开盘高
                return .up
            }
        }
    }
    
}

/**
 *  定义图表数据模型
 */
open class CHChartModel {
    
    /// MARK: - 成员变量
    open var upColor = UIColor.green                       //升的颜色
    open var downColor = UIColor.red                       //跌的颜色
    open var titleColor = UIColor.white                    //标题文本的颜色
    open var datas: [CHChartItem] = [CHChartItem]()               //数据值
    open var decimal: Int = 2                                     //小数位的长度
    open var showMaxVal: Bool = false                             //是否显示最大值
    open var showMinVal: Bool = false                             //是否显示最小值
    open var title: String = ""                                   //标题
    open var useTitleColor = true
    open var key: String = ""                                     //key的名字
    open var ultimateValueStyle: CHUltimateValueStyle = .none       // 最大最小值显示样式
    open var lineWidth: CGFloat = 1                                     //线段宽度
    
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
    open func drawSerie(_ startIndex: Int, endIndex: Int, plotPaddingExt: CGFloat = 0.15) { }
}


/**
 *  线点样式模型
 */
open class CHLineModel: CHChartModel {
    
 
    /**
     画点线
     
     - parameter startIndex:     起始索引
     - parameter endIndex:       结束索引
     - parameter plotPaddingExt: 点与点之间间断所占点宽的比例
     */
    open override func drawSerie(_ startIndex: Int, endIndex: Int,
                                   plotPaddingExt: CGFloat = 0.25) {
        
        //每个点的间隔宽度
        let plotWidth = (self.section.frame.size.width - self.section.padding.left - self.section.padding.right) / CGFloat(endIndex - startIndex)
        
        let context = UIGraphicsGetCurrentContext()
        context?.setShouldAntialias(true)
        
        //使用bezierPath画线段
        let linePath = UIBezierPath()
        linePath.lineWidth = self.lineWidth
        linePath.lineCapStyle = .round
        linePath.lineJoinStyle = .bevel
        
        var maxValue: CGFloat = 0       //最大值的项
        var maxPoint: CGPoint?          //最大值所在坐标
        var minValue: CGFloat = CGFloat.greatestFiniteMagnitude       //最小值的项
        var minPoint: CGPoint?          //最小值所在坐标
        
        var isStartDraw = false
        
        //循环起始到终结
        for i in stride(from: startIndex, to: endIndex, by: 1) {
            
            //开始的点
            guard let value = self[i].value else {
                continue //无法计算的值不绘画
            }
            
            //开始X
            let ix = self.section.frame.origin.x + self.section.padding.left + CGFloat(i - startIndex) * plotWidth
            //结束X
//            let iNx = self.section.frame.origin.x + self.section.padding.left + CGFloat(i + 1 - startIndex) * plotWidth
            
            //把具体的数值转为坐标系的y值
            let iys = self.section.getLocalY(value)
//            let iye = self.section.getLocalY(valueNext!)
            let point = CGPoint(x: ix + plotWidth / 2, y: iys)
            //第一个点移动路径起始
            if !isStartDraw {
                linePath.move(to: point)
                isStartDraw = true
            } else {
                linePath.addLine(to: point)
            }
            
            
            

            
            //记录最大值信息
            if value > maxValue {
                maxValue = value
                maxPoint = point
            }
            
            //记录最小值信息
            if value < minValue {
                minValue = value
                minPoint = point
            }
        }
        
        self.upColor.set()
        linePath.stroke()
        
        
        //显示最大最小值
        if self.showMaxVal && maxValue != 0 {
            let highPrice = maxValue.ch_toString(maxF: section.decimal)
            self.drawGuideValue(context!, value: highPrice, section: section, point: maxPoint!, trend: CHChartItemTrend.up)
        }
        
        //显示最大最小值
        if self.showMinVal && minValue != CGFloat.greatestFiniteMagnitude {
            let lowPrice = minValue.ch_toString(maxF: section.decimal)
            self.drawGuideValue(context!, value: lowPrice, section: section, point: minPoint!, trend: CHChartItemTrend.down)
        }
        
    }
    
    
}

/**
 *  蜡烛样式模型
 */
open class CHCandleModel: CHChartModel {
    
    /**
     画点线
     
     - parameter startIndex:     起始索引
     - parameter endIndex:       结束索引
     - parameter plotPaddingExt: 点与点之间间断所占点宽的比例
     */
    open override func drawSerie(_ startIndex: Int, endIndex: Int,
                                   plotPaddingExt: CGFloat = 0.15) {
        
        //每个点的间隔宽度
        let plotWidth = (self.section.frame.size.width - self.section.padding.left - self.section.padding.right) / CGFloat(endIndex - startIndex)
        let plotPadding = plotWidth * plotPaddingExt
        
        let context = UIGraphicsGetCurrentContext()
        context?.setShouldAntialias(false)
        context?.setLineWidth(0.5)
        
        var maxValue: CGFloat = 0       //最大值的项
        var maxPoint: CGPoint?          //最大值所在坐标
        var minValue: CGFloat = CGFloat.greatestFiniteMagnitude       //最小值的项
        var minPoint: CGPoint?          //最小值所在坐标
        
        //循环起始到终结
        for i in stride(from: startIndex, to: endIndex, by: 1) {
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
            case .equal:
                //开盘收盘一样，则显示横线
                context?.setStrokeColor(self.upColor.cgColor)
            case .up:
                //收盘价比开盘高，则显示涨的颜色
                context?.setStrokeColor(self.upColor.cgColor)
                context?.setFillColor(self.upColor.cgColor)
            case .down:
                //收盘价比开盘低，则显示跌的颜色
                context?.setStrokeColor(self.downColor.cgColor)
                context?.setFillColor(self.downColor.cgColor)
            }
            
            //1.先画最高和最低价格的线
            context?.move(to: CGPoint(x: ix + plotWidth / 2, y: iyh))
            context?.addLine(to: CGPoint(x: ix + plotWidth / 2, y: iyl))
            context?.strokePath()
            
            //2.画蜡烛柱的矩形，空心的刚好覆盖上面的线
            switch item.trend {
            case .equal:
                //开盘收盘一样，则显示横线
                context?.move(to: CGPoint(x: ix + plotPadding, y: iyo))
                context?.addLine(to: CGPoint(x: iNx - plotPadding, y: iyo))
                context?.strokePath()
            case .up:
                //收盘价比开盘高，则从收盘的Y值向下画矩形
                context?.fill(CGRect(x: ix + plotPadding, y: iyc, width: plotWidth - 2 * plotPadding, height: iyo - iyc))
            case .down:
                //收盘价比开盘低，则从开盘的Y值向下画矩形
                context?.fill(CGRect(x: ix + plotPadding, y: iyo, width: plotWidth - 2 *  plotPadding, height: iyc - iyo))
            }
            
            
            //记录最大值信息
            if item.highPrice > maxValue {
                maxValue = item.highPrice
                maxPoint = CGPoint(x: ix + plotWidth / 2, y: iyh)
            }
            
            //记录最小值信息
            if item.lowPrice < minValue {
                minValue = item.lowPrice
                minPoint = CGPoint(x: ix + plotWidth / 2, y: iyl)
            }
            
        }
        
        //显示最大最小值
        if self.showMaxVal && maxValue != 0 {
            let highPrice = maxValue.ch_toString(maxF: section.decimal)
            self.drawGuideValue(context!, value: highPrice, section: section, point: maxPoint!, trend: CHChartItemTrend.up)
        }
        
        //显示最大最小值
        if self.showMinVal && minValue != CGFloat.greatestFiniteMagnitude {
            let lowPrice = minValue.ch_toString(maxF: section.decimal)
            self.drawGuideValue(context!, value: lowPrice, section: section, point: minPoint!, trend: CHChartItemTrend.down)
        }
    }
    
}

/**
 *  交易量样式模型
 */
open class CHColumnModel: CHChartModel {
    
    /**
     画点线
     
     - parameter startIndex:     起始索引
     - parameter endIndex:       结束索引
     - parameter plotPaddingExt: 点与点之间间断所占点宽的比例
     */
    open override func drawSerie(_ startIndex: Int, endIndex: Int,
                                   plotPaddingExt: CGFloat = 0.15) {
        
        //每个点的间隔宽度
        let plotWidth = (self.section.frame.size.width - self.section.padding.left - self.section.padding.right) / CGFloat(endIndex - startIndex)
        let plotPadding = plotWidth * plotPaddingExt
        
        let iybase = self.section.getLocalY(section.yAxis.baseValue)
        
        let context = UIGraphicsGetCurrentContext()
        context?.setShouldAntialias(false)
        context?.setLineWidth(0.5)
        
        //循环起始到终结
        for i in stride(from: startIndex, to: endIndex, by: 1) {
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
            case .up, .equal:
                //收盘价比开盘高，则显示涨的颜色
                context?.setStrokeColor(self.upColor.cgColor)
                context?.setFillColor(self.upColor.cgColor)
            case .down:
                context?.setStrokeColor(self.downColor.cgColor)
                context?.setFillColor(self.downColor.cgColor)
            }
            
            //画交易量的矩形
            context?.fill (CGRect(x: ix + plotPadding, y: iyv, width: plotWidth - 2 * plotPadding, height: iybase - iyv))
            
            
        }
    }
    
}

/**
 *  交易量样式模型
 */
open class CHBarModel: CHChartModel {
    
    /**
     画点线
     
     - parameter startIndex:     起始索引
     - parameter endIndex:       结束索引
     - parameter plotPaddingExt: 点与点之间间断所占点宽的比例
     */
    open override func drawSerie(_ startIndex: Int, endIndex: Int,
                                 plotPaddingExt: CGFloat = 0.15) {
        
        //每个点的间隔宽度
        let plotWidth = (self.section.frame.size.width - self.section.padding.left - self.section.padding.right) / CGFloat(endIndex - startIndex)
        let plotPadding = plotWidth * plotPaddingExt
        
        let iybase = self.section.getLocalY(section.yAxis.baseValue)
        
        let context = UIGraphicsGetCurrentContext()
        context?.setShouldAntialias(false)
        context?.setLineWidth(0.5)
        
        //循环起始到终结
        for i in stride(from: startIndex, to: endIndex, by: 1) {
            //            let value = self[i].value
            //
            //            if value == nil{
            //                continue  //无法计算的值不绘画
            //            }
            
            let value = self[i].value           //读取的值
            
            if value == nil {
                continue  //无法计算的值不绘画
            }
            //开始X
            let ix = self.section.frame.origin.x + self.section.padding.left + CGFloat(i - startIndex) * plotWidth
            
            //把具体的数值转为坐标系的y值
            let iyv = self.section.getLocalY(value!)
            
            //如果值是正数
            if value! > 0 {
                //收盘价比开盘高，则显示涨的颜色
                context?.setStrokeColor(self.upColor.cgColor)
                context?.setFillColor(self.upColor.cgColor)
            } else {
                context?.setStrokeColor(self.downColor.cgColor)
                context?.setFillColor(self.downColor.cgColor)
            }
            
            //画交易量的矩形
            context?.fill (CGRect(x: ix + plotPadding, y: iyv, width: plotWidth - 2 * plotPadding, height: iybase - iyv))
            
            
        }
    }
    
}


// MARK: - 扩展公共方法
public extension CHChartModel {
    
    /**
     绘画最大值
     */
    public func drawGuideValue(_ context: CGContext, value: String, section: CHSection, point: CGPoint, trend: CHChartItemTrend) {
        
        let fontSize = value.ch_sizeWithConstrained(section.labelFont)
        let arrowLineWidth: CGFloat = 4
        var isUp: CGFloat = -1
        var isLeft: CGFloat = -1
        var tagStartY: CGFloat = 0
        var isShowValue: Bool = true        //是否显示值，圆形样式可以不显示值，只显示圆形
        var guideValueTextColor: UIColor = UIColor.white              //显示最大最小的文字颜色
        //判断绘画完整时是否超过界限
        var maxPriceStartX = point.x + arrowLineWidth * 2
        var maxPriceStartY: CGFloat = 0
        if maxPriceStartX + fontSize.width > section.frame.origin.x + section.frame.size.width - section.padding.right {
            //超过了最右边界，则反方向画
            isLeft = -1
            maxPriceStartX = point.x + arrowLineWidth * isLeft * 2 - fontSize.width
        } else {
            isLeft = 1
        }
        
        
        context.setShouldAntialias(true)
        context.setStrokeColor(self.titleColor.cgColor)
        var fillColor: UIColor = self.upColor
        switch trend {
        case .up:
            fillColor = self.upColor
            isUp = -1
            tagStartY = point.y - (fontSize.height + arrowLineWidth)
            maxPriceStartY = point.y - (fontSize.height + arrowLineWidth / 2)
        case .down:
            fillColor = self.downColor
            isUp = 1
            tagStartY = point.y
            maxPriceStartY = point.y + arrowLineWidth / 2
        default:break
        }
        
        /****** 根据样式类型绘制 ******/
        
        switch self.ultimateValueStyle {
        case let .arrow(color):
            guideValueTextColor = color
            //画小箭头
            context.move(to: CGPoint(x: point.x, y: point.y + arrowLineWidth * isUp))
            context.addLine(to: CGPoint(x: point.x + arrowLineWidth * isLeft, y: point.y + arrowLineWidth * isUp))
            context.strokePath()
            
            context.move(to: CGPoint(x: point.x, y: point.y + arrowLineWidth * isUp))
            context.addLine(to: CGPoint(x: point.x, y: point.y + arrowLineWidth * isUp * 2))
            context.strokePath()
            
            context.move(to: CGPoint(x: point.x, y: point.y + arrowLineWidth * isUp))
            context.addLine(to: CGPoint(x: point.x + arrowLineWidth * isLeft, y: point.y + arrowLineWidth * isUp * 2))
            context.strokePath()
            
        case let .tag(color):
            
            guideValueTextColor = color
            
            fillColor.set()
            
            let arrowPath = UIBezierPath()
            arrowPath.move(to: CGPoint(x: point.x, y: point.y + arrowLineWidth * isUp))
            arrowPath.addLine(to: CGPoint(x: point.x + arrowLineWidth * isLeft * 2, y: point.y + arrowLineWidth * isUp))
            arrowPath.addLine(to: CGPoint(x: point.x + arrowLineWidth * isLeft * 2, y: point.y + arrowLineWidth * isUp * 3))
            arrowPath.close()
            arrowPath.fill()
            
            let tagPath = UIBezierPath(
                roundedRect: CGRect(x: maxPriceStartX - arrowLineWidth, y: tagStartY, width: fontSize.width + arrowLineWidth * 2, height: fontSize.height + arrowLineWidth), cornerRadius: arrowLineWidth * 2)
            tagPath.fill()
            
        case let .circle(color, show):
            guideValueTextColor = color
            isShowValue = show
            
            let circleWidth: CGFloat = 6
            let circlePoint = CGPoint(x: point.x - circleWidth / 2, y: point.y - circleWidth / 2)
            let circleSize = CGSize(width: circleWidth, height: circleWidth)
            let circlePath = UIBezierPath(ovalIn: CGRect(origin: circlePoint, size: circleSize))
            circlePath.lineWidth = self.lineWidth * 2
            
            fillColor.set()
            circlePath.stroke()
            
            self.section.backgroundColor.set()
            circlePath.fill()
            
        default:
            break
        }
        
        if isShowValue {
            
            let fontAttributes = [
                NSFontAttributeName: section.labelFont,
                NSForegroundColorAttributeName: guideValueTextColor
                ] as [String : Any]
            
            //计算画文字的位置
            let point = CGPoint(x: maxPriceStartX, y: maxPriceStartY)
            
            //画最大值数字
            NSString(string: value)
                .draw(at: point,
                      withAttributes: fontAttributes)
            
        }
        
        
        
        context.setShouldAntialias(false)
        
    }
    
}

// MARK: - 工厂方法
extension CHChartModel {
    
    //生成一个点线样式
    class func getLine(_ color: UIColor, title: String, key: String) -> CHLineModel {
        let model = CHLineModel(upColor: color, downColor: color,
                                titleColor: color)
        model.title = title
        model.key = key
        return model
    }
    
    //生成一个蜡烛样式
    class func getCandle(upColor: UIColor, downColor: UIColor, titleColor: UIColor) -> CHCandleModel {
        let model = CHCandleModel(upColor: upColor, downColor: downColor,
                                  titleColor: titleColor)
        model.key = "Candle"
        return model
    }
    
    //生成一个交易量样式
    class func getVolume(upColor: UIColor, downColor: UIColor) -> CHColumnModel {
        let model = CHColumnModel(upColor: upColor, downColor: downColor,
                                  titleColor: UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1))
        model.title = NSLocalizedString("Vol", comment: "")
        model.key = "Vol"
        return model
    }
    
    //生成一个柱状样式
    class func getBar(upColor: UIColor, downColor: UIColor, titleColor: UIColor, title: String, key: String) -> CHBarModel {
        let model = CHBarModel(upColor: upColor, downColor: downColor,
                                  titleColor: titleColor)
        model.title = title
        model.key = key
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
