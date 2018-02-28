//
//  ChartCustomViewController.swift
//  Example
//
//  Created by Chance on 2018/2/27.
//  Copyright © 2018年 Chance. All rights reserved.
//

import UIKit
import CHKLineChartKit

class ChartCustomViewController: UIViewController {
    
    /// 不显示
    static let Hide: String = "N/A"
    
    //选择时间
    let times: [String] = [
        "5min", "15min", "30min",
        "1hour", "2hour", "4hour",
        "1day", "1week"
    ]

    /// 主图线段
    let masterLine: [String] = [
        CHSeriesKey.candle, CHSeriesKey.timeline
    ]
    
    /// 主图指标
    let masterIndex: [String] = [
        CHSeriesKey.ma, CHSeriesKey.ema, CHSeriesKey.sar, CHSeriesKey.boll, CHSeriesKey.sam, Hide
    ]
    
    /// 副图指标
    let assistIndex: [String] = [
        CHSeriesKey.volume, CHSeriesKey.kdj, CHSeriesKey.macd, Hide
    ]
    
    //选择交易对
    let exPairs: [String] = [
        "btc_usdt", "eth_usdt", "ltc_usdt",
        "ltc_btc", "eth_btc", "etc_btc",
        ]
    
    /// 已选周期
    var selectedTime: Int = 0 {
        didSet {
            let time = self.times[self.selectedTime]
            self.buttonTime.setTitle(time, for: .normal)
        }
    }
    
    /// 已选主图线段
    var selectedMasterLine: Int = 0
    
    /// 已选主图指标
    var selectedMasterIndex: Int = 0
    
    /// 已选副图指标1
    var selectedAssistIndex: Int = 0
    
    /// 已选副图指标2
    var selectedAssistIndex2: Int = 0
    
    var selectedSymbol: String = ""
    
    /// 数据源
    var klineDatas = [KlineChartData]()
    
    /// 图表X轴的前一天，用于对比是否夸日
    var chartXAxisPrevDay: String = ""
    
    
    /// 图表
    lazy var chartView: CHKLineChartView = {
        let chartView = CHKLineChartView(frame: CGRect.zero)
        chartView.style = .myChart
        chartView.delegate = self
        return chartView
    }()
    
    /// 顶部数据
    lazy var topView: TickerTopView = {
        let view = TickerTopView(frame: CGRect.zero)
        return view
    }()
    
    /// 选择时间周期
    lazy var buttonTime: UIButton = {
        let btn = UIButton()
        btn.setTitleColor(.white, for: .normal)
        btn.addTarget(self, action: #selector(self.handleShowTimeSelection), for: .touchUpInside)
        return btn
    }()
    
    /// 股票指标
    lazy var buttonIndex: UIButton = {
        let btn = UIButton()
        btn.setTitle("指标", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.addTarget(self, action: #selector(self.handleShowIndex), for: .touchUpInside)
        return btn
    }()
    
    /// 指标设置
    lazy var buttonSetting: UIButton = {
        let btn = UIButton()
        btn.setTitle("参数", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        return btn
    }()
    
    /// 工具栏
    lazy var toolbar: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0x242731)
        return view
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.prepareChart()
        self.fetchChartDatas()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

// MARK: - 图表
extension ChartCustomViewController {
    
    /// 准备显示图标
    func prepareChart() {
        
        self.selectedTime = 0
        self.selectedMasterLine = 0
        self.selectedMasterIndex = 0
        self.selectedAssistIndex = 0
        self.selectedAssistIndex2 = 1
        self.selectedSymbol = self.exPairs[0]
        
//        if let serise = self.chartView.sections[0].getSeries(key: self.masterLine[self.selectedMasterLine]) {
//            serise.hidden = false
//        }
//        
//        self.chartView.sections[1].selectedIndex = self.selectedAssistIndex
//        self.chartView.sections[2].selectedIndex = self.selectedAssistIndex2
    }
    
    /// 拉取数据
    func fetchChartDatas() {
        ChartDatasFetcher.shared.getRemoteChartData(
            symbol: self.selectedSymbol,
            timeType: self.times[self.selectedTime],
            size: 1000) {
                [weak self](flag, chartsData) in
                if flag && chartsData.count > 0 {
                    self?.klineDatas = chartsData
                    self?.chartView.reloadData()
                    
                    //显示最后一条数据
                    self?.topView.update(data: chartsData.last!)
                }
        }
    }
    
    /// 配置UI
    func setupUI() {
        
        self.view.backgroundColor = UIColor(hex: 0x232732)
        self.view.addSubview(self.topView)
        self.view.addSubview(self.chartView)
        self.view.addSubview(self.toolbar)
        self.toolbar.addSubview(self.buttonIndex)
        self.toolbar.addSubview(self.buttonTime)
        self.toolbar.addSubview(self.buttonSetting)
        
        self.topView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(4)
            make.bottom.equalTo(self.chartView.snp.top).offset(-4)
            make.left.right.equalToSuperview().inset(8)
            make.height.equalTo(60)
        }
        
        self.chartView.snp.makeConstraints { (make) in
//            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            make.left.right.equalToSuperview()
        }
        
        self.toolbar.snp.makeConstraints { (make) in
            make.top.equalTo(self.chartView.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            make.height.equalTo(44)
        }
        
        self.buttonTime.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(8)
            make.width.equalTo(80)
            make.height.equalTo(30)
            make.centerY.equalToSuperview()
        }
        
        self.buttonSetting.snp.makeConstraints { (make) in
            make.right.equalToSuperview().inset(8)
            make.width.equalTo(80)
            make.height.equalTo(30)
            make.centerY.equalToSuperview()
        }
        
        self.buttonIndex.snp.makeConstraints { (make) in
            make.right.equalTo(self.buttonSetting.snp.left)
            make.width.equalTo(80)
            make.height.equalTo(30)
            make.centerY.equalToSuperview()
        }
    }
    
    /// 选择周期
    @objc func handleShowTimeSelection() {
        let view = SelectionPopView() {
            (vc, indexPath) in
            self.selectedTime = indexPath.row
            self.fetchChartDatas()
        }
        view.addItems(section: "周期选择", items: self.times, selectedIndex: self.selectedTime)
        view.show(from: self)
    }
    
    /// 选择指标
    @objc func handleShowIndex() {
        let view = SelectionPopView() {
            (vc, indexPath) in
            self.didSelectChartIndex(indexPath: indexPath)
        }
        view.addItems(section: "主图线", items: self.masterLine, selectedIndex: self.selectedMasterLine)
        view.addItems(section: "主图指标", items: self.masterIndex, selectedIndex: self.selectedMasterIndex)
        view.addItems(section: "副图指标1", items: self.assistIndex, selectedIndex: self.selectedAssistIndex)
        view.addItems(section: "副图指标2", items: self.assistIndex, selectedIndex: self.selectedAssistIndex2)
        view.show(from: self)
    }
    
    func didSelectChartIndex(indexPath: IndexPath) {
        
        switch indexPath.section {
        case 0:
            self.selectedMasterLine = indexPath.row
            let lineKey = self.masterLine[indexPath.row]
            let indexKey = self.masterIndex[self.selectedMasterIndex]
            
            self.chartView.setSerie(hidden: true, inSection: 0)
            self.chartView.setSerie(hidden: false, by: lineKey, inSection: 0)
            self.chartView.setSerie(hidden: false, by: indexKey, inSection: 0)
        case 1:
            self.selectedMasterIndex = indexPath.row
            let lineKey = self.masterLine[self.selectedMasterLine]
            let indexKey = self.masterIndex[indexPath.row]
            
            self.chartView.setSerie(hidden: true, inSection: 0)
            self.chartView.setSerie(hidden: false, by: lineKey, inSection: 0)
            
            if indexKey != ChartCustomViewController.Hide {
                self.chartView.setSerie(hidden: false, by: indexKey, inSection: 0)
            }
            
            
        case 2:
            self.selectedAssistIndex = indexPath.row
            let indexKey = self.assistIndex[indexPath.row]
            
            if indexKey == ChartCustomViewController.Hide {
                self.chartView.setSection(hidden: true, byIndex: 1)
            } else {
                self.chartView.setSection(hidden: false, byIndex: 1)
                self.chartView.setSerie(hidden: false, by: indexKey, inSection: 1)
            }
            self.chartView.setSerie(hidden: false, by: indexKey, inSection: 1)
        case 3:
            self.selectedAssistIndex2 = indexPath.row
            let indexKey = self.assistIndex[indexPath.row]
            
            if indexKey == ChartCustomViewController.Hide {
                self.chartView.setSection(hidden: true, byIndex: 2)
            } else {
                self.chartView.setSection(hidden: false, byIndex: 2)
                self.chartView.setSerie(hidden: false, by: indexKey, inSection: 2)
            }
        default: break
        }
        
    }
}

// MARK: - 实现K线图表的委托方法
extension ChartCustomViewController: CHKLineChartDelegate {
    
    func numberOfPointsInKLineChart(chart: CHKLineChartView) -> Int {
        return self.klineDatas.count
    }
    
    func kLineChart(chart: CHKLineChartView, valueForPointAtIndex index: Int) -> CHChartItem {
        let data = self.klineDatas[index]
        let item = CHChartItem()
        item.time = data.time / 1000
        item.openPrice = CGFloat(data.openPrice)
        item.highPrice = CGFloat(data.highPrice)
        item.lowPrice = CGFloat(data.lowPrice)
        item.closePrice = CGFloat(data.closePrice)
        item.vol = CGFloat(data.vol)
        return item
    }
    
    func kLineChart(chart: CHKLineChartView, labelOnYAxisForValue value: CGFloat, atIndex index: Int, section: CHSection) -> String {
        var strValue = ""
        if section.key == "volume" {
            if value / 1000 > 1 {
                strValue = (value / 1000).ch_toString(maxF: section.decimal) + "K"
            } else {
                strValue = value.ch_toString(maxF: section.decimal)
            }
        } else {
            strValue = value.ch_toString(maxF: section.decimal)
        }
        
        return strValue
    }
    
    func kLineChart(chart: CHKLineChartView, labelOnXAxisForIndex index: Int) -> String {
        let data = self.klineDatas[index]
        let timestamp = data.time / 1000
        let dayText = Date.ch_getTimeByStamp(timestamp, format: "MM-dd")
        let timeText = Date.ch_getTimeByStamp(timestamp, format: "HH:mm")
        var text = ""
        //跨日，显示日期
        if dayText != self.chartXAxisPrevDay && index > 0 {
            text = dayText
        } else {
            text = timeText
        }
        self.chartXAxisPrevDay = dayText
        return text
    }
    
    
    /// 调整每个分区的小数位保留数
    ///
    /// - parameter chart:
    /// - parameter section:
    ///
    /// - returns:
    func kLineChart(chart: CHKLineChartView, decimalAt section: Int) -> Int {
        return 4
    }
    
    
    /// 调整Y轴标签宽度
    ///
    /// - parameter chart:
    ///
    /// - returns:
    func widthForYAxisLabelInKLineChart(in chart: CHKLineChartView) -> CGFloat {
        return 65
    }
    
    
    
    /// 点击图标返回点击的位置和数据对象
    ///
    /// - Parameters:
    ///   - chart:
    ///   - index:
    ///   - item:
    func kLineChart(chart: CHKLineChartView, didSelectAt index: Int, item: CHChartItem) {
//        NSLog("selected index = \(index)")
    }
    
}

// MARK: - 竖屏切换重载方法实现
extension ChartCustomViewController {
    
    
    override func willAnimateRotation(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        if toInterfaceOrientation.isPortrait {
            //竖屏时，交易量的y轴只以4间断显示
            self.chartView.sections[1].yAxis.tickInterval = 3
            self.chartView.sections[2].yAxis.tickInterval = 3
        } else {
            //竖屏时，交易量的y轴只以2间断显示
            self.chartView.sections[1].yAxis.tickInterval = 1
            self.chartView.sections[2].yAxis.tickInterval = 1
        }
        self.chartView.reloadData()
    }
    
}

// MARK: - 扩展样式
public extension CHKLineChartStyle {
    
    //实现一个最基本的样式，开发者可以自由扩展配置样式
    public static var myChart: CHKLineChartStyle {
        let style = CHKLineChartStyle()
        style.labelFont = UIFont.systemFont(ofSize: 10)
        style.lineColor = UIColor(white: 0.2, alpha: 1)
        style.textColor = UIColor(white: 0.8, alpha: 1)
        style.selectedBGColor = UIColor(white: 0.4, alpha: 1)
        style.selectedTextColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        style.padding = UIEdgeInsets(top: 32, left: 8, bottom: 4, right: 0)
        style.backgroundColor = UIColor(hex: 0x232732)
        style.showYAxisLabel = .right
        
        //配置图表处理算法
        style.algorithms = [
            CHChartAlgorithm.timeline,
            CHChartAlgorithm.sar(4, 0.02, 0.2), //默认周期4，最小加速0.02，最大加速0.2
            CHChartAlgorithm.ma(5),
            CHChartAlgorithm.ma(10),
            CHChartAlgorithm.ma(20),        //计算BOLL，必须先计算到同周期的MA
            CHChartAlgorithm.ma(30),
            CHChartAlgorithm.ema(5),
            CHChartAlgorithm.ema(10),
            CHChartAlgorithm.ema(12),       //计算MACD，必须先计算到同周期的EMA
            CHChartAlgorithm.ema(26),       //计算MACD，必须先计算到同周期的EMA
            CHChartAlgorithm.ema(30),
            CHChartAlgorithm.boll(20, 2),
            CHChartAlgorithm.macd(12, 26, 9),
            CHChartAlgorithm.kdj(9, 3, 3),
            CHChartAlgorithm.sam(60),
        ]
        
        //分区点线样式
        let upcolor = (UIColor.ch_hex(0x00bd9a), true)
        let downcolor = (UIColor.ch_hex(0xff6960), true)
        let priceSection = CHSection()
        priceSection.backgroundColor = style.backgroundColor
        priceSection.titleShowOutSide = true
        priceSection.valueType = .master
        priceSection.key = "master"
        priceSection.hidden = false
        priceSection.ratios = 3
        priceSection.padding = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        
        /// 时分线
        let timelineSeries = CHSeries.getTimelinePrice(
            color: UIColor.ch_hex(0xAE475C),
            section: priceSection,
            showGuide: true,
            ultimateValueStyle: .circle(UIColor.ch_hex(0xAE475C), true),
            lineWidth: 2)
        
        timelineSeries.hidden = true
        
        /// 蜡烛线
        let priceSeries = CHSeries.getCandlePrice(
            upStyle: upcolor,
            downStyle: downcolor,
            titleColor: UIColor(white: 0.8, alpha: 1),
            section: priceSection,
            showGuide: true,
            ultimateValueStyle: .arrow(UIColor(white: 0.8, alpha: 1)))
        
        priceSeries.showTitle = true
        
        priceSeries.chartModels.first?.ultimateValueStyle = .arrow(UIColor(white: 0.8, alpha: 1))
        
        let priceMASeries = CHSeries.getPriceMA(
            isEMA: false,
            num: [5,10,30],
            colors: [
                UIColor.ch_hex(0xDDDDDD),
                UIColor.ch_hex(0xF9EE30),
                UIColor.ch_hex(0xF600FF),
                ],
            section: priceSection)
        priceMASeries.hidden = false
        
        let priceEMASeries = CHSeries.getPriceMA(
            isEMA: true,
            num: [5,10,30],
            colors: [
                UIColor.ch_hex(0xDDDDDD),
                UIColor.ch_hex(0xF9EE30),
                UIColor.ch_hex(0xF600FF),
                ],
            section: priceSection)
        
        priceEMASeries.hidden = true
        
        let priceBOLLSeries = CHSeries.getBOLL(
            UIColor.ch_hex(0xDDDDDD),
            ubc: UIColor.ch_hex(0xF9EE30),
            lbc: UIColor.ch_hex(0xF600FF),
            section: priceSection)
        
        priceBOLLSeries.hidden = true
        
        let priceSARSeries = CHSeries.getSAR(
            upStyle: upcolor,
            downStyle: downcolor,
            titleColor: UIColor.ch_hex(0xDDDDDD),
            section: priceSection)
        
        priceSARSeries.hidden = true
        
        let priceSAMSeries = CHSeries.getPriceSAM(num: 60, barStyle: (UIColor.yellow, false), lineColor: UIColor(white: 0.4, alpha: 1), section: priceSection)
        
        priceSAMSeries.hidden = true
        
        priceSection.series = [
            timelineSeries,
            priceSeries,
            priceMASeries,
            priceEMASeries,
            priceBOLLSeries,
            priceSARSeries,
            priceSAMSeries,
        ]
        
        
        let assistSection = style.assistSection
        let assistSection2 = style.assistSection
        
        style.sections = [priceSection, assistSection, assistSection2]
        
        
        return style
    }
    
    var assistSection: CHSection {
        
        //分区点线样式
        let upcolor = (UIColor.ch_hex(0x00bd9a), true)
        let downcolor = (UIColor.ch_hex(0xff6960), true)
        
        let assistSection = CHSection()
        assistSection.backgroundColor = self.backgroundColor
        assistSection.valueType = .assistant
        assistSection.key = "analysis"
        assistSection.hidden = false
        assistSection.ratios = 1
        assistSection.paging = true
        assistSection.yAxis.tickInterval = 4
        assistSection.padding = UIEdgeInsets(top: 16, left: 0, bottom: 8, right: 0)
        
        let volSeries = CHSeries.getVolumeWithMA(upStyle: upcolor,
                                                 downStyle: downcolor,
                                                 isEMA: false,
                                                 num: [5,10,30],
                                                 colors: [
                                                    UIColor.ch_hex(0xDDDDDD),
                                                    UIColor.ch_hex(0xF9EE30),
                                                    UIColor.ch_hex(0xF600FF),
                                                    ],
                                                 section: assistSection)
        
        let kdjSeries = CHSeries.getKDJ(
            UIColor.ch_hex(0xDDDDDD),
            dc: UIColor.ch_hex(0xF9EE30),
            jc: UIColor.ch_hex(0xF600FF),
            section: assistSection)
        kdjSeries.title = "KDJ(9,3,3)"
        
        let macdSeries = CHSeries.getMACD(
            UIColor.ch_hex(0xDDDDDD),
            deac: UIColor.ch_hex(0xF9EE30),
            barc: UIColor.ch_hex(0xF600FF),
            upStyle: upcolor, downStyle: downcolor,
            section: assistSection)
        macdSeries.title = "MACD(12,26,9)"
        macdSeries.symmetrical = true
        assistSection.series = [
            volSeries,
            kdjSeries,
            macdSeries]
        
        return assistSection
    }
}
