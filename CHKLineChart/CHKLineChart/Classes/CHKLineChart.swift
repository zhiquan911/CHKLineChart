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
public enum CHYAxisShowPosition {
    case Left, Right, None
}

public enum CHKLineChartStyle {
    case Default
    
    /**
     分区样式配置
     
     - returns:
     */
    func getSections() -> [CHSection] {
        let upcolor = UIColor.chHex(0xF80D1F)
        let downcoloer = UIColor.chHex(0x1E932B)
        let priceSection = CHSection()
        let candleModel = CHCandleModel(upColor: upcolor, downColor: downcoloer)
        priceSection.series = [[candleModel]]
        priceSection.hidden = false
        priceSection.ratios = 3
        
        let volumeSection = CHSection()
        let volumeModel = CHColumnModel(upColor: upcolor, downColor: downcoloer)
        volumeSection.series = [[volumeModel]]
        volumeSection.hidden = false
        volumeSection.ratios = 1
        
//        let trendSection = CHSection()
        return [priceSection, volumeSection]
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
    func numberOfPointsInKLineChart(chart: CHKLineChartView) -> Int
    
    /**
     数据源索引为对应的对象
     
     - parameter chart:
     - parameter index: 索引位
     
     - returns: K线数据对象
     */
    func kLineChart(chart: CHKLineChartView, valueForPointAtIndex index: Int) -> CHChartItem
    
    /**
     获取图表X轴的显示的内容
     
     - parameter chart:
     - parameter index:     索引位
     
     - returns:
     */
    func kLineChart(chart: CHKLineChartView, labelOnXAxisForIndex index: Int) -> String
}

public class CHKLineChartView: UIView {
    
    /// MARK: - 常量
    var kMinRange = 9
    var kMaxRange = 121
    
    /// MARK: - 成员变量
    @IBInspectable public var upColor: UIColor = UIColor.greenColor()     //升的颜色
    @IBInspectable public var downColor: UIColor = UIColor.redColor()     //跌的颜色
    @IBInspectable public var labelFont = UIFont.systemFontOfSize(10)
    @IBInspectable public var lineColor: UIColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1) //线条颜色
    @IBInspectable public var textColor: UIColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1) //文字颜色
    @IBInspectable public var delegate: CHKLineChartDelegate?             //代理
    @IBInspectable public var xAxisPerInterval: Int = 4                        //x轴的间断个数
    @IBInspectable public var yLabelWidth:CGFloat = 35                    //Y轴的宽度
    
    public var padding: UIEdgeInsets = UIEdgeInsetsZero    //内边距
    public var showYLabel = CHYAxisShowPosition.Right      //显示y的位置，默认右边
    public var style = CHKLineChartStyle.Default {           //显示样式
        didSet {
            //重新配置样式
            self.sections = self.style.getSections()
            self.setNeedsDisplay()
        }
        
    }
    var sections = [CHSection]()
    var selectedIndex: Int = 0                      //选择索引位
    
    var enableSelection = true                      //是否可点选
    
    var borderWidth: CGFloat = 0.5
    var plotCount: Int = 0
    var rangeFrom: Int = 0                          //可见区域的开始索引位
    var rangeTo: Int = 0                            //可见区域的结束索引位
    var range: Int = 48                             //显示在可见区域的个数
    var borderColor: UIColor = UIColor.grayColor()
    var xlabelSize = CGSizeMake(40, 14)
    var isInitialized = false                       //是否已经初始化数据
    
    var datas: [CHChartItem] = [CHChartItem]()      //数据源
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.initData()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initData()
    }
    
    convenience init(style: CHKLineChartStyle) {
        self.init()
        self.initData()
        self.style = style
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
        
        var padding = UIEdgeInsetsZero
        var width: CGFloat = 0
        
        //初始化分区的样式
        self.initChart()
        //建立每个分区
        self.buildSections {
            (section, index) in
            //绘制每个区域
            self.drawSection(section)
            //初始Y轴的数据
            self.initYAxis(section)
            //绘制Y轴坐标
            self.drawYAxis(section)
            //绘制图表的点线
            self.drawChart(section)
            
            //记录最后一个分区的边距和宽度
            padding = section.padding
            width = section.frame.width
        }
        
        //绘制X轴坐标
        self.drawXAxis(padding, width: width)
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
     
     - parameter complete: 初始化后，执行每个分区绘制
     */
    private func buildSections(
        complete:(section: CHSection, index: Int) -> Void) {
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
        for (index, section) in self.sections.enumerate() {
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
            
            complete(section: section, index: index)
    
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
        CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor)
        
        //x轴分平均分4个间断，显示5个x轴坐标，按照图表的值个数，计算每个间断的个数
        let dataRange = self.rangeTo - self.rangeFrom;
        let xTickInterval: Int = dataRange / self.xAxisPerInterval;
        
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
            CGContextSetFillColorWithColor(context, self.textColor.CGColor)
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
        CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor)
        
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
        
        //画左边线
        CGContextMoveToPoint(context, section.frame.origin.x + section.padding.left, section.frame.origin.y)
        CGContextAddLineToPoint(context, section.frame.origin.x + section.padding.left, section.frame.size.height + section.frame.origin.y)
        
        //画右边线
        CGContextMoveToPoint(context, section.frame.origin.x + section.frame.size.width - section.padding.right, section.frame.origin.y)
        CGContextAddLineToPoint(context, section.frame.origin.x + section.frame.size.width - section.padding.right, section.frame.size.height + section.frame.origin.y)
        
        CGContextStrokePath(context)
        
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
                                       endIndex: self.rangeTo)
                }
            }
            
        }
        
    }
    
    /**
     绘制Y轴左边
     
     - parameter section: 分区
     */
    private func drawYAxis(section: CHSection) {
        
        let context = UIGraphicsGetCurrentContext()
        
        //设置画笔颜色
        CGContextSetShouldAntialias(context, false)
        CGContextSetLineWidth(context, 1.0)
        CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor)
        
        var startX: CGFloat = 0
        var showYAxisLabel: Bool = true
        
        CGContextSetFillColorWithColor(context, self.textColor.CGColor)      //文字填充颜色
        let dash:[CGFloat] = [5]
        CGContextSetLineDash(context, 0, dash, 1)
        
        //分区中各个y轴虚线和y轴的label
        //控制y轴的label在左还是右显示
        switch self.showYLabel {
        case .Left:
            startX = section.frame.origin.x - 1
        case .Right:
            startX = section.frame.origin.x + section.frame.size.width - section.padding.right + 3
        case .None:
            showYAxisLabel = false
        }
        
        let fontAttributes = [
            NSFontAttributeName: self.labelFont
        ]
        
        var yaxis = section.yAxis
        let format = "%.".stringByAppendingFormat("%df", yaxis.decimal)
        
        //保持Y轴标签个数偶数显示
        if (yaxis.tickInterval % 2 == 1) {
            yaxis.tickInterval += 1
        }
        
        //计算y轴的标签及虚线分几段
        let step = (yaxis.max - yaxis.min) / CGFloat(yaxis.tickInterval)
        var i = 0
        var yVal = yaxis.baseValue + CGFloat(i) * step
        while yVal <= yaxis.max {
            //画虚线和Y标签值
            let iy = section.getLocalY(yVal)
            if showYAxisLabel {
                //突出的线段
                CGContextSetShouldAntialias(context, false)
                CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
                CGContextMoveToPoint(context, section.frame.origin.x + section.padding.left + section.frame.size.width - section.padding.right, iy)
                if(!isnan(iy)){
                    CGContextAddLineToPoint(context, section.frame.origin.x + section.padding.left + section.frame.size.width - section.padding.right + 2, iy)
                }
                CGContextStrokePath(context);
                
                //把Y轴标签文字画上去
                CGContextSetShouldAntialias(context, true);  //抗锯齿开启，解决字体发虚
                NSString(format: format, yaxis.baseValue).drawAtPoint(
                    CGPointMake(startX, iy - 7), withAttributes: fontAttributes)
            }
            
            CGContextSetShouldAntialias(context, false)
            CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
            CGContextMoveToPoint(context, section.frame.origin.x + section.padding.left, iy)
            if(!isnan(iy)){
                CGContextAddLineToPoint(context, section.frame.origin.x + section.frame.size.width - section.padding.right, iy)
            }
            
            CGContextStrokePath(context);
            
            //递增下一个
            i =  i + 1
            yVal = yaxis.baseValue + CGFloat(i) * step
        }
        
        CGContextSetLineDash (context, 0, nil, 0);
    }
    
    /**
     绘制图表上的点线
     
     - parameter section:
     */
    func drawChart(section: CHSection) {
        
        //当前显示的系列
        let serie = section.series[section.selectedIndex]
        //循环画出每个模型的线
        for model in serie {
            model.drawSerie(self.rangeFrom, endIndex: self.rangeTo)
        }
    }
}

