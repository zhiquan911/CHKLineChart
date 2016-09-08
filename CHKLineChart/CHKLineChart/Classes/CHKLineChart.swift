//
//  CHKLineChart.swift
//  CHKLineChart
//
//  Created by 麦志泉 on 16/9/6.
//  Copyright © 2016年 bitbank. All rights reserved.
//

import UIKit

/**
 Y轴显示的位置
 
 - Left:  左边
 - Right: 右边
 - None:  不显示
 */
enum CHYAxisShowPosition {
    case Left, Right, None
}

public enum CHKLineChartStyle {
    case Default
    
    func getSections() -> [CHSection] {
        let priceSection = CHSection()
        let volumeSection = CHSection()
        let trendSection = CHSection()
        return [priceSection, volumeSection, trendSection]
    }
    
    func getRatios() -> [Int] {
        return [3, 1, 1]
    }
}



/**
 *  K线数据源代理
 */
public protocol CHKLineChartDelegate {
    
    /**
     数据源总数
     
     - parameter chart:
     
     - returns:
     */
    func numberOfPointsInKLineChart(chart: CHKLineChart) -> Int
    
    /**
     数据源索引为对应的对象
     
     - parameter chart:
     - parameter index: 索引位
     
     - returns: K线数据对象
     */
    func kLineChart(chart: CHKLineChart, valueForPointAtIndex index: Int) -> CHChartItem
    
    /**
     获取图表X轴的显示的内容
     
     - parameter chart:
     - parameter index:     索引位
     
     - returns:
     */
    func kLineChart(chart: CHKLineChart, labelOnXAxisForIndex index: Int) -> String
}

public class CHKLineChart: UIView {
    
    /// MARK: - 常量
    var kMinRange = 9
    var kMaxRange = 121
    
    /// MARK: - 成员变量
    var upColor: UIColor = UIColor.greenColor()     //升的颜色
    var downColor: UIColor = UIColor.redColor()     //跌的颜色
    var style = CHKLineChartStyle.Default           //显示样式
    var xAxisPerInterval = 4                        //x轴的间断个数
    var sections = [CHSection]()
    var labelFont = UIFont.systemFontOfSize(10)
    var selectedIndex: Int = 0                      //选择索引位
    var padding: UIEdgeInsets = UIEdgeInsetsZero    //内边距
    var enableSelection = true                      //是否可点选
    var showYLabel = CHYAxisShowPosition.Right      //显示y的位置，默认右边
    var yLabelWidth:CGFloat = 35                    //Y轴的宽度
    var borderWidth: CGFloat = 0.5
    var plotWidth: CGFloat = 1
    var plotPadding: CGFloat = 0.5
    var plotCount: Int = 0
    var rangeFrom: Int = 0                          //可见区域的开始索引位
    var rangeTo: Int = 0                            //可见区域的结束索引位
    var range: Int = 49                             //显示在可见区域的个数
    var borderColor: UIColor = UIColor.grayColor()
    var xlabelSize = CGSizeMake(40, 14)
    var isInitialized = false                       //是否已经初始化数据
    var delegate: CHKLineChartDelegate?             //代理
    var datas: [CHChartItem] = [CHChartItem]()      //数据源
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.initData()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initData()
    }
    
    func initData() {
        
        self.multipleTouchEnabled = true
        
        //添加手势操作
        //        [self addGestureRecognizer:[[UIPanGestureRecognizer alloc]
        //            initWithTarget:self
        //            action:@selector(doPanAciton:)]];
        //点击手势操作
        //        [self addGestureRecognizer:[[UITapGestureRecognizer alloc]
        //            initWithTarget:self
        //            action:@selector(doTapAction:)]];
        
        //双指缩放操作
        //        [self addGestureRecognizer:[[UIPinchGestureRecognizer alloc]
        //            initWithTarget:self
        //            action:@selector(doPinchAction:)]];
    }
    
    
    /**
     绘制图表
     
     - parameter rect:
     */
    override public func drawRect(rect: CGRect) {
        
        //初始化分区的样式
        self.initChart()
        //建立每个分区
        self.buildSections()
        //        [self initSections];
        //        [self initXAxis];
        //        [self initYAxis];
        //        [self drawXAxis];
        //        [self drawYAxis];
        //        [self drawChart];
        
    }
    
    /**
     初始化图表结构
     
     - returns:
     */
    private func initChart() {
        
        self.plotCount = self.delegate?.numberOfPointsInKLineChart(self) ?? 0
        if self.rangeTo == 0 {      //如果图表尽头的索引为0，则进行初始化
            self.rangeTo = self.plotCount               //默认是数据最后一条为尽头
            if self.rangeTo - self.range > 0 {          //如果尽头 - 默认显示数大于0
                self.rangeFrom = self.rangeTo - range   //计算开始的显示的位置
            } else {
                self.rangeFrom = 0
            }
            
        }
        
        //获取代理上的数据源
        for i in 0...self.plotCount - 1 {
            let item = self.delegate?.kLineChart(self, valueForPointAtIndex: i)
            self.datas.append(item!)
        }
        
        let context = UIGraphicsGetCurrentContext()
        CGContextSetRGBFillColor(context, 0, 0, 0, 1.0);
        CGContextFillRect (context, CGRectMake (0, 0, self.bounds.size.width,self.bounds.size.height));
        
    }
    
    /**
     初始化各个分区
     
     - returns:
     */
    private func buildSections() {
        //计算实际的显示高度和宽度
        let height = self.frame.size.height - (self.padding.top + self.padding.bottom)
        let width  = self.frame.size.width - (self.padding.left + self.padding.right)
        
        var total = 0
        for section in self.sections {
            if !section.hidden {
                total = total + section.ratios
            }
            
        }
        
        var offsetY: CGFloat = self.padding.top
        //计算每个区域的高度，并绘制
        for var section in self.sections {
            var heightOfSection: CGFloat = 0
            let WidthOfSection = width
            if section.hidden {
                continue
            }
            //计算每个区域的高度
            heightOfSection = height * CGFloat(section.ratios) / CGFloat(total)
            
            //y轴的标签显示方位
            switch self.showYLabel {
            case .Left:         //左边显示
                section.padding.left = self.yLabelWidth
                section.padding.right = 0
            case .Right:        //右边显示
                section.padding.left = 0
                section.padding.right = self.yLabelWidth
            case .None:         //都不显示
                section.padding.left = 0
                section.padding.right = 0
            }
            
            //计算每个section的坐标
            section.frame = CGRectMake(0 + self.padding.left,
                                       offsetY, WidthOfSection, heightOfSection)
            offsetY = offsetY + section.frame.height
            
            //绘制每个区域
            self.drawSection(section)
            //绘制X轴坐标
            self.drawXAxis(section.padding, width: section.frame.size.width)
            
            //初始Y轴的数据
            self.initYAxis(section)
            //绘制Y轴坐标
            self.drawYAxis(section)
        }
        
        
        
    }
    
    
    /**
     绘制X轴上的标签
     
     - parameter padding: 内边距
     - parameter width:   总宽度
     */
    private func drawXAxis(padding: UIEdgeInsets, width: CGFloat) {
        
        var startX: CGFloat = 0
        let endX: CGFloat = 0
        let secWidth: CGFloat = width
        let secPaddingLeft: CGFloat = padding.left
        let secPaddingRight: CGFloat = padding.right
        
        let context = UIGraphicsGetCurrentContext();
        CGContextSetShouldAntialias(context, false);
        CGContextSetLineWidth(context, 0.5);
        CGContextSetStrokeColorWithColor(context, UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1).CGColor)
        
        //x轴分平均分4个间断，显示5个x轴坐标，按照图表的值个数，计算每个间断的个数
        let dataRange = self.rangeTo - self.rangeFrom;
        let xTickInterval: Int = (dataRange - 1) / self.xAxisPerInterval;
        
        //绘制x轴标签
        //每个点的间隔宽度
        let perPlotWidth: CGFloat = (secWidth - secPaddingLeft - secPaddingRight) / CGFloat(self.rangeTo - self.rangeFrom);
        let startY = self.frame.size.height - self.padding.bottom;
        var k: Int = 0
        
        //X轴标签的字体样式
        let textStyle = NSMutableParagraphStyle()
        textStyle.alignment = NSTextAlignment.Center
        textStyle.lineBreakMode = NSLineBreakMode.ByClipping
        
        let fontAttributes = [
            NSFontAttributeName: self.labelFont,
            NSParagraphStyleAttributeName: textStyle
        ]
        
        //相当 for var i = self.rangeFrom; i < self.rangeTo; i = i + xTickInterval
        for i in self.rangeFrom.stride(to: self.rangeTo, by: xTickInterval) {
            CGContextSetRGBFillColor(context, 0.8, 0.8, 0.8, 1.0);
            CGContextSetShouldAntialias(context, true);  //抗锯齿开启，解决字体发虚
            let xLabel = self.delegate?.kLineChart(self, labelOnXAxisForIndex: i) ?? ""
            var textSize = xLabel.ch_heightWithConstrainedWidth(300, font: labelFont)
            textSize.width = textSize.width + 4;
            var xPox = startX - textSize.width / 2 + perPlotWidth / 2;
            //计算最左最右的x轴标签不越过边界
            if (xPox < 0) {
                xPox = 0;
            } else if (xPox + textSize.width > endX) {
                xPox = xPox - (xPox + textSize.width - endX);
            }
            //        NSLog(@"xPox = %f", xPox);
            //        NSLog(@"textSize.width = %f", textSize.width);
            let barLabelRect = CGRectMake(xPox, startY, textSize.width, textSize.height)
            NSString(string: xLabel).drawInRect(barLabelRect,
                                                withAttributes: fontAttributes)
            
            
            k = k + xTickInterval
            startX = perPlotWidth * CGFloat(k)
        }
        
        CGContextStrokePath(context)
    }
    
    
    /**
     绘制分区
     
     - parameter section:
     */
    private func drawSection(section: CHSection) {
        
        let context = UIGraphicsGetCurrentContext();
        CGContextSetShouldAntialias(context, false);
        CGContextSetLineWidth(context, 0.5);
        CGContextSetStrokeColorWithColor(context, UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1).CGColor)
        
        //画低部边线
        CGContextMoveToPoint(context,
                             section.frame.origin.x + section.padding.left,
                             section.frame.size.height + section.frame.origin.y);
        CGContextAddLineToPoint(context,
                                section.frame.origin.x + section.frame.size.width,
                                section.frame.size.height + section.frame.origin.y);
        //画顶部边线
        CGContextMoveToPoint(context,
                             section.frame.origin.x + section.padding.left,
                             section.frame.origin.y);
        CGContextAddLineToPoint(context,
                                section.frame.origin.x + section.frame.size.width,
                                section.frame.origin.y);
        CGContextStrokePath(context);
        
    }
    
    /**
     初始化分区上各个线的Y轴
     */
    private func initYAxis(section: CHSection) {
        
        if section.series.count > 0 {
            //建立分区每条线的坐标系
            for serie in section.series {
                for serieModel in serie {
                    serieModel.datas = self.datas
                    section.buildYAxis(serieModel.datas,
                                       startIndex: self.rangeFrom,
                                       endIndex: self.rangeTo - 1)
                }
            }
            
        }
        
    }
    
    /**
     绘制Y轴左边
     
     - parameter section: 分区
     */
    private func drawYAxis(section: CHSection) {
        let context = UIGraphicsGetCurrentContext();
        CGContextSetShouldAntialias(context, NO );
        CGContextSetLineWidth(context, 1.0f);
        CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:0.2 green:0.2 blue:0.2 alpha:1.0].CGColor);
        
        CGFloat startX = 0;
        BOOL showYAxisLabel = YES;
        
        //画区域边框
        for(int secIndex=0;secIndex<[self.sections count];secIndex++){
            Section *sec = [self.sections objectAtIndex:secIndex];
            
            
            if(sec.hidden){
                continue;
            }
            //		CGContextMoveToPoint(context, sec.frame.origin.x+sec.paddingLeft,sec.frame.origin.y+sec.paddingTop);
            CGContextMoveToPoint(context, sec.frame.origin.x+sec.paddingLeft,sec.frame.origin.y);
            CGContextAddLineToPoint(context, sec.frame.origin.x+sec.paddingLeft,sec.frame.size.height+sec.frame.origin.y);
            //		CGContextMoveToPoint(context, sec.frame.origin.x+sec.frame.size.width - sec.paddingRight,sec.frame.origin.y+sec.paddingTop);
            CGContextMoveToPoint(context, sec.frame.origin.x+sec.frame.size.width - sec.paddingRight,sec.frame.origin.y);
            CGContextAddLineToPoint(context, sec.frame.origin.x+sec.frame.size.width - sec.paddingRight,sec.frame.size.height+sec.frame.origin.y);
            CGContextStrokePath(context);
        }
        
        CGContextSetRGBFillColor(context, 0.8, 0.8, 0.8, 1.0);      //文字填充颜色
        CGFloat dash[] = {5};
        CGContextSetLineDash (context,0,dash,1);
        
        //分区中各个y轴虚线和y轴的label
        for(int secIndex=0;secIndex<self.sections.count;secIndex++){
            Section *sec = [self.sections objectAtIndex:secIndex];
            
            //控制y轴的label在左还是右显示
            if (self.yAxisLabelShow == 0) {
                showYAxisLabel = NO;
            } else if (self.yAxisLabelShow == 1) {
                startX = sec.frame.origin.x-1;
            } else if (self.yAxisLabelShow == 2) {
                startX = sec.frame.origin.x + sec.frame.size.width - sec.paddingRight + 3;
            }
            
            if(sec.hidden){
                continue;
            }
            for(int aIndex=0;aIndex<sec.yAxises.count;aIndex++){
                
                YAxis *yaxis = [sec.yAxises objectAtIndex:aIndex];
                NSString *format=[@"%." stringByAppendingFormat:@"%df",yaxis.decimal];
                
                float baseY = [self getLocalY:yaxis.baseValue withSection:secIndex withAxis:aIndex];
                CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:0.2 green:0.2 blue:0.2 alpha:1.0].CGColor);
                CGContextMoveToPoint(context,sec.frame.origin.x+sec.paddingLeft+sec.frame.size.width-sec.paddingRight,baseY);
                if(!isnan(baseY)){
                    CGContextAddLineToPoint(context, sec.frame.origin.x+sec.paddingLeft+sec.frame.size.width-sec.paddingRight+2, baseY);
                }
                CGContextStrokePath(context);
                CGContextSetShouldAntialias(context, YES);  //抗锯齿开启，解决字体发虚
                [[@"" stringByAppendingFormat:format,yaxis.baseValue] drawAtPoint:CGPointMake(startX,baseY-7) withFont:[UIFont systemFontOfSize: 10]];
                
                CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:0.15 green:0.15 blue:0.15 alpha:1.0].CGColor);
                CGContextMoveToPoint(context,sec.frame.origin.x+sec.paddingLeft,baseY);
                if(!isnan(baseY)){
                    CGContextAddLineToPoint(context,sec.frame.origin.x+sec.frame.size.width-sec.paddingRight,baseY);
                }
                
                if (yaxis.tickInterval%2 == 1) {
                    yaxis.tickInterval +=1;
                }
                
                //计算y轴的标签及虚线分几段
                float step = (float)(yaxis.max-yaxis.min)/yaxis.tickInterval;
                for(int i=1; i<= yaxis.tickInterval+1;i++){
                    if(yaxis.baseValue + i*step <= yaxis.max){
                        float iy = [self getLocalY:(yaxis.baseValue + i*step) withSection:secIndex withAxis:aIndex];
                        
                        CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:0.2 green:0.2 blue:0.2 alpha:1.0].CGColor);
                        CGContextMoveToPoint(context,sec.frame.origin.x+sec.paddingLeft+sec.frame.size.width-sec.paddingRight,iy);
                        if(!isnan(iy)){
                            CGContextAddLineToPoint(context,sec.frame.origin.x+sec.paddingLeft+sec.frame.size.width-sec.paddingRight+2,iy);
                        }
                        CGContextStrokePath(context);
                        CGContextSetShouldAntialias(context, YES);
                        [[@"" stringByAppendingFormat:format,yaxis.baseValue+i*step] drawAtPoint:CGPointMake(startX,iy-7) withFont:[UIFont systemFontOfSize: 10]];
                        
                        //					if(yaxis.baseValue + i*step < yaxis.max){
                        CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:0.15 green:0.15 blue:0.15 alpha:1.0].CGColor);
                        CGContextMoveToPoint(context,sec.frame.origin.x+sec.paddingLeft,iy);
                        CGContextAddLineToPoint(context,sec.frame.origin.x+sec.frame.size.width-sec.paddingRight,iy);
                        //					}
                        
                        CGContextStrokePath(context);
                    }
                }
                
                //不清楚下面代码的作用
                /*
                 for(int i=1; i <= yaxis.tickInterval+1;i++){
                 if(yaxis.baseValue - i*step >= yaxis.min){
                 float iy = [self getLocalY:(yaxis.baseValue - i*step) withSection:secIndex withAxis:aIndex];
                 
                 CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:0.2 green:0.2 blue:0.2 alpha:1.0].CGColor);
                 CGContextMoveToPoint(context,sec.frame.origin.x+sec.paddingLeft,iy);
                 if(!isnan(iy)){
                 CGContextAddLineToPoint(context,sec.frame.origin.x+sec.paddingLeft-2,iy);
                 }
                 CGContextStrokePath(context);
                 CGContextSetShouldAntialias(context, YES);
                 [[@"" stringByAppendingFormat:format,yaxis.baseValue-i*step] drawAtPoint:CGPointMake(startX,iy-7) withFont:[UIFont systemFontOfSize: 9]];
                 
                 if(yaxis.baseValue - i*step > yaxis.min){
                 CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:0.15 green:0.15 blue:0.15 alpha:1.0].CGColor);
                 CGContextMoveToPoint(context,sec.frame.origin.x+sec.paddingLeft,iy);
                 CGContextAddLineToPoint(context,sec.frame.origin.x+sec.frame.size.width-sec.paddingRight,iy);
                 }
                 
                 CGContextStrokePath(context);
                 }
                 }
                 */
            }
        }
        CGContextSetLineDash (context,0,NULL,0);
    }
}

