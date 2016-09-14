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
        let upcolor = UIColor.ch_hex(0xF80D1F)
        let downcolor = UIColor.ch_hex(0x1E932B)
        let priceSection = CHSection()
        priceSection.titleShowOutSide = true
        priceSection.valueType = .Price
        priceSection.hidden = false
        priceSection.ratios = 3
        priceSection.padding = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        let priceSeries = CHSeries.getDefaultPrice(upColor: upcolor, downColor: downcolor, section: priceSection)
        priceSection.series = [priceSeries]
        
        let volumeSection = CHSection()
        volumeSection.valueType = .Volume
        volumeSection.hidden = false
        volumeSection.ratios = 1
        volumeSection.padding = UIEdgeInsets(top: 16, left: 0, bottom: 8, right: 0)
        let volumeSeries = CHSeries.getDefaultVolume(upColor: upcolor, downColor: downcolor, section: volumeSection)
        volumeSection.series = [volumeSeries]
        
        let trendSection = CHSection()
        trendSection.valueType = .Analysis
        trendSection.hidden = false
        trendSection.ratios = 1
        trendSection.padding = UIEdgeInsets(top: 16, left: 0, bottom: 8, right: 0)
        let trendSeries = CHSeries.getKDJ(UIColor.ch_hex(0xDDDDDD),
                                          dc: UIColor.ch_hex(0xF9EE30),
                                          jc: UIColor.ch_hex(0xF600FF),
                                          section: trendSection)
        trendSection.series = [trendSeries]

        return [priceSection, volumeSection, trendSection]
    }
    
    /**
     要处理的算法
     
     - returns:
     */
    func getAlgorithms() -> [CHChartAlgorithm] {
        return [CHChartAlgorithm.MA(5),
                CHChartAlgorithm.MA(10),
                CHChartAlgorithm.MA(30),
                CHChartAlgorithm.KDJ(9, 3, 3),
        ]
    }
    
    func getBackgroundColor() -> UIColor {
        return UIColor.ch_hex(0x1D1C1C)
    }
    
    func getPadding() -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 8, bottom: 20, right: 0)
    }
    
}



/**
 *  K线数据源代理
 */
@objc public protocol CHKLineChartDelegate: class {
    
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
    optional func kLineChart(chart: CHKLineChartView, labelOnXAxisForIndex index: Int) -> String
    
}

public class CHKLineChartView: UIView {
    
    /// MARK: - 常量
    var kMinRange = 9       //最小缩放范围
    var kMaxRange = 121     //最大缩放范围
    var kPerInterval = 4    //缩放的每段间隔
    
    /// MARK: - 成员变量
    @IBInspectable public var upColor: UIColor = UIColor.greenColor()     //升的颜色
    @IBInspectable public var downColor: UIColor = UIColor.redColor()     //跌的颜色
    @IBInspectable public var labelFont = UIFont.systemFontOfSize(10)
    @IBInspectable public var lineColor: UIColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1) //线条颜色
    @IBInspectable public var dashColor: UIColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1) //线条颜色
    @IBInspectable public var textColor: UIColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1) //文字颜色
    @IBInspectable public var xAxisPerInterval: Int = 4                        //x轴的间断个数
    @IBInspectable public var yLabelWidth:CGFloat = 46                    //Y轴的宽度
    
    public var handlerOfAlgorithms: [CHChartAlgorithm] = [CHChartAlgorithm]()
    public var padding: UIEdgeInsets = UIEdgeInsetsZero    //内边距
    public var showYLabel = CHYAxisShowPosition.Right      //显示y的位置，默认右边
    public var style = CHKLineChartStyle.Default {           //显示样式
        didSet {
            //重新配置样式
            self.sections = self.style.getSections()
            self.backgroundColor = self.style.getBackgroundColor()
            self.padding = self.style.getPadding()
            self.handlerOfAlgorithms = self.style.getAlgorithms()
            //            self.setNeedsDisplay()
        }
        
    }
    
    @IBOutlet public weak var delegate: CHKLineChartDelegate?             //代理
    
    var sections = [CHSection]()
    var selectedIndex: Int = -1                      //选择索引位
    var selectedPoint: CGPoint = CGPointZero
    
    var enableSelection = true                      //是否可点选
    
    var borderWidth: CGFloat = 0.5
    var lineWidth: CGFloat = 0.5
    var plotCount: Int = 0
    var rangeFrom: Int = 0                          //可见区域的开始索引位
    var rangeTo: Int = 0                            //可见区域的结束索引位
    var range: Int = 49                             //显示在可见区域的个数
    var borderColor: UIColor = UIColor.grayColor()
    var labelSize = CGSizeMake(40, 16)
    var isInitialized = false                       //是否已经初始化数据
    
    var datas: [CHChartItem] = [CHChartItem]()      //数据源
    
    var selectedBGColor: UIColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
    var verticalLineView: UIView!
    var horizontalLineView: UIView!
    var selectedXAxisLabel: UILabel!
    var selectedYAxisLabel: UILabel!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.initUI()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initUI()
    }
    
    convenience init(style: CHKLineChartStyle) {
        self.init()
        self.initUI()
        self.style = style
    }
    
    /**
     初始化UI
     
     - returns:
     */
    private func initUI() {
        
        self.multipleTouchEnabled = true
        
        //初始化点击选择的辅助线显示
        self.verticalLineView = UIView(frame: CGRectMake(0, 0, lineWidth, 0))
        self.verticalLineView.backgroundColor = self.selectedBGColor
        self.verticalLineView.hidden = true
        self.addSubview(self.verticalLineView)
        
        self.horizontalLineView = UIView(frame: CGRectMake(0, 0, 0, lineWidth))
        self.horizontalLineView.backgroundColor = self.selectedBGColor
        self.horizontalLineView.hidden = true
        self.addSubview(self.horizontalLineView)
        
        //用户点击图表显示当前y轴的实际值
        self.selectedYAxisLabel = UILabel(frame: CGRectZero)
        self.selectedYAxisLabel.backgroundColor = self.selectedBGColor
        self.selectedYAxisLabel.hidden = true
        self.selectedYAxisLabel.font = self.labelFont
        self.selectedYAxisLabel.textColor = self.textColor
        self.selectedYAxisLabel.textAlignment = NSTextAlignment.Center
        self.addSubview(self.selectedYAxisLabel)
        
        //用户点击图表显示当前x轴的实际值
        self.selectedXAxisLabel = UILabel(frame: CGRectZero)
        self.selectedXAxisLabel.backgroundColor = self.selectedBGColor
        self.selectedXAxisLabel.hidden = true
        self.selectedXAxisLabel.font = self.labelFont
        self.selectedXAxisLabel.textColor = self.textColor
        self.selectedXAxisLabel.textAlignment = NSTextAlignment.Center
        self.addSubview(self.selectedXAxisLabel)
        
        //添加手势操作
        self.addGestureRecognizer(UIPanGestureRecognizer(
            target: self,
            action: #selector(doPanAciton(_:))))
        
        //点击手势操作
        self.addGestureRecognizer(UITapGestureRecognizer(target: self,
            action: #selector(doTapAction(_:))))
        
        
        //双指缩放操作
        self.addGestureRecognizer(UIPinchGestureRecognizer(
            target: self,
            action: #selector(doPinchAction(_:))))
        
        //初始数据
        self.resetData()
        
    }
    
    /**
     初始化数据
     */
    private func resetData() {
        
        self.plotCount = self.delegate?.numberOfPointsInKLineChart(self) ?? 0
        
        if plotCount > 0 {
            
            //获取代理上的数据源
            for i in 0...self.plotCount - 1 {
                let item = self.delegate?.kLineChart(self, valueForPointAtIndex: i)
                self.datas.append(item!)
            }
            
            //执行算法方程式计算值，添加到对象中
            for algorithm in self.handlerOfAlgorithms {
                //执行该算法，计算指标数据
                self.datas = algorithm.handleAlgorithm(self.datas)
            }
        }
    }
    
    
    /**
     获取点击区域所在分区位
     
     - parameter point: 点击坐标
     
     - returns: 返回section和索引位
     */
    func getSectionByTouchPoint(point: CGPoint) -> (Int, CHSection?) {
        for (i, section) in self.sections.enumerate() {
            if CGRectContainsPoint(section.frame, point) {
                return (i, section)
            }
        }
        return (-1, nil)
    }
    
    /**
     设置选中的数据点
     
     - parameter point:
     */
    func setSelectedIndexByPoint(point: CGPoint) {
        
        if CGPointEqualToPoint(point, CGPointZero) {
            return
        }
        
        let (_, section) = self.getSectionByTouchPoint(point)
        if section == nil {
            return
        }
        
        let yaxis = section!.yAxis
        let format = "%.".stringByAppendingFormat("%df", yaxis.decimal)
        
        self.selectedPoint = point
        
        //每个点的间隔宽度
        let plotWidth = (section!.frame.size.width - section!.padding.left - section!.padding.right) / CGFloat(self.rangeTo - self.rangeFrom)
        
        let yVal = section!.getRawValue(point.y)        //获取y轴坐标的实际值
        
        for i in self.rangeFrom...self.rangeTo - 1 {
            let ixs = plotWidth * CGFloat(i - self.rangeFrom) + section!.padding.left + self.padding.left
            let ixe = plotWidth * CGFloat(i - self.rangeFrom + 1) + section!.padding.left + self.padding.left
            //            NSLog("ixs = \(ixs)")
            //            NSLog("ixe = \(ixe)")
            //            NSLog("point.x = \(point.x)")
            if ixs <= point.x && point.x < ixe {
                self.selectedIndex = i
                let item = self.datas[i]
                var hx = section!.frame.origin.x + section!.padding.left
                hx = hx + plotWidth * CGFloat(i - self.rangeFrom) + plotWidth / 2
                let hy = self.padding.top
                let hheight = self.frame.size.height - self.padding.bottom - self.padding.top
                //显示辅助线
                self.horizontalLineView.frame = CGRectMake(hx, hy, self.lineWidth, hheight)
                self.horizontalLineView.hidden = false
                
                let vx = self.padding.left
                let vy = point.y
                let hwidth = section!.frame.size.width - section!.padding.left - section!.padding.right
                //显示辅助线
                self.verticalLineView.frame = CGRectMake(vx, vy, hwidth, self.lineWidth)
                self.verticalLineView.hidden = false
                
                //显示y轴辅助内容
                //控制y轴的label在左还是右显示
                var yAxisStartX: CGFloat = 0
                self.selectedYAxisLabel.hidden = false
                self.selectedXAxisLabel.hidden = false
                switch self.showYLabel {
                case .Left:
                    yAxisStartX = section!.frame.origin.x
                case .Right:
                    yAxisStartX = section!.frame.origin.x + section!.frame.size.width - section!.padding.right
                case .None:
                    self.selectedYAxisLabel.hidden = true
                }
                self.selectedYAxisLabel.text = String(format: format, yVal)     //显示实际值
                self.selectedYAxisLabel.frame = CGRectMake(yAxisStartX, point.y - self.labelSize.height / 2, self.yLabelWidth, self.labelSize.height)
                let time = NSDate.getTimeByStamp(item.time, format: "yyyy-MM-dd HH:mm") //显示实际值
                let size = time.ch_heightWithConstrainedWidth(self.labelFont)
                self.selectedXAxisLabel.text = time
                self.selectedXAxisLabel.frame = CGRectMake(hx - (size.width + 6) / 2, self.frame.size.height - self.padding.bottom, size.width  + 6, self.labelSize.height)
                
                break
            }
            
        }
    }
    
}

// MARK: - 绘图相关方法
extension CHKLineChartView {
    
    /**
     绘制图表
     
     - parameter rect:
     */
    override public func drawRect(rect: CGRect) {
        
        var lastSection: CHSection!
        //初始化数据
        if self.initChart() {
            
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
                
                //显示范围最后一个点的内容
                section.drawTitle(self.selectedIndex)
                
                //记录最后一个分区
                lastSection = section
            
            }
            
            //最后一个分区下面绘制X轴坐标
            self.drawXAxis(lastSection)
            
            //重新显示点击选中的坐标
            self.setSelectedIndexByPoint(self.selectedPoint)
        }
        
    }
    
    /**
     初始化图表结构
     
     - returns: 是否初始化数据
     */
    private func initChart() -> Bool {
        
        self.plotCount = self.delegate?.numberOfPointsInKLineChart(self) ?? 0
        
        if plotCount > 0 {
            if self.rangeTo == 0 {      //如果图表尽头的索引为0，则进行初始化
                self.rangeTo = self.plotCount               //默认是数据最后一条为尽头
                if self.rangeTo - self.range > 0 {          //如果尽头 - 默认显示数大于0
                    self.rangeFrom = self.rangeTo - range   //计算开始的显示的位置
                } else {
                    self.rangeFrom = 0
                }
                
            }
        }
        
        //选择最后一个元素选中
        if selectedIndex == -1 {
            self.selectedIndex = self.rangeTo - 1
        }
        
        
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, self.backgroundColor!.CGColor)
        CGContextFillRect (context, CGRectMake (0, 0, self.bounds.size.width,self.bounds.size.height))
        
        return self.datas.count > 0 ? true : false
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
    private func drawXAxis(lastSection: CHSection) {
        
        var startX: CGFloat = lastSection.frame.origin.x + lastSection.padding.left
        let endX: CGFloat = lastSection.frame.origin.x + lastSection.frame.size.width - lastSection.padding.right
        let secWidth: CGFloat = lastSection.frame.size.width
        let secPaddingLeft: CGFloat = lastSection.padding.left
        let secPaddingRight: CGFloat = lastSection.padding.right
        
        let context = UIGraphicsGetCurrentContext()
        CGContextSetShouldAntialias(context, false)
        CGContextSetLineWidth(context, self.lineWidth)
        CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor)
        
        //x轴分平均分4个间断，显示5个x轴坐标，按照图表的值个数，计算每个间断的个数
        let dataRange = self.rangeTo - self.rangeFrom
        let xTickInterval: Int = dataRange / self.xAxisPerInterval
        
        //绘制x轴标签
        //每个点的间隔宽度
        let perPlotWidth: CGFloat = (secWidth - secPaddingLeft - secPaddingRight) / CGFloat(self.rangeTo - self.rangeFrom)
        let startY = self.frame.size.height - self.padding.bottom
        var k: Int = 0
        
        //X轴标签的字体样式
        let textStyle = NSMutableParagraphStyle()
        textStyle.alignment = NSTextAlignment.Center
        textStyle.lineBreakMode = NSLineBreakMode.ByClipping
        
        let fontAttributes = [
            NSFontAttributeName: self.labelFont,
            NSParagraphStyleAttributeName: textStyle,
            NSForegroundColorAttributeName: self.textColor
        ]
        
        //相当 for var i = self.rangeFrom; i < self.rangeTo; i = i + xTickInterval
        for i in self.rangeFrom.stride(to: self.rangeTo, by: xTickInterval) {
            CGContextSetFillColorWithColor(context, self.textColor.CGColor)
            CGContextSetShouldAntialias(context, true)  //抗锯齿开启，解决字体发虚
            let xLabel = self.delegate?.kLineChart?(self, labelOnXAxisForIndex: i) ?? ""
            var textSize = xLabel.ch_heightWithConstrainedWidth(self.labelFont)
            textSize.width = textSize.width + 4
            var xPox = startX - textSize.width / 2 + perPlotWidth / 2
            //计算最左最右的x轴标签不越过边界
            if (xPox < 0) {
                xPox = startX
            } else if (xPox + textSize.width > endX) {
                xPox = xPox - (xPox + textSize.width - endX)
            }
            //        NSLog(@"xPox = %f", xPox)
            //        NSLog(@"textSize.width = %f", textSize.width)
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
        
        let context = UIGraphicsGetCurrentContext()
        CGContextSetShouldAntialias(context, false)
        CGContextSetLineWidth(context, self.lineWidth)
        CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor)
        
        //画低部边线
        CGContextMoveToPoint(context,
                             section.frame.origin.x + section.padding.left,
                             section.frame.size.height + section.frame.origin.y)
        CGContextAddLineToPoint(context,
                                section.frame.origin.x + section.frame.size.width,
                                section.frame.size.height + section.frame.origin.y)
        //画顶部边线
        CGContextMoveToPoint(context,
                             section.frame.origin.x + section.padding.left,
                             section.frame.origin.y)
        CGContextAddLineToPoint(context,
                                section.frame.origin.x + section.frame.size.width,
                                section.frame.origin.y)
        
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
            section.yAxis.isUsed = false
            //建立分区每条线的坐标系
            for serie in section.series {
                for serieModel in serie.chartModels {
                    serieModel.datas = self.datas
                    section.buildYAxis(serieModel,
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
            NSFontAttributeName: self.labelFont,
            NSForegroundColorAttributeName: self.textColor
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
        while yVal <= yaxis.max && i <= yaxis.tickInterval {
            //画虚线和Y标签值
            let iy = section.getLocalY(yVal)
            if showYAxisLabel {
                //突出的线段
                CGContextSetShouldAntialias(context, false)
                CGContextSetStrokeColorWithColor(context, self.dashColor.CGColor)
                CGContextMoveToPoint(context, section.frame.origin.x + section.padding.left + section.frame.size.width - section.padding.right, iy)
                if(!isnan(iy)){
                    CGContextAddLineToPoint(context, section.frame.origin.x + section.padding.left + section.frame.size.width - section.padding.right + 2, iy)
                }
                CGContextStrokePath(context)
                
                //把Y轴标签文字画上去
                CGContextSetShouldAntialias(context, true)  //抗锯齿开启，解决字体发虚
                NSString(format: format, yVal).drawAtPoint(
                    CGPointMake(startX, iy - 7), withAttributes: fontAttributes)
            }
            
            CGContextSetShouldAntialias(context, false)
            CGContextSetStrokeColorWithColor(context, self.dashColor.CGColor)
            CGContextMoveToPoint(context, section.frame.origin.x + section.padding.left, iy)
            if(!isnan(iy)){
                CGContextAddLineToPoint(context, section.frame.origin.x + section.frame.size.width - section.padding.right, iy)
            }
            
            CGContextStrokePath(context)
            
            //递增下一个
            i =  i + 1
            yVal = yaxis.baseValue + CGFloat(i) * step
        }
        
        CGContextSetLineDash (context, 0, nil, 0)
    }
    
    /**
     绘制图表上的点线
     
     - parameter section:
     */
    func drawChart(section: CHSection) {
        
        //当前显示的系列
        let serie = section.series[section.selectedIndex]
        //循环画出每个模型的线
        for model in serie.chartModels {
            model.drawSerie(self.rangeFrom, endIndex: self.rangeTo)
        }
    }
    
}

// MARK: - 公开方法
extension CHKLineChartView {
    
    /**
     刷新视图
     */
    public func reloadData() {
        self.resetData()
        self.setNeedsDisplay()
    }
}


// MARK: - 手势操作
extension CHKLineChartView {
    
    /**
     *  拖动操作
     *
     *  @param sender
     */
    func doPanAciton(sender: UIPanGestureRecognizer) {
        let translation = sender.translationInView(self)
        let  velocity =  sender.velocityInView(self)
        
        var interval: Int = 0
        
        //处理滑动的幅度
        let panRange = fabs(velocity.x)    //滑动的力度
        interval = Int(panRange / 70)              //力度大于100才移动
        if (interval > 4) {                     //移动的间隔不超过5
            interval = 4
        }
        if (interval > 0) {                     //有移动间隔才移动
            if(translation.x > 0){
                //单指向右拖，往后查看数据
                if self.plotCount > (self.rangeTo-self.rangeFrom) {
                    if self.rangeFrom - interval >= 0 {
                        self.rangeFrom -= interval
                        self.rangeTo   -= interval
                        
                    } else {
                        self.rangeFrom = 0
                        self.rangeTo -= self.rangeFrom
                        
                    }
                    self.setNeedsDisplay()
                }
            } else if translation.x < 0 {
                //单指向左拖，往前查看数据
                if self.plotCount > (self.rangeTo-self.rangeFrom) {
                    if self.rangeTo + interval <= self.plotCount {
                        self.rangeFrom += interval
                        self.rangeTo += interval
                        
                    } else {
                        self.rangeFrom += self.plotCount - self.rangeTo
                        self.rangeTo  = self.plotCount
                        
                        
                    }
                    self.setNeedsDisplay()
                }
            }
        }
        
        sender.setTranslation(CGPointMake(0, 0), inView: self)
    }
    
    /**
     *  点击事件处理
     *
     *  @param sender
     */
    func doTapAction(sender: UITapGestureRecognizer) {
        let point = sender.locationInView(self)
        let (_, section) = self.getSectionByTouchPoint(point)
        if section != nil {
            self.setSelectedIndexByPoint(point)
            //显示点击选中的内容
            self.setNeedsDisplay()
        }
    }
    
    
    /**
     *  双指缩放操作
     */
    func doPinchAction(sender: UIPinchGestureRecognizer) {
        //双指合拢或张开
        let interval = self.kPerInterval / 2
        let scale = sender.scale
        let velocity = sender.velocity
        
        var newRangeTo = 0
        var newRangeFrom = 0
        var newRange = 0
        if fabs(velocity) > 0.1 {   //力度的绝对值大于0.1才起作用
            if scale > 1 {
                //双指张开
                newRangeTo = self.rangeTo - interval
                newRangeFrom = self.rangeFrom + interval
                newRange = self.rangeTo - self.rangeFrom
                if newRange >= kMinRange {
                    
                    if self.plotCount > self.rangeTo - self.rangeFrom {
                        if newRangeFrom < self.rangeTo {
                            self.rangeFrom = newRangeFrom
                        }
                        if newRangeTo > self.rangeFrom {
                            self.rangeTo = newRangeTo
                        }
                    }else{
                        if newRangeTo > self.rangeFrom {
                            self.rangeTo = newRangeTo
                        }
                    }
                    self.setNeedsDisplay()
                }
                
            } else {
                //双指合拢
                newRangeTo = self.rangeTo + interval
                newRangeFrom = self.rangeFrom - interval
                newRange = self.rangeTo - self.rangeFrom
                if newRange <= kMaxRange {
                    
                    if newRangeFrom >= 0 {
                        self.rangeFrom = newRangeFrom
                    } else {
                        self.rangeFrom = 0
                        newRangeTo = newRangeTo - newRangeFrom //补充负数位到头部
                    }
                    if newRangeTo <= self.plotCount {
                        self.rangeTo = newRangeTo
                        
                    } else {
                        self.rangeTo = self.plotCount
                        newRangeFrom = newRangeFrom - (newRangeTo - self.plotCount)
                        if newRangeFrom < 0 {
                            self.rangeFrom = 0
                        } else {
                            self.rangeFrom = newRangeFrom
                        }
                    }
                    
                    self.setNeedsDisplay()
                }
            }
        }
        
        sender.scale = 1
    }
    
}