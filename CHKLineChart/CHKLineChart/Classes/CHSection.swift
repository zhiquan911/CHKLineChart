//
//  CHSection.swift
//  CHKLineChart
//
//  Created by Chance on 16/8/31.
//  Copyright © 2016年 Chance. All rights reserved.
//

import UIKit


public enum CHSectionValueType {
    case price              //价格
    case volume             //交易量
    case analysis           //指标
    
    public var key: String {
        switch self {
        case .price:
            return "Price"
        case .volume:
            return "Volume"
        case .analysis:
            return "Analysis"
        }
    }
}


/**
 *  K线的区域
 */
open class CHSection: NSObject {
    
    /// MARK: - 成员变量
    open var upColor: UIColor = UIColor.green     //升的颜色
    open var downColor: UIColor = UIColor.red     //跌的颜色
    open var titleColor: UIColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1) //文字颜色
    open var labelFont = UIFont.systemFont(ofSize: 10)
    open var valueType: CHSectionValueType = CHSectionValueType.price {
        didSet {
            self.key = valueType.key
        }
    }
    open var key = ""
    open var name: String = ""                              //区域的名称
    open var hidden: Bool = false
    open var paging: Bool = false
    open var selectedIndex: Int = 0
    open var padding: UIEdgeInsets = UIEdgeInsets.zero
    open var series = [CHSeries]()                          //每个分区包含多组系列，每个系列包含多个点线模型
    open var tickInterval: Int = 0
    open var title: String = ""                                      //标题
    open var titleShowOutSide: Bool = false                          //标题是否显示在外面
    open var showTitle: Bool = true                                 //是否显示标题文本
    open var decimal: Int = 2                                        //小数位的长度
    open var ratios: Int = 0                                         //所占区域比例
    open var fixHeight: CGFloat = 0                                 //固定高度，为0则通过ratio计算高度
    open var frame: CGRect = CGRect.zero
    open var yAxis: CHYAxis = CHYAxis()                           //Y轴参数
    open var xAxis: CHXAxis = CHXAxis()                             //X轴参数
    open var backgroundColor: UIColor = UIColor.black
    open var index: Int = 0
    var titleLayer: CHShapeLayer = CHShapeLayer()                           //显示标题内容的层
    var sectionLayer: CHShapeLayer = CHShapeLayer()                 //分区的绘图层
    
    /// 初始化分区
    ///
    /// - Parameter valueType: 分区类型
    convenience init(valueType: CHSectionValueType) {
        self.init()
        self.valueType = valueType
    }
    
    
    /// 清空图表的子图层
    func removeLayerView() {
        _ = self.sectionLayer.sublayers?.map { $0.removeFromSuperlayer() }
        self.sectionLayer.sublayers?.removeAll()
        
        _ = self.titleLayer.sublayers?.map { $0.removeFromSuperlayer() }
        self.titleLayer.sublayers?.removeAll()
    }
    
    func buildYAxis(startIndex: Int, endIndex: Int, datas: [CHChartItem]) {
        self.yAxis.isUsed = false
        var baseValueSticky = false
        var symmetrical = false
        if self.paging {     //如果分页，计算当前选中的系列作为坐标系的数据源
            //建立分区每条线的坐标系
            let serie = self.series[self.selectedIndex]
            baseValueSticky = serie.baseValueSticky
            symmetrical = serie.symmetrical
            for serieModel in serie.chartModels {
                serieModel.datas = datas
                self.buildYAxisPerModel(serieModel,
                                   startIndex: startIndex,
                                   endIndex: endIndex)
            }
        } else {
            for serie in self.series {   //不分页，计算所有系列作为坐标系的数据源
                baseValueSticky = serie.baseValueSticky
                symmetrical = serie.symmetrical
                for serieModel in serie.chartModels {
                    serieModel.datas = datas
                    self.buildYAxisPerModel(serieModel,
                                       startIndex: startIndex,
                                       endIndex: endIndex)
                }
            }
        }
        
        //让边界溢出些，这样图表不会占满屏幕
        //        self.yAxis.max += (self.yAxis.max - self.yAxis.min) * self.yAxis.ext
        //        self.yAxis.min -= (self.yAxis.max - self.yAxis.min) * self.yAxis.ext
        
        if !baseValueSticky {        //不使用固定基值
            if self.yAxis.max >= 0 && self.yAxis.min >= 0 {
                self.yAxis.baseValue = self.yAxis.min
            } else if self.yAxis.max < 0 && self.yAxis.min < 0 {
                self.yAxis.baseValue = self.yAxis.max
            } else {
                self.yAxis.baseValue = 0
            }
        } else {                                //使用固定基值
            if self.yAxis.baseValue < self.yAxis.min {
                self.yAxis.min = self.yAxis.baseValue
            }
            
            if self.yAxis.baseValue > self.yAxis.max {
                self.yAxis.max = self.yAxis.baseValue
            }
        }
        
        //如果使用水平对称显示y轴，基本基值计算上下的边界值
        if symmetrical {
            if self.yAxis.baseValue > self.yAxis.max {
                self.yAxis.max = self.yAxis.baseValue + (self.yAxis.baseValue - self.yAxis.min)
            } else if self.yAxis.baseValue < self.yAxis.min {
                self.yAxis.min =  self.yAxis.baseValue - (self.yAxis.max - self.yAxis.baseValue)
            } else {
                if (self.yAxis.max - self.yAxis.baseValue) > (self.yAxis.baseValue - self.yAxis.min) {
                    self.yAxis.min = self.yAxis.baseValue - (self.yAxis.max - self.yAxis.baseValue)
                } else {
                    self.yAxis.max = self.yAxis.baseValue + (self.yAxis.baseValue - self.yAxis.min)
                }
            }
        }
    }
    
    /**
     建立Y轴左边对象，由起始位到结束位
     */
    func buildYAxisPerModel(_ model: CHChartModel, startIndex: Int, endIndex: Int) {
        let datas = model.datas
        if datas.count == 0 {
            return  //没有数据返回
        }
        
        if !self.yAxis.isUsed {
            self.yAxis.decimal = self.decimal
            
            self.yAxis.max = 0
            self.yAxis.min = CGFloat.greatestFiniteMagnitude
            self.yAxis.isUsed = true
        }
        
        
        for i in stride(from: startIndex, to: endIndex, by: 1) {
            
            
            let item = datas[i]
            
            switch model {
            case is CHCandleModel:
                
                let high = item.highPrice
                let low = item.lowPrice
                
                //判断数据集合的每个价格，把最大值和最少设置到y轴对象中
                if high > self.yAxis.max {
                    self.yAxis.max = high
                }
                if low < self.yAxis.min {
                    self.yAxis.min = low
                }
                
            case is CHLineModel, is CHBarModel:
                
                let value = model[i].value
                
                if value == nil{
                    continue  //无法计算的值不绘画
                }
                
                //判断数据集合的每个价格，把最大值和最少设置到y轴对象中
                if value! > self.yAxis.max {
                    self.yAxis.max = value!
                }
                if value! < self.yAxis.min {
                    self.yAxis.min = value!
                }
                
            case is CHColumnModel:
                
                let value = item.vol
                
                //判断数据集合的每个价格，把最大值和最少设置到y轴对象中
                if value > self.yAxis.max {
                    self.yAxis.max = value
                }
                if value < self.yAxis.min {
                    self.yAxis.min = value
                }
            default:break
                
            }
            
            
            
        }
    }
    
    /**
     获取y轴上标签数值对应在坐标系中的y值
     
     - parameter val: 标签值
     
     - returns: 坐标系中实际的y值
     */
    func getLocalY(_ val: CGFloat) -> CGFloat {
        let max = self.yAxis.max
        let min = self.yAxis.min
        
        if (max == min) {
            return 0
        }
        
        /*
         计算公式：
         y轴有值的区间高度 = 整个分区高度-（paddingTop+paddingBottom）
         当前y值所在位置的比例 =（当前值 - y最小值）/（y最大值 - y最小值）
         当前y值的实际的相对y轴有值的区间的高度 = 当前y值所在位置的比例 * y轴有值的区间高度
         当前y值的实际坐标 = 分区高度 + 分区y坐标 - paddingBottom - 当前y值的实际的相对y轴有值的区间的高度
         */
        let baseY = self.frame.size.height + self.frame.origin.y - self.padding.bottom - (self.frame.size.height - self.padding.top - self.padding.bottom) * (val - min) / (max - min)
        //        NSLog("baseY(val) = \(baseY)(\(val))")
        //        NSLog("fra.size.height = \(self.frame.size.height)");
        //        NSLog("max = \(max)");
        //        NSLog("min = \(min)");
        return baseY
    }
    
    /**
     获取坐标系中y坐标对应的y值
     
     - parameter y:
     
     - returns:
     */
    func getRawValue(_ y: CGFloat) -> CGFloat {
        let max = self.yAxis.max
        let min = self.yAxis.min
        
        let ymax = self.getLocalY(self.yAxis.min)       //y最大值对应y轴上的最高点，则最小值
        let ymin = self.getLocalY(self.yAxis.max)       //y最小值对应y轴上的最低点，则最大值
        
        if (max == min) {
            return 0
        }
        
        let value = (y - ymax) / (ymin - ymax) * (max - min) + min
        
        return value
    }
    
    /**
     画分区的标题
     */
    func drawTitle(_ chartSelectedIndex: Int) {
        
        guard self.showTitle else {
            return
        }
        
        if chartSelectedIndex == -1 {
            return       //没有数据返回
        }
        
        if self.paging {     //如果分页
            let series = self.series[self.selectedIndex]
            if let attributes = self.getTitleAttributesByIndex(chartSelectedIndex, series: series) {
                self.setHeader(titles: attributes)
            }
      
            
        } else {
            var titleAttr = [(title: String, color: UIColor)]()
            for serie in self.series {   //不分页
                if let attributes = self.getTitleAttributesByIndex(chartSelectedIndex, series: serie) {
                    titleAttr.append(contentsOf: attributes)
                }
                

            }
            
            self.setHeader(titles: titleAttr)
        }
        
        
    }
    
    /**
     画分区中每个系列的标题
 
    func drawTitlePerSerie(_ xPos: CGFloat, chartSelectedIndex: Int, series: CHSeries) -> (CGFloat, CHShapeLayer?) {
        
        if series.hidden {
            return (xPos, nil)
        }
        
        let serieLayer = CHShapeLayer()

        var yPos: CGFloat = 0, w: CGFloat = 0
        if titleShowOutSide {
            yPos = self.frame.origin.y - self.padding.top + 2
        } else {
            yPos = self.frame.origin.y + 2
        }
        
        let startX = xPos
        
        //绘画系列的标题
        
        if !series.title.isEmpty {
            let seriesTitle = series.title + "  "
            let point = CGPoint(x: startX + w, y: yPos)
            let textSize = seriesTitle.ch_sizeWithConstrained(self.labelFont)
            
            let titleText = CHTextLayer()
            titleText.frame = CGRect(origin: point, size: textSize)
            titleText.string = seriesTitle
            titleText.fontSize = self.labelFont.pointSize
            titleText.foregroundColor =  self.titleColor.cgColor
            titleText.backgroundColor = UIColor.clear.cgColor
            titleText.contentsScale = UIScreen.main.scale
            
            serieLayer.addSublayer(titleText)

            
            w += seriesTitle.ch_sizeWithConstrained(self.labelFont).width
        }
        
        for model in series.chartModels {
            var title = ""
            let item = model[chartSelectedIndex]
            switch model {
            case is CHCandleModel:
                
                title += NSLocalizedString("O", comment: "") + ": " +
                    item.openPrice.ch_toString(maxF: self.decimal) + "  "   //开始
                title += NSLocalizedString("H", comment: "") + ": " +
                    item.highPrice.ch_toString(maxF: self.decimal) + "  "   //最高
                title += NSLocalizedString("L", comment: "") + ": " +
                    item.lowPrice.ch_toString(maxF: self.decimal) + "  "    //最低
                title += NSLocalizedString("C", comment: "") + ": " +
                    item.closePrice.ch_toString(maxF: self.decimal) + "  "  //收市
                
            case is CHColumnModel:
                title += model.title + ": " + item.vol.ch_toString(maxF: self.decimal) + "  "
            default:
                if item.value != nil {
                    title += model.title + ": " + item.value!.ch_toString(maxF: self.decimal) + "  "
                }  else {
                    title += model.title + ": --  "
                }
                
            }
            
            var textColor: UIColor
            
            if model.useTitleColor {    //是否用标题颜色
                textColor = model.titleColor
//                context?.setFillColor(model.titleColor.cgColor)
            } else {
                switch item.trend {
                case .up, .equal:
                    textColor = model.upStyle.color
                case .down:
                    textColor = model.downStyle.color
                }
            }
            
            let point = CGPoint(x: startX + w, y: yPos)
            let textSize = title.ch_sizeWithConstrained(self.labelFont)
            
            let titleText = CHTextLayer()
            titleText.frame = CGRect(origin: point, size: textSize)
            titleText.string = title
            titleText.fontSize = self.labelFont.pointSize
            titleText.foregroundColor =  textColor.cgColor
            titleText.backgroundColor = UIColor.clear.cgColor
            titleText.contentsScale = UIScreen.main.scale
            
            serieLayer.addSublayer(titleText)
            
//            let fontAttributes = [
//                NSFontAttributeName: self.labelFont,
//                NSForegroundColorAttributeName: textColor
//                ] as [String : Any]
//            
//            
//            NSString(string: title).draw(at: point,
//                                         withAttributes: fontAttributes)
            
            w += title.ch_sizeWithConstrained(self.labelFont).width
        }
        return (startX + w, serieLayer)
    }
     */
    
    /// 设置分区头部文本显示内容
    ///
    /// - Parameters:
    ///   - titles: 文本内容及颜色元组
    open func setHeader(titles: [(title: String, color: UIColor)])  {

        var start = 0
        let titleString = NSMutableAttributedString()
        for (title, color) in titles {
            titleString.append(NSAttributedString(string: title))
            let range = NSMakeRange(start, title.ch_length)
//            NSLog("title = \(title)")
//            NSLog("range = \(range)")
            let colorAttribute: [String: AnyObject] = [NSForegroundColorAttributeName: color]
            titleString.addAttributes(colorAttribute, range: range)
            start += title.ch_length
        }
        
        self.drawTitleForHeader(title: titleString)
    }
    
    
    /// 获取标题属性元组
    ///
    /// - Parameters:
    ///   - chartSelectedIndex: 图表选中位置
    ///   - series: 线
    /// - Returns: 标题属性
    open func getTitleAttributesByIndex(_ chartSelectedIndex: Int, series: CHSeries) -> [(title: String, color: UIColor)]? {
        
        if series.hidden {
            return nil
        }
        
        guard series.showTitle else {
            return nil
        }
 
        if chartSelectedIndex == -1 {
            return nil      //没有数据返回
        }
        
        var titleAttr = [(title: String, color: UIColor)]()
        
        if !series.title.isEmpty {
            let seriesTitle = series.title + "  "
            
            titleAttr.append((title: seriesTitle, color: self.titleColor))
            
        }
        
        for model in series.chartModels {
            var title = ""
            var textColor: UIColor
            let item = model[chartSelectedIndex]
            switch model {
            case is CHCandleModel:
                
                title += NSLocalizedString("O", comment: "") + ": " +
                    item.openPrice.ch_toString(maxF: self.decimal) + "  "   //开始
                title += NSLocalizedString("H", comment: "") + ": " +
                    item.highPrice.ch_toString(maxF: self.decimal) + "  "   //最高
                title += NSLocalizedString("L", comment: "") + ": " +
                    item.lowPrice.ch_toString(maxF: self.decimal) + "  "    //最低
                title += NSLocalizedString("C", comment: "") + ": " +
                    item.closePrice.ch_toString(maxF: self.decimal) + "  "  //收市
                
            case is CHColumnModel:
                title += model.title + ": " + item.vol.ch_toString(maxF: self.decimal) + "  "
            default:
                if item.value != nil {
                    title += model.title + ": " + item.value!.ch_toString(maxF: self.decimal) + "  "
                }  else {
                    title += model.title + ": --  "
                }
                
            }
            
            if model.useTitleColor {    //是否用标题颜色
                textColor = model.titleColor
            } else {
                switch item.trend {
                case .up, .equal:
                    textColor = model.upStyle.color
                case .down:
                    textColor = model.downStyle.color
                }
            }
            
            titleAttr.append((title: title, color: textColor))
           
        }
        
        return titleAttr
    }
    
    
    
    /// 绘制header上的标题信息
    ///
    /// - Parameter title: 标题内容
    func drawTitleForHeader(title: NSMutableAttributedString) {
        
        guard self.showTitle else {
            return
        }
        
        _ = self.titleLayer.sublayers?.map { $0.removeFromSuperlayer() }
        self.titleLayer.sublayers?.removeAll()
        
        var yPos: CGFloat = 0, w: CGFloat = 0
        if titleShowOutSide {
            yPos = self.frame.origin.y - self.padding.top + 2
        } else {
            yPos = self.frame.origin.y + 2
        }
        
        let startX = self.frame.origin.x + self.padding.left + 2
        let containerWidth = self.frame.width - self.padding.left - self.padding.right
        
        let point = CGPoint(x: startX + w, y: yPos)
        
        let textSize = title.string.ch_sizeWithConstrained(self.labelFont)
        
        let titleText = CHTextLayer()
        titleText.frame = CGRect(origin: point, size: CGSize(width: containerWidth, height: textSize.height + 20))
        titleText.string = title
        titleText.fontSize = self.labelFont.pointSize
//        titleText.foregroundColor =  self.titleColor.cgColor
        titleText.backgroundColor = UIColor.clear.cgColor
        titleText.contentsScale = UIScreen.main.scale
        titleText.isWrapped = true
        
        self.titleLayer.addSublayer(titleText)
        
    }
    
    //切换到下一个系列显示
    func nextPage() {
        if(self.selectedIndex < self.series.count - 1){
            self.selectedIndex += 1
        } else {
            self.selectedIndex = 0
        }
    }
}
