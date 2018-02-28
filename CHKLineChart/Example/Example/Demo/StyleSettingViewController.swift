//
//  StyleSettingViewController.swift
//  CHKLineChart
//
//  Created by Chance on 2017/1/5.
//  Copyright © 2017年 Chance. All rights reserved.
//

import UIKit
import CHKLineChartKit

class StyleSettingViewController: UITableViewController {
    
    @IBOutlet var segThemeStyle: UISegmentedControl!
    @IBOutlet var segYAxisSide: UISegmentedControl!
    @IBOutlet var segCandleColor: UISegmentedControl!
    @IBOutlet var switchEnableTouch: UISwitch!
    @IBOutlet var switchEnableShowValue: UISwitch!
    
    weak var chartView: CHKLineChartView?
    
    //实现一个最基本的样式，开发者可以自由扩展配置样式
    var cusStyle: CHKLineChartStyle = .base
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


// MARK: - 控制器方法
extension StyleSettingViewController {
    
    
    /// 2种主题风格的切换
    ///
    /// - Parameter sender: 
    @IBAction func handleThemeStyleChange(sender: UISegmentedControl) {
        
        let style = self.cusStyle
        
        if sender.selectedSegmentIndex == 0 {
            
            
            /*** 暗黑风格 ***/
            
            //文字颜色
            style.textColor = UIColor(white: 0.8, alpha: 1)
            
            //背景颜色
            style.backgroundColor = UIColor.ch_hex(0x1D1C1C)
            
            //边线颜色
            style.lineColor = UIColor(white: 0.2, alpha: 1)
            
            
            //选中点的显示的文字颜色
            style.selectedTextColor = UIColor(white: 0.8, alpha: 1)
            
        } else {
            
            /*** 明亮风格 ***/
            
            //文字颜色
            style.textColor = UIColor(white: 0.5, alpha: 1)
            
            //背景颜色
            style.backgroundColor = UIColor.white
            
            //边线颜色
            style.lineColor = UIColor(white: 0.8, alpha: 1)
            
            
            //选中点的显示的文字颜色
            style.selectedTextColor = UIColor(white: 0.8, alpha: 1)
            
        }
        
        _ = style.sections.map {
            $0.backgroundColor = style.backgroundColor
        }
        
        //更换价格分区的样式
        self.changePriceSeries(selectedStyle: sender.selectedSegmentIndex,
                               selectedCandleColor: self.segCandleColor.selectedSegmentIndex)
        
        //更换交易量分区的样式
        self.changeVolumeSeries(selectedStyle: sender.selectedSegmentIndex,
                               selectedCandleColor: self.segCandleColor.selectedSegmentIndex)
        
        //更换指标分区的样式
        self.changeTrendSeries(selectedStyle: sender.selectedSegmentIndex,
                                selectedCandleColor: self.segCandleColor.selectedSegmentIndex)
    }
    
    
    /// 更换价格分区的样式
    ///
    /// - Parameters:
    ///   - selectedStyle: 选择的样式
    ///   - selectedCandleColor: 选择的蜡烛颜色样式
    func changePriceSeries(selectedStyle: Int, selectedCandleColor: Int) {
        
        var upcolor: (color: UIColor, isSolid: Bool)
        var downcolor: (color: UIColor, isSolid: Bool)
        
        if selectedCandleColor == 0 {
            upcolor = (UIColor.ch_hex(0xF80D1F), true)
            downcolor = (UIColor.ch_hex(0x1E932B), true)
        } else {
            upcolor = (UIColor.ch_hex(0x1E932B), true)
            downcolor = (UIColor.ch_hex(0xF80D1F), true)
        }
        
        
        let priceSection = self.cusStyle.sections[0]
        
        
        if selectedStyle == 0 {
            
            //虚线颜色
            priceSection.yAxis.referenceStyle = .dash(color: UIColor(white: 0.2, alpha: 1), pattern: [5])
            
            /// 时分线
            let timelineSeries = CHSeries.getTimelinePrice(color: UIColor.ch_hex(0xDDDDDD), section: priceSection)
            timelineSeries.hidden = true
            
            /// 蜡烛线
            let priceSeries = CHSeries.getCandlePrice(upStyle: upcolor,
                                                      downStyle: downcolor,
                                                      titleColor: UIColor(white: 0.8, alpha: 1),
                                                      section: priceSection)
            
            let priceMASeries = CHSeries.getPriceMA(isEMA: false, num: [5,10,30],
                                               colors: [
                                                UIColor.ch_hex(0xDDDDDD),
                                                UIColor.ch_hex(0xF9EE30),
                                                UIColor.ch_hex(0xF600FF),
                                                ], section: priceSection)
            priceMASeries.hidden = false
            let priceEMASeries = CHSeries.getPriceMA(isEMA: true, num: [5,10,30],
                                                colors: [
                                                    UIColor.ch_hex(0xDDDDDD),
                                                    UIColor.ch_hex(0xF9EE30),
                                                    UIColor.ch_hex(0xF600FF),
                                                    ], section: priceSection)
            priceEMASeries.hidden = true
            priceSection.series = [timelineSeries, priceSeries, priceMASeries, priceEMASeries]
            
        } else {
            
            //虚线颜色
            priceSection.yAxis.referenceStyle = .dash(color: UIColor(white: 0.8, alpha: 1), pattern: [5])
            
            /// 时分线
            let timelineSeries = CHSeries.getTimelinePrice(color: UIColor(white: 0.5, alpha: 1), section: priceSection)
            timelineSeries.hidden = true
            
            /// 蜡烛线
            let priceSeries = CHSeries.getCandlePrice(upStyle: upcolor,
                                                      downStyle: downcolor,
                                                      titleColor: UIColor(white: 0.5, alpha: 1),
                                                      section: priceSection)
            
            let priceMASeries = CHSeries.getPriceMA(isEMA: false, num: [5,10,30],
                                               colors: [
                                                UIColor.ch_hex(0x4E9CC1),
                                                UIColor.ch_hex(0xF7A23B),
                                                UIColor.ch_hex(0xF600FF),
                                                ], section: priceSection)
            priceMASeries.hidden = false
            let priceEMASeries = CHSeries.getPriceMA(isEMA: true, num: [5,10,30],
                                                colors: [
                                                    UIColor.ch_hex(0x4E9CC1),
                                                    UIColor.ch_hex(0xF7A23B),
                                                    UIColor.ch_hex(0xF600FF),
                                                    ], section: priceSection)
            priceEMASeries.hidden = true
            priceSection.series = [timelineSeries, priceSeries, priceMASeries, priceEMASeries]
            
        }
        
    }
    
    
    /// 更换交易量分区的样式
    ///
    /// - Parameters:
    ///   - selectedStyle: 选择的样式
    ///   - selectedCandleColor: 选择的蜡烛颜色样式
    func changeVolumeSeries(selectedStyle: Int, selectedCandleColor: Int) {
        
        var upcolor: (color: UIColor, isSolid: Bool)
        var downcolor: (color: UIColor, isSolid: Bool)
        
        if selectedCandleColor == 0 {
            upcolor = (UIColor.ch_hex(0xF80D1F), true)
            downcolor = (UIColor.ch_hex(0x1E932B), true)
        } else {
            upcolor = (UIColor.ch_hex(0x1E932B), true)
            downcolor = (UIColor.ch_hex(0xF80D1F), true)
        }
        
        
        let volumeSection = self.cusStyle.sections[1]
        
        if selectedStyle == 0 {
            
            //虚线颜色
            volumeSection.yAxis.referenceStyle = .dash(color: UIColor(white: 0.2, alpha: 1), pattern: [5])
            
            let volumeSeries = CHSeries.getDefaultVolume(upStyle: upcolor, downStyle: downcolor, section: volumeSection)
            let volumeMASeries = CHSeries.getVolumeMA(isEMA: false, num: [5,10,30],
                                                colors: [
                                                    UIColor.ch_hex(0xDDDDDD),
                                                    UIColor.ch_hex(0xF9EE30),
                                                    UIColor.ch_hex(0xF600FF),
                                                    ], section: volumeSection)
            let volumeEMASeries = CHSeries.getVolumeMA(isEMA: true, num: [5,10,30],
                                                 colors: [
                                                    UIColor.ch_hex(0xDDDDDD),
                                                    UIColor.ch_hex(0xF9EE30),
                                                    UIColor.ch_hex(0xF600FF),
                                                    ], section: volumeSection)
            volumeEMASeries.hidden = true
            volumeSection.series = [volumeSeries, volumeMASeries, volumeEMASeries]
            
        } else {
            
            //虚线颜色
            volumeSection.yAxis.referenceStyle = .dash(color: UIColor(white: 0.8, alpha: 1), pattern: [5])
            
            let volumeSeries = CHSeries.getDefaultVolume(upStyle: upcolor, downStyle: downcolor, section: volumeSection)
            let volumeMASeries = CHSeries.getVolumeMA(isEMA: false, num: [5,10,30],
                                                colors: [
                                                    UIColor.ch_hex(0x4E9CC1),
                                                    UIColor.ch_hex(0xF7A23B),
                                                    UIColor.ch_hex(0xF600FF),
                                                    ], section: volumeSection)
            let volumeEMASeries = CHSeries.getVolumeMA(isEMA: true, num: [5,10,30],
                                                 colors: [
                                                    UIColor.ch_hex(0x4E9CC1),
                                                    UIColor.ch_hex(0xF7A23B),
                                                    UIColor.ch_hex(0xF600FF),
                                                    ], section: volumeSection)
            volumeEMASeries.hidden = true
            volumeSection.series = [volumeSeries, volumeMASeries, volumeEMASeries]
            
        }
        
    }
    
    
    /// 更换指标分区的样式
    ///
    /// - Parameters:
    ///   - selectedStyle: 选择的样式
    ///   - selectedCandleColor: 选择的蜡烛颜色样式
    func changeTrendSeries(selectedStyle: Int, selectedCandleColor: Int) {
        
        var upcolor: (color: UIColor, isSolid: Bool)
        var downcolor: (color: UIColor, isSolid: Bool)
        
        if selectedCandleColor == 0 {
            upcolor = (UIColor.ch_hex(0xF80D1F), true)
            downcolor = (UIColor.ch_hex(0x1E932B), true)
        } else {
            upcolor = (UIColor.ch_hex(0x1E932B), true)
            downcolor = (UIColor.ch_hex(0xF80D1F), true)
        }
        
        let trendSection = self.cusStyle.sections[2]
        
        if selectedStyle == 0 {
            
            //虚线颜色
            trendSection.yAxis.referenceStyle = .dash(color: UIColor(white: 0.2, alpha: 1), pattern: [5])
            
            let kdjSeries = CHSeries.getKDJ(UIColor.ch_hex(0xDDDDDD),
                                            dc: UIColor.ch_hex(0xF9EE30),
                                            jc: UIColor.ch_hex(0xF600FF),
                                            section: trendSection)
            kdjSeries.title = "KDJ(9,3,3)"
            
            let macdSeries = CHSeries.getMACD(UIColor.ch_hex(0xDDDDDD),
                                              deac: UIColor.ch_hex(0xF9EE30),
                                              barc: UIColor.ch_hex(0xF600FF),
                                              upStyle: upcolor, downStyle: downcolor,
                                              section: trendSection)
            macdSeries.title = "MACD(12,26,9)"
            macdSeries.symmetrical = true
            trendSection.series = [
                kdjSeries,
                macdSeries]
            
            trendSection.titleColor = UIColor(white: 0.8, alpha: 1)
            
        } else {
            
            //虚线颜色
            trendSection.yAxis.referenceStyle = .dash(color: UIColor(white: 0.8, alpha: 1), pattern: [5])
            
            let kdjSeries = CHSeries.getKDJ(UIColor.ch_hex(0x4E9CC1),
                                            dc: UIColor.ch_hex(0xF7A23B),
                                            jc: UIColor.ch_hex(0xF600FF),
                                            section: trendSection)
            kdjSeries.title = "KDJ(9,3,3)"
            
            let macdSeries = CHSeries.getMACD(UIColor.ch_hex(0x4E9CC1),
                                              deac: UIColor.ch_hex(0xF7A23B),
                                              barc: UIColor.ch_hex(0xF600FF),
                                              upStyle: upcolor, downStyle: downcolor,
                                              section: trendSection)
            macdSeries.title = "MACD(12,26,9)"
            macdSeries.symmetrical = true
            trendSection.series = [
                kdjSeries,
                macdSeries]
            
            trendSection.titleColor = UIColor(white: 0.5, alpha: 1)
        }
        
    }
    
    /// Y轴标签显示的方位设置
    ///
    /// - Parameter sender:
    @IBAction func handleYAxisSideChange(sender: UISegmentedControl) {
        
        let style = self.cusStyle
        
        if sender.selectedSegmentIndex == 0 {
            
            style.showYAxisLabel = .left
            
            style.padding = UIEdgeInsets(top: 16, left: 0, bottom: 20, right: 8)
            
        } else {
            
            style.showYAxisLabel = .right
            
            style.padding = UIEdgeInsets(top: 16, left: 8, bottom: 20, right: 0)
            
        }
        
        
    }
    
    
    /// 是否切换蜡烛柱颜色
    ///
    /// - Parameter sender:
    @IBAction func handleCandleColorChange(sender: UISegmentedControl) {
        
        //更换价格分区的样式
        self.changePriceSeries(selectedStyle: self.segThemeStyle.selectedSegmentIndex,
                               selectedCandleColor: sender.selectedSegmentIndex)
        
        //更换交易量分区的样式
        self.changeVolumeSeries(selectedStyle: self.segThemeStyle.selectedSegmentIndex,
                                selectedCandleColor: sender.selectedSegmentIndex)
        
        //更换指标分区的样式
        self.changeTrendSeries(selectedStyle: self.segThemeStyle.selectedSegmentIndex,
                               selectedCandleColor: sender.selectedSegmentIndex)
        
    }
    
    
    /// 是否允许点击
    ///
    /// - Parameter sender:
    @IBAction func handleEnableTouchChange(sender: UISwitch) {
        let style = self.cusStyle
        style.enableTap = sender.isOn
    }
    
    
    /// 开关是否显示数据
    ///
    /// - Parameter sender:
    @IBAction func handleEnableShowChange(sender: UISwitch) {
        for section in self.cusStyle.sections {
            section.showTitle = false
        }
    }
    
    
    /// 完成配置
    ///
    /// - Parameter sender:
    @IBAction func handleDoneButtonPress(sender: UIButton) {
        
        self.chartView?.resetStyle(style: self.cusStyle)
 
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
}
