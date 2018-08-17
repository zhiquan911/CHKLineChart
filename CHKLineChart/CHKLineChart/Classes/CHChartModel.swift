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
    
    //升的颜色
    open var upStyle: (color: UIColor, isSolid: Bool) = (.green, true)
    //跌的颜色
    open var downStyle: (color: UIColor, isSolid: Bool) = (.red, true)
    open var titleColor = UIColor.white                    //标题文本的颜色
    open var datas: [CHChartItem] = [CHChartItem]()               //数据值
    open var decimal: Int = 2                                     //小数位的长度
    open var showMaxVal: Bool = false                             //是否显示最大值
    open var showMinVal: Bool = false                             //是否显示最小值
    open var title: String = ""                                   //标题
    open var useTitleColor = true
    open var key: String = ""                                     //key的名字
    open var ultimateValueStyle: CHUltimateValueStyle = .none       // 最大最小值显示样式
    open var lineWidth: CGFloat = 0.6                                     //线段宽度
    open var plotPaddingExt: CGFloat =  0.165                     //点与点之间间断所占点宽的比例
    
    weak var section: CHSection!
    
    
    convenience init(
        upStyle: (color: UIColor, isSolid: Bool),
        downStyle: (color: UIColor, isSolid: Bool),
        title: String = "",
        titleColor: UIColor,
        datas: [CHChartItem] = [CHChartItem](),
        decimal: Int = 2,
        plotPaddingExt: CGFloat =  0.165
        ) {
        
        self.init()
        self.upStyle = upStyle
        self.downStyle = downStyle
        self.titleColor = titleColor
        self.title = title
        self.datas = datas
        self.decimal = decimal
        self.plotPaddingExt = plotPaddingExt
    }
    
    /**
     画点线
     
     - parameter startIndex:     起始索引
     - parameter endIndex:       结束索引
     - parameter plotPaddingExt: 点与点之间间断所占点宽的比例
     */
    open func drawSerie(_ startIndex: Int, endIndex: Int) -> CAShapeLayer {
        return CAShapeLayer()
    }
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
    open override func drawSerie(_ startIndex: Int, endIndex: Int) -> CAShapeLayer {
        
        let serieLayer = CAShapeLayer()
        
        let modelLayer = CAShapeLayer()
        modelLayer.strokeColor = self.upStyle.color.cgColor
        modelLayer.fillColor = UIColor.clear.cgColor
        modelLayer.lineWidth = self.lineWidth
        modelLayer.lineCap = kCALineCapRound
        modelLayer.lineJoin = kCALineJoinBevel
        
        //每个点的间隔宽度
        let plotWidth = (self.section.frame.size.width - self.section.padding.left - self.section.padding.right) / CGFloat(endIndex - startIndex)
        
        //使用bezierPath画线段
        let linePath = UIBezierPath()
        
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
        
        modelLayer.path = linePath.cgPath
        
        serieLayer.addSublayer(modelLayer)
        
        //显示最大最小值
        if self.showMaxVal && maxValue != 0 {
            let highPrice = maxValue.ch_toString(maxF: section.decimal)
            let maxLayer = self.drawGuideValue(value: highPrice, section: section, point: maxPoint!, trend: CHChartItemTrend.up)
            
            serieLayer.addSublayer(maxLayer)
        }
        
        //显示最大最小值
        if self.showMinVal && minValue != CGFloat.greatestFiniteMagnitude {
            let lowPrice = minValue.ch_toString(maxF: section.decimal)
            let minLayer = self.drawGuideValue(value: lowPrice, section: section, point: minPoint!, trend: CHChartItemTrend.down)
            
            serieLayer.addSublayer(minLayer)
        }
        
        return serieLayer
    }
    
    
}

/**
 *  蜡烛样式模型
 */
open class CHCandleModel: CHChartModel {
    
    
    var drawShadow = true
    
    /**
     画点线
     
     - parameter startIndex:     起始索引
     - parameter endIndex:       结束索引
     - parameter plotPaddingExt: 点与点之间间断所占点宽的比例
     */
    open override func drawSerie(_ startIndex: Int, endIndex: Int) -> CAShapeLayer {
        
        let serieLayer = CAShapeLayer()
        
        let modelLayer = CAShapeLayer()
        
        //每个点的间隔宽度
        let plotWidth = (self.section.frame.size.width - self.section.padding.left - self.section.padding.right) / CGFloat(endIndex - startIndex)
        var plotPadding = plotWidth * self.plotPaddingExt
        plotPadding = plotPadding < 0.25 ? 0.25 : plotPadding
        
        var maxValue: CGFloat = 0       //最大值的项
        var maxPoint: CGPoint?          //最大值所在坐标
        var minValue: CGFloat = CGFloat.greatestFiniteMagnitude       //最小值的项
        var minPoint: CGPoint?          //最小值所在坐标
        
        //循环起始到终结
        for i in stride(from: startIndex, to: endIndex, by: 1) {
            
            if self.key != CHSeriesKey.candle {
                //不是蜡烛柱类型，要读取具体的数值才绘制
                if self[i].value == nil {       //读取的值
                    continue  //无法计算的值不绘画
                }
            }
            
            
            var isSolid = true
            let candleLayer = CAShapeLayer()
            var candlePath: UIBezierPath?
            let shadowLayer = CAShapeLayer()
            let shadowPath = UIBezierPath()
            shadowPath.lineWidth = 0
            
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
                shadowLayer.strokeColor = self.upStyle.color.cgColor
                isSolid = true
            case .up:
                //收盘价比开盘高，则显示涨的颜色
                shadowLayer.strokeColor = self.upStyle.color.cgColor
                candleLayer.strokeColor = self.upStyle.color.cgColor
                candleLayer.fillColor = self.upStyle.color.cgColor
                isSolid = self.upStyle.isSolid
            case .down:
                //收盘价比开盘低，则显示跌的颜色
                shadowLayer.strokeColor = self.downStyle.color.cgColor
                candleLayer.strokeColor = self.downStyle.color.cgColor
                candleLayer.fillColor = self.downStyle.color.cgColor
                isSolid = self.downStyle.isSolid
            }
            
            //1.先画最高和最低价格的线
            if self.drawShadow {
                shadowPath.move(to: CGPoint(x: ix + plotWidth / 2, y: iyh))
                shadowPath.addLine(to: CGPoint(x: ix + plotWidth / 2, y: iyl))
            }
            
            
            
            //2.画蜡烛柱的矩形，空心的刚好覆盖上面的线
            switch item.trend {
            case .equal:
                //开盘收盘一样，则显示横线
                shadowPath.move(to: CGPoint(x: ix + plotPadding, y: iyo))
                shadowPath.addLine(to: CGPoint(x: iNx - plotPadding, y: iyo))
            case .up:
                //收盘价比开盘高，则从收盘的Y值向下画矩形
                candlePath = UIBezierPath(rect: CGRect(x: ix + plotPadding, y: iyc, width: plotWidth - 2 * plotPadding, height: iyo - iyc))
                
            case .down:
                //收盘价比开盘低，则从开盘的Y值向下画矩形
                candlePath = UIBezierPath(rect: CGRect(x: ix + plotPadding, y: iyo, width: plotWidth - 2 *  plotPadding, height: iyc - iyo))
                
                
            }
            
            shadowLayer.path = shadowPath.cgPath
            modelLayer.addSublayer(shadowLayer)
            
            if candlePath != nil {
                
                //如果为自定义为空心，需要把矩形缩小lineWidth一圈。
                if isSolid {
                    candleLayer.lineWidth = self.lineWidth
                } else {
                    candleLayer.fillColor = UIColor.clear.cgColor
                    candleLayer.lineWidth = self.lineWidth
                }
                
                candleLayer.path = candlePath!.cgPath
                modelLayer.addSublayer(candleLayer)
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
        
        serieLayer.addSublayer(modelLayer)
        
        //显示最大最小值
        if self.showMaxVal && maxValue != 0 {
            let highPrice = maxValue.ch_toString(maxF: section.decimal)
            let maxLayer = self.drawGuideValue(value: highPrice, section: section, point: maxPoint!, trend: CHChartItemTrend.up)
            serieLayer.addSublayer(maxLayer)
        }
        
        //显示最大最小值
        if self.showMinVal && minValue != CGFloat.greatestFiniteMagnitude {
            let lowPrice = minValue.ch_toString(maxF: section.decimal)
            let minLayer = self.drawGuideValue(value: lowPrice, section: section, point: minPoint!, trend: CHChartItemTrend.down)
            serieLayer.addSublayer(minLayer)
        }
        
        return serieLayer
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
    open override func drawSerie(_ startIndex: Int, endIndex: Int) -> CAShapeLayer {
        
        let serieLayer = CAShapeLayer()
        
        let modelLayer = CAShapeLayer()
        
        //每个点的间隔宽度
        let plotWidth = (self.section.frame.size.width - self.section.padding.left - self.section.padding.right) / CGFloat(endIndex - startIndex)
        var plotPadding = plotWidth * self.plotPaddingExt
        plotPadding = plotPadding < 0.25 ? 0.25 : plotPadding
        
        let iybase = self.section.getLocalY(section.yAxis.baseValue)
        
        //循环起始到终结
        for i in stride(from: startIndex, to: endIndex, by: 1) {
            
            if self.key != CHSeriesKey.volume {
                //不是蜡烛柱类型，要读取具体的数值才绘制
                if self[i].value == nil {       //读取的值
                    continue  //无法计算的值不绘画
                }
            }
            
            var isSolid = true
            let columnLayer = CAShapeLayer()
            
            let item = datas[i]
            //开始X
            let ix = self.section.frame.origin.x + self.section.padding.left + CGFloat(i - startIndex) * plotWidth
            
            //把具体的数值转为坐标系的y值
            let iyv = self.section.getLocalY(item.vol)
            
            //收盘价比开盘低，则显示跌的颜色
            switch item.trend {
            case .up, .equal:
                //收盘价比开盘高，则显示涨的颜色
                columnLayer.strokeColor = self.upStyle.color.cgColor
                columnLayer.fillColor = self.upStyle.color.cgColor
                isSolid = self.upStyle.isSolid
            case .down:
                columnLayer.strokeColor = self.downStyle.color.cgColor
                columnLayer.fillColor = self.downStyle.color.cgColor
                isSolid = self.downStyle.isSolid
            }
            
            //画交易量的矩形
            let columnPath = UIBezierPath(rect: CGRect(x: ix + plotPadding, y: iyv, width: plotWidth - 2 * plotPadding, height: iybase - iyv))
            columnLayer.path = columnPath.cgPath
            
            if isSolid {
                columnLayer.lineWidth = self.lineWidth   //不设置为0会受到抗锯齿处理导致变大
            } else {
                columnLayer.fillColor = UIColor.clear.cgColor
                columnLayer.lineWidth = self.lineWidth
            }
            
            
            modelLayer.addSublayer(columnLayer)
        }
        
        serieLayer.addSublayer(modelLayer)
        
        return serieLayer
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
    open override func drawSerie(_ startIndex: Int, endIndex: Int) -> CAShapeLayer{
        
        let serieLayer = CAShapeLayer()
        
        let modelLayer = CAShapeLayer()
        
        //每个点的间隔宽度
        let plotWidth = (self.section.frame.size.width - self.section.padding.left - self.section.padding.right) / CGFloat(endIndex - startIndex)
        var plotPadding = plotWidth * self.plotPaddingExt
        plotPadding = plotPadding < 0.25 ? 0.25 : plotPadding
        
        let iybase = self.section.getLocalY(section.yAxis.baseValue)
        
        //        let context = UIGraphicsGetCurrentContext()
        //        context?.setShouldAntialias(false)
        //        context?.setLineWidth(1)
        
        //循环起始到终结
        for i in stride(from: startIndex, to: endIndex, by: 1) {
            //            let value = self[i].value
            //
            //            if value == nil{
            //                continue  //无法计算的值不绘画
            //            }
            var isSolid = true
            let value = self[i].value           //读取的值
            if value == nil {
                continue  //无法计算的值不绘画
            }
            
            let barLayer = CAShapeLayer()
            
            //开始X
            let ix = self.section.frame.origin.x + self.section.padding.left + CGFloat(i - startIndex) * plotWidth
            
            //把具体的数值转为坐标系的y值
            let iyv = self.section.getLocalY(value!)
            
            //如果值是正数
            if value! > 0 {
                //收盘价比开盘高，则显示涨的颜色
                barLayer.strokeColor = self.upStyle.color.cgColor
                barLayer.fillColor = self.upStyle.color.cgColor
            } else {
                barLayer.strokeColor = self.downStyle.color.cgColor
                barLayer.fillColor = self.downStyle.color.cgColor
            }
            
            if i < endIndex - 1, let newValue = self[i + 1].value {
                if newValue >= value! {
                    isSolid = self.upStyle.isSolid
                } else {
                    isSolid = self.downStyle.isSolid
                }
                
            }
            
            if isSolid {
                barLayer.lineWidth = self.lineWidth      //不设置为0会受到抗锯齿处理导致变大
            } else {
                barLayer.fillColor = section.backgroundColor.cgColor
                barLayer.lineWidth = self.lineWidth
            }
            
            //画交易量的矩形
            let barPath = UIBezierPath(rect: CGRect(x: ix + plotPadding, y: iyv, width: plotWidth - 2 * plotPadding, height: iybase - iyv))
            
            barLayer.path = barPath.cgPath
            
            
            modelLayer.addSublayer(barLayer)
        }
        
        serieLayer.addSublayer(modelLayer)
        
        return serieLayer
    }
    
}

/**
 *  圆点样式模型
 */
open class CHRoundModel: CHChartModel {
    
    
    /**
     画点线
     
     - parameter startIndex:     起始索引
     - parameter endIndex:       结束索引
     - parameter plotPaddingExt: 点与点之间间断所占点宽的比例
     */
    open override func drawSerie(_ startIndex: Int, endIndex: Int) -> CAShapeLayer {
        
        let serieLayer = CAShapeLayer()
        
        let modelLayer = CAShapeLayer()
        modelLayer.strokeColor = self.upStyle.color.cgColor
        modelLayer.fillColor = UIColor.clear.cgColor
        modelLayer.lineWidth = self.lineWidth
        modelLayer.lineCap = kCALineCapRound
        modelLayer.lineJoin = kCALineJoinBevel
        
        //每个点的间隔宽度
        let plotWidth = (self.section.frame.size.width - self.section.padding.left - self.section.padding.right) / CGFloat(endIndex - startIndex)
        var plotPadding = plotWidth * self.plotPaddingExt
        plotPadding = plotPadding < 0.25 ? 0.25 : plotPadding
        
        var maxValue: CGFloat = 0       //最大值的项
        var maxPoint: CGPoint?          //最大值所在坐标
        var minValue: CGFloat = CGFloat.greatestFiniteMagnitude       //最小值的项
        var minPoint: CGPoint?          //最小值所在坐标
        
        //循环起始到终结
        for i in stride(from: startIndex, to: endIndex, by: 1) {
            
            //开始的点
            guard let value = self[i].value else {
                continue //无法计算的值不绘画
            }
            
            let item = datas[i]
            
            //开始X
            let ix = self.section.frame.origin.x + self.section.padding.left + CGFloat(i - startIndex) * plotWidth
            
            //把具体的数值转为坐标系的y值
            let iys = self.section.getLocalY(value)
            
            let roundLayer = CAShapeLayer()
            
            let roundPoint = CGPoint(x: ix + plotPadding, y: iys)
            let roundSize = CGSize(width: plotWidth - 2 * plotPadding, height: plotWidth - 2 * plotPadding)
            let roundPath = UIBezierPath(ovalIn: CGRect(origin: roundPoint, size: roundSize))
            
            roundLayer.lineWidth = self.lineWidth
            roundLayer.path = roundPath.cgPath
            
            //收盘价大于指导价
            var fillColor: (color: UIColor, isSolid: Bool)
            if item.closePrice > value {
                fillColor = self.upStyle
            } else {
                fillColor = self.downStyle
            }
            
            roundLayer.strokeColor = fillColor.color.cgColor
            roundLayer.fillColor = fillColor.color.cgColor
            
            //设置为空心
            if !fillColor.isSolid {
                roundLayer.fillColor = section.backgroundColor.cgColor
            }
            
            modelLayer.addSublayer(roundLayer)
            
            //记录最大值信息
            if value > maxValue {
                maxValue = value
                maxPoint = roundPoint
            }
            
            //记录最小值信息
            if value < minValue {
                minValue = value
                minPoint = roundPoint
            }
        }
        
        serieLayer.addSublayer(modelLayer)
        
        //显示最大最小值
        if self.showMaxVal && maxValue != 0 {
            let highPrice = maxValue.ch_toString(maxF: section.decimal)
            let maxLayer = self.drawGuideValue(value: highPrice, section: section, point: maxPoint!, trend: CHChartItemTrend.up)
            
            serieLayer.addSublayer(maxLayer)
        }
        
        //显示最大最小值
        if self.showMinVal && minValue != CGFloat.greatestFiniteMagnitude {
            let lowPrice = minValue.ch_toString(maxF: section.decimal)
            let minLayer = self.drawGuideValue(value: lowPrice, section: section, point: minPoint!, trend: CHChartItemTrend.down)
            
            serieLayer.addSublayer(minLayer)
        }
        
        return serieLayer
    }
    
    
}

// MARK: - 扩展公共方法
public extension CHChartModel {
    
    /**
     绘画最大值
     */
    public func drawGuideValue(value: String, section: CHSection, point: CGPoint, trend: CHChartItemTrend) -> CAShapeLayer {
        
        let guideValueLayer = CAShapeLayer()
        
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
        
        
        //        context.setShouldAntialias(true)
        //        context.setStrokeColor(self.titleColor.cgColor)
        var fillColor: UIColor = self.upStyle.color
        switch trend {
        case .up:
            fillColor = self.upStyle.color
            isUp = -1
            tagStartY = point.y - (fontSize.height + arrowLineWidth)
            maxPriceStartY = point.y - (fontSize.height + arrowLineWidth / 2)
        case .down:
            fillColor = self.downStyle.color
            isUp = 1
            tagStartY = point.y
            maxPriceStartY = point.y + arrowLineWidth / 2
        default:break
        }
        
        /****** 根据样式类型绘制 ******/
        
        switch self.ultimateValueStyle {
        case let .arrow(color):
            
            let arrowPath = UIBezierPath()
            let arrowLayer = CAShapeLayer()
            
            guideValueTextColor = color
            //画小箭头
            arrowPath.move(to: CGPoint(x: point.x, y: point.y + arrowLineWidth * isUp))
            arrowPath.addLine(to: CGPoint(x: point.x + arrowLineWidth * isLeft, y: point.y + arrowLineWidth * isUp))
            
            arrowPath.move(to: CGPoint(x: point.x, y: point.y + arrowLineWidth * isUp))
            arrowPath.addLine(to: CGPoint(x: point.x, y: point.y + arrowLineWidth * isUp * 2))
            
            arrowPath.move(to: CGPoint(x: point.x, y: point.y + arrowLineWidth * isUp))
            arrowPath.addLine(to: CGPoint(x: point.x + arrowLineWidth * isLeft, y: point.y + arrowLineWidth * isUp * 2))
            
            arrowLayer.path = arrowPath.cgPath
            arrowLayer.strokeColor = self.titleColor.cgColor
            
            guideValueLayer.addSublayer(arrowLayer)
            
        case let .tag(color):
            
            let tagLayer = CAShapeLayer()
            let arrowLayer = CAShapeLayer()
            
            guideValueTextColor = color
            
            let arrowPath = UIBezierPath()
            arrowPath.move(to: CGPoint(x: point.x, y: point.y + arrowLineWidth * isUp))
            arrowPath.addLine(to: CGPoint(x: point.x + arrowLineWidth * isLeft * 2, y: point.y + arrowLineWidth * isUp))
            arrowPath.addLine(to: CGPoint(x: point.x + arrowLineWidth * isLeft * 2, y: point.y + arrowLineWidth * isUp * 3))
            arrowPath.close()
            arrowLayer.path = arrowPath.cgPath
            arrowLayer.fillColor = fillColor.cgColor
            guideValueLayer.addSublayer(arrowLayer)
            
            let tagPath = UIBezierPath(
                roundedRect: CGRect(x: maxPriceStartX - arrowLineWidth, y: tagStartY, width: fontSize.width + arrowLineWidth * 2, height: fontSize.height + arrowLineWidth), cornerRadius: arrowLineWidth * 2)
            //            tagPath.fill()
            
            tagLayer.path = tagPath.cgPath
            tagLayer.fillColor = fillColor.cgColor
            
            guideValueLayer.addSublayer(tagLayer)
            
        case let .circle(color, show):
            
            let circleLayer = CAShapeLayer()
            
            guideValueTextColor = color
            isShowValue = show
            
            let circleWidth: CGFloat = 6
            let circlePoint = CGPoint(x: point.x - circleWidth / 2, y: point.y - circleWidth / 2)
            let circleSize = CGSize(width: circleWidth, height: circleWidth)
            let circlePath = UIBezierPath(ovalIn: CGRect(origin: circlePoint, size: circleSize))
            
            
            //            fillColor.set()
            //            circlePath.stroke()
            //
            //            self.section.backgroundColor.set()
            //            circlePath.fill()
            
            circleLayer.lineWidth = self.lineWidth
            circleLayer.path = circlePath.cgPath
            circleLayer.fillColor = self.section.backgroundColor.cgColor
            circleLayer.strokeColor = fillColor.cgColor
            
            guideValueLayer.addSublayer(circleLayer)
            
        default:
            isShowValue = false
            break
        }
        
        if isShowValue {
            
            //            let fontAttributes = [
            //                NSFontAttributeName: section.labelFont,
            //                NSForegroundColorAttributeName: guideValueTextColor
            //                ] as [String : Any]
            
            //计算画文字的位置
            let point = CGPoint(x: maxPriceStartX, y: maxPriceStartY)
            let textSize = value.ch_sizeWithConstrained(section.labelFont)
            
            //画最大值数字
            let valueText = CHTextLayer()
            valueText.frame = CGRect(origin: point, size: textSize)
            valueText.string = value
            valueText.fontSize = section.labelFont.pointSize
            valueText.foregroundColor =  guideValueTextColor.cgColor
            valueText.backgroundColor = UIColor.clear.cgColor
            valueText.contentsScale = UIScreen.main.scale
            
            guideValueLayer.addSublayer(valueText)
            
            
            //            NSString(string: value)
            //                .draw(at: point,
            //                      withAttributes: fontAttributes)
            
        }
        
        
        return guideValueLayer
        //        context.setShouldAntialias(false)
        
    }
    
}

// MARK: - 工厂方法
extension CHChartModel {
    
    //生成一个点线样式
    public class func getLine(_ color: UIColor, title: String, key: String) -> CHLineModel {
        let model = CHLineModel(upStyle: (color, true), downStyle: (color, true),
                                titleColor: color)
        model.title = title
        model.key = key
        return model
    }
    
    //生成一个蜡烛样式
    public class func getCandle(upStyle: (color: UIColor, isSolid: Bool),
                         downStyle: (color: UIColor, isSolid: Bool),
                         titleColor: UIColor,
                         key: String = CHSeriesKey.candle) -> CHCandleModel {
        let model = CHCandleModel(upStyle: upStyle, downStyle: downStyle,
                                  titleColor: titleColor)
        model.key = key
        return model
    }
    
    //生成一个交易量样式
    public class func getVolume(upStyle: (color: UIColor, isSolid: Bool),
                         downStyle: (color: UIColor, isSolid: Bool),
                         key: String = CHSeriesKey.volume) -> CHColumnModel {
        let model = CHColumnModel(upStyle: upStyle, downStyle: downStyle,
                                  titleColor: UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1))
        model.title = NSLocalizedString("Vol", comment: "")
        model.key = key
        return model
    }
    
    //生成一个柱状样式
    public class func getBar(upStyle: (color: UIColor, isSolid: Bool),
                      downStyle: (color: UIColor, isSolid: Bool),
                      titleColor: UIColor, title: String, key: String) -> CHBarModel {
        let model = CHBarModel(upStyle: upStyle, downStyle: downStyle,
                               titleColor: titleColor)
        model.title = title
        model.key = key
        return model
    }
    
    //生成一个圆点样式
    public class func getRound(upStyle: (color: UIColor, isSolid: Bool),
                        downStyle: (color: UIColor, isSolid: Bool),
                        titleColor: UIColor, title: String,
                        plotPaddingExt: CGFloat,
                        key: String) -> CHRoundModel {
        let model = CHRoundModel(upStyle: upStyle, downStyle: downStyle,
                                 titleColor: titleColor, plotPaddingExt: plotPaddingExt)
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
