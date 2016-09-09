//
//  CHChartModel.swift
//  CHKLineChart
//
//  Created by 麦志泉 on 16/9/6.
//  Copyright © 2016年 bitbank. All rights reserved.
//

import UIKit

public enum CHChartModelType {
    case Line
    case Candle
    case Column
}

/**
 *  数据元素
 */
public struct CHChartItem {
    
    var time: Int = 0
    var openPrice: CGFloat = 0
    var closePrice: CGFloat = 0
    var lowPrice: CGFloat = 0
    var highPrice: CGFloat = 0
    var vol: CGFloat = 0
    
}

/**
 *  定义图表数据模型
 */
public class CHChartModel {
    
    /// MARK: - 成员变量
    public var upColor = UIColor.greenColor()                       //升的颜色
    public var downColor = UIColor.redColor()                       //跌的颜色
    public var datas: [CHChartItem] = [CHChartItem]()               //数据值
    public var decimal: Int = 2                                     //小数位的长度
    weak var section: CHSection!
    
    convenience init(upColor: UIColor,
                     downColor: UIColor,
                     datas: [CHChartItem] = [CHChartItem](),
                     decimal: Int = 2
        ) {
        self.init()
        self.upColor = upColor
        self.downColor = downColor
        self.datas = datas
        self.decimal = decimal
    }
    
    /**
     画点线
     
     - parameter startIndex:     起始索引
     - parameter endIndex:       结束索引
     - parameter plotPaddingExt: 点与点之间间断所占点宽的比例
     */
    public func drawSerie(startIndex: Int, endIndex: Int, plotPaddingExt: CGFloat = 0.25) {
        
    }
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
        let plotWidth = (self.section.frame.size.width - self.section.padding.left - self.section.padding.right) / CGFloat(startIndex - endIndex)
        
        let context = UIGraphicsGetCurrentContext();
        CGContextSetShouldAntialias(context, false);
        CGContextSetLineWidth(context, 0.5);
        
        //循环起始到终结 - 1
        for i in startIndex.stride(to: endIndex - 1, by: 1) {

            let item = datas[i]     //开始的点
            let itemNext = datas[i + 1]     //下一个点
            //开始X
            let ix = self.section.frame.origin.x + self.section.padding.left + CGFloat(i - startIndex) * plotWidth
            //结束X
            let iNx = self.section.frame.origin.x + self.section.padding.left + CGFloat(i + 1 - startIndex) * plotWidth
            
            //把具体的数值转为坐标系的y值
            let iys = self.section.getLocalY(item.closePrice)
            let iye = self.section.getLocalY(itemNext.closePrice)

            CGContextSetStrokeColorWithColor(context, self.upColor.CGColor);
            CGContextMoveToPoint(context, ix + plotWidth / 2, iys)      //移动到当前点
            CGContextAddLineToPoint(context, iNx + plotWidth / 2, iye); //画一条直线到下一个点
            
            CGContextStrokePath(context);
            
            
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
        let plotWidth = (self.section.frame.size.width - self.section.padding.left - self.section.padding.right) / CGFloat(startIndex - endIndex)
        let plotPadding = plotWidth * plotPaddingExt
        
        let context = UIGraphicsGetCurrentContext();
        CGContextSetShouldAntialias(context, false);
        CGContextSetLineWidth(context, 0.5);

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
            
            
            if item.closePrice == item.openPrice {
                //开盘收盘一样，则显示横线
                CGContextSetStrokeColorWithColor(context, self.upColor.CGColor)
            }else{
                //收盘价比开盘低，则显示跌的颜色
                if item.closePrice < item.openPrice {
                    CGContextSetStrokeColorWithColor(context, self.downColor.CGColor)
                    CGContextSetFillColorWithColor(context, self.downColor.CGColor)
                } else {
                    //收盘价比开盘高，则显示涨的颜色
                    CGContextSetStrokeColorWithColor(context, self.upColor.CGColor)
                    CGContextSetFillColorWithColor(context, self.upColor.CGColor)
                }
            }
            
            //1.先画最高和最低价格的线
            CGContextMoveToPoint(context, plotWidth / 2, iyh);
            CGContextAddLineToPoint(context,ix + plotWidth / 2,iyl);
            CGContextStrokePath(context);
            
            //2.画蜡烛柱的矩形，空心的刚好覆盖上面的线
            if item.closePrice == item.openPrice {
                //开盘收盘一样，则显示横线
                CGContextMoveToPoint(context, ix + plotPadding, iyo)
                CGContextAddLineToPoint(context, iNx - plotPadding, iyo);
                CGContextStrokePath(context);
                
            }else{
                //收盘价比开盘低，则从开盘的Y值向下画矩形
                if item.closePrice < item.openPrice {
                    CGContextFillRect(context, CGRectMake(ix + plotPadding, iyo, plotWidth - 2 *  plotPadding, iyo - iyc))
                } else {
                    //收盘价比开盘高，则从收盘的Y值向下画矩形
                    CGContextFillRect(context, CGRectMake(ix + plotPadding, iyc, plotWidth - 2 * plotPadding, iyo - iyc));
                }
            }
            
            
        }
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
        let plotWidth = (self.section.frame.size.width - self.section.padding.left - self.section.padding.right) / CGFloat(startIndex - endIndex)
        let plotPadding = plotWidth * plotPaddingExt
        
        let iybase = self.section.getLocalY(section.yAxis.baseValue)
        
        let context = UIGraphicsGetCurrentContext();
        CGContextSetShouldAntialias(context, false);
        CGContextSetLineWidth(context, 0.5);
        
        //循环起始到终结
        for i in startIndex.stride(to: endIndex, by: 1) {
            let item = datas[i]
            //开始X
            let ix = self.section.frame.origin.x + self.section.padding.left + CGFloat(i - startIndex) * plotWidth
            
            //把具体的数值转为坐标系的y值
            let iyv = self.section.getLocalY(item.vol)
            
            //收盘价比开盘低，则显示跌的颜色
            if item.closePrice < item.openPrice {
                CGContextSetStrokeColorWithColor(context, self.downColor.CGColor)
                CGContextSetFillColorWithColor(context, self.downColor.CGColor)
            } else {
                //收盘价比开盘高，则显示涨的颜色
                CGContextSetStrokeColorWithColor(context, self.upColor.CGColor)
                CGContextSetFillColorWithColor(context, self.upColor.CGColor)
            }
            
            //画交易量的矩形
            CGContextFillRect (context, CGRectMake(ix + plotPadding, iyv, plotWidth - 2 * plotPadding, iybase - iyv))
            
            
        }
    }
    
}