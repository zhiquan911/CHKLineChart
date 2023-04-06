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
    static let Hide: String = ""
    
    //选择时间
    let times: [String] = [
        "5m", "15m", "1H", "6H","1D",
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
        CHSeriesKey.volume, CHSeriesKey.sam, CHSeriesKey.kdj, CHSeriesKey.macd, CHSeriesKey.rsi, Hide
    ]
    
    //选择交易对
    let exPairs: [String] = [
        "BTC-USD", "ETH-USD", "LTC-USD",
        "LTC-BTC", "ETH-BTC", "BCH-BTC",
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
    
    /// 选择的风格
    var selectedTheme: Int = 0
    
    /// y轴显示方向
    var selectedYAxisSide: Int = 1
    
    /// 蜡烛柱颜色
    var selectedCandleColor: Int = 1
    
    var selectedSymbol: Int = 0
    
    /// 数据源
    var klineDatas = [KlineChartData]()
    
    /// 图表X轴的前一天，用于对比是否夸日
    var chartXAxisPrevDay: String = ""
    
    
    /// 图表
    lazy var chartView: CHKLineChartView = {
        let chartView = CHKLineChartView(frame: CGRect.zero)
        chartView.style = self.loadUserStyle()
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
        btn.setTitleColor(UIColor(hex: 0xfe9d25), for: .normal)
        btn.addTarget(self, action: #selector(self.handleShowTimeSelection), for: .touchUpInside)
        return btn
    }()
    
    /// 股票指标
    lazy var buttonIndex: UIButton = {
        let btn = UIButton()
        btn.setTitle("Index", for: .normal)
        btn.setTitleColor(UIColor(hex: 0xfe9d25), for: .normal)
        btn.addTarget(self, action: #selector(self.handleShowIndex), for: .touchUpInside)
        return btn
    }()
    
    /// 指标设置
    lazy var buttonSetting: UIButton = {
        let btn = UIButton()
        btn.setTitle("Params", for: .normal)
        btn.setTitleColor(UIColor(hex: 0xfe9d25), for: .normal)
        btn.addTarget(self, action: #selector(self.gotoSettingList), for: .touchUpInside)
        return btn
    }()
    
    /// 风格设置
    lazy var buttonStyle: UIButton = {
        let btn = UIButton()
        btn.setTitle("Style", for: .normal)
        btn.setTitleColor(UIColor(hex: 0xfe9d25), for: .normal)
        btn.addTarget(self, action: #selector(self.gotoStyleSetting), for: .touchUpInside)
        return btn
    }()
    
    /// 市场设置
    lazy var buttonMarket: UIButton = {
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 70, height: 40))
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        btn.setTitleColor(UIColor(hex: 0xfe9d25), for: .normal)
        btn.addTarget(self, action: #selector(self.handleTitlePress(_:)), for: .touchUpInside)
        return btn
    }()
    
    /// 工具栏
    lazy var toolbar: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0x242731)
        return view
    }()
    
    ///周期弹出窗
    lazy var selectionViewForTime: SelectionPopView = {
        let view = SelectionPopView() {
            (vc, indexPath) in
            self.selectedTime = indexPath.row
            self.fetchChartDatas()
        }
        return view
    }()
    
    ///市场弹出窗
    lazy var selectionViewForMarket: SelectionPopView = {
        let view = SelectionPopView() {
            (vc, indexPath) in
            let symbol = self.exPairs[indexPath.row]
            self.selectedSymbol = indexPath.row
            self.buttonMarket.setTitle(symbol + "📈", for: .normal)
            self.fetchChartDatas()
        }
        return view
    }()
    
    ///指标弹出窗
    lazy var selectionViewForIndex: SelectionPopView = {
        let view = SelectionPopView() {
            (vc, indexPath) in
            self.didSelectChartIndex(indexPath: indexPath)
        }
        return view
    }()
    
    lazy var loadingView: UIActivityIndicatorView = {
        let v = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        
        self.selectedTime = 0
        self.selectedMasterLine = 0
        self.selectedMasterIndex = 0
        self.selectedAssistIndex = 0
        self.selectedAssistIndex2 = 2
        self.selectedSymbol = 0
        let symbol = self.exPairs[self.selectedSymbol]
        self.buttonMarket.setTitle(symbol + "📈", for: .normal)
        self.handleChartIndexChanged()
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
    
    /// 拉取数据
    func fetchChartDatas() {
        self.loadingView.startAnimating()
        self.loadingView.isHidden = false
        let symbol = self.exPairs[self.selectedSymbol]
        ChartDatasFetcher.shared.getRemoteChartData(
            symbol: symbol,
            timeType: self.times[self.selectedTime],
            size: 300) {
                [weak self](flag, chartsData) in
                if flag && chartsData.count > 0 {
                    self?.klineDatas = chartsData
                    self?.chartView.reloadData()
                    
                    //显示最后一条数据
                    self?.topView.update(data: chartsData.last!)
                    
                    self?.loadingView.stopAnimating()
                    self?.loadingView.isHidden = true
                }
        }
    }
    
    /// 配置UI
    func setupUI() {
        
        self.view.backgroundColor = UIColor(hex: 0x232732)
        self.navigationItem.titleView = self.buttonMarket
        self.view.addSubview(self.topView)
        self.view.addSubview(self.chartView)
        self.view.addSubview(self.toolbar)
        self.view.addSubview(self.loadingView)
        self.toolbar.addSubview(self.buttonIndex)
        self.toolbar.addSubview(self.buttonTime)
        self.toolbar.addSubview(self.buttonSetting)
        self.toolbar.addSubview(self.buttonStyle)
        
        self.loadingView.snp.makeConstraints { (make) in
            make.center.equalTo(self.chartView)
        }
        
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
        
        self.buttonIndex.snp.makeConstraints { (make) in
            make.left.equalTo(self.buttonTime.snp.right)
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
        
        self.buttonStyle.snp.makeConstraints { (make) in
            make.right.equalTo(self.buttonSetting.snp.left)
            make.width.equalTo(80)
            make.height.equalTo(30)
            make.centerY.equalToSuperview()
        }
        
    }
    
    /// 选择周期
    @objc func handleShowTimeSelection() {
        let view = self.selectionViewForTime
        view.clear()
        view.addItems(section: "Time", items: self.times, selectedIndex: self.selectedTime)
        view.show(from: self)
    }
    
    /// 选择指标
    @objc func handleShowIndex() {
        let view = self.selectionViewForIndex
        view.clear()
        view.addItems(section: "Chart Line", items: self.masterLine, selectedIndex: self.selectedMasterLine)
        view.addItems(section: "Master Index", items: self.masterIndex, selectedIndex: self.selectedMasterIndex)
        view.addItems(section: "Assist Index 1", items: self.assistIndex, selectedIndex: self.selectedAssistIndex)
        view.addItems(section: "Assist Index 2", items: self.assistIndex, selectedIndex: self.selectedAssistIndex2)
        view.show(from: self)
    }
    
    func didSelectChartIndex(indexPath: IndexPath) {
        
        switch indexPath.section {
        case 0:
            self.selectedMasterLine = indexPath.row
        case 1:
            self.selectedMasterIndex = indexPath.row
        case 2:
            self.selectedAssistIndex = indexPath.row
        case 3:
            self.selectedAssistIndex2 = indexPath.row
        default: break
        }
        
        //重新渲染
        self.handleChartIndexChanged()
    }
    
    /// 处理指标的变更
    func handleChartIndexChanged() {
        
        let lineKey = self.masterLine[self.selectedMasterLine]
        let masterKey = self.masterIndex[self.selectedMasterIndex]
        let assistKey = self.assistIndex[self.selectedAssistIndex]
        let assist2Key = self.assistIndex[self.selectedAssistIndex2]
        
        self.chartView.setSection(hidden: assistKey == ChartCustomViewController.Hide, byIndex: 1)
        self.chartView.setSection(hidden: assist2Key == ChartCustomViewController.Hide, byIndex: 2)
        
        //先隐藏所有线段
        self.chartView.setSerie(hidden: true, inSection: 0)
        self.chartView.setSerie(hidden: true, inSection: 1)
        self.chartView.setSerie(hidden: true, inSection: 2)
        
        //显示当前选中的线段
        self.chartView.setSerie(hidden: false, by: masterKey, inSection: 0)
        self.chartView.setSerie(hidden: false, by: assistKey, inSection: 1)
        self.chartView.setSerie(hidden: false, by: assist2Key, inSection: 2)
        self.chartView.setSerie(hidden: false, by: lineKey, inSection: 0)
        
        //重新渲染
        self.chartView.reloadData(resetData: false)
    }
    
    /// 进入参数设置
    @objc func gotoSettingList() {
        let vc = SettingListViewController()
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    /// 更新指标算法和样式风格
    func updateUserStyle() {
        self.chartView.resetStyle(style: self.loadUserStyle())
        self.handleChartIndexChanged()
    }
    
    @objc func gotoStyleSetting() {
        let vc = ChartStyleSettingViewController()
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func handleTitlePress(_ sender: Any) {
        let view = self.selectionViewForMarket
        view.clear()
        view.addItems(section: "Markets", items: self.exPairs, selectedIndex: self.selectedSymbol)
        view.show(from: self)
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
        item.time = data.time
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
        let timestamp = data.time
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
        if section == 0 {
            return 4
        } else {
            return 2
        }
        
    }
    
    
    /// 调整Y轴标签宽度
    ///
    /// - parameter chart:
    ///
    /// - returns:
    func widthForYAxisLabelInKLineChart(in chart: CHKLineChartView) -> CGFloat {
        return 60
    }
    
    /// 自定义分区图标题
    ///
    func kLineChart(chart: CHKLineChartView, titleForHeaderInSection section: CHSection, index: Int, item: CHChartItem) -> NSAttributedString? {
        var start = 0
        let titleString = NSMutableAttributedString()
        var key = ""
        switch section.index {
        case 0:
            key = self.masterIndex[self.selectedMasterIndex]
        default:
            key = section.series[section.selectedIndex].key
        }
        
        //获取该线段的标题值及颜色，可以继续自定义
        guard let attributes = section.getTitleAttributesByIndex(index, seriesKey: key) else {
            return nil
        }
        
        //合并为完整字符串
        for (title, color) in attributes {
            titleString.append(NSAttributedString(string: title))
            let range = NSMakeRange(start, title.ch_length)
            let colorAttribute = [NSAttributedStringKey.foregroundColor: color]
            titleString.addAttributes(colorAttribute, range: range)
            start += title.ch_length
        }
        
        return titleString
    }
    
    /// 点击图标返回点击的位置和数据对象
    ///
    /// - Parameters:
    ///   - chart:
    ///   - index:
    ///   - item:
    func kLineChart(chart: CHKLineChartView, didSelectAt index: Int, item: CHChartItem) {
        let data = self.klineDatas[index]
        self.topView.update(data: data)
    }
    
    /// 切换可分页分区的线组
    ///
    func kLineChart(chart: CHKLineChartView, didFlipPageSeries section: CHSection, series: CHSeries, seriesIndex: Int) {
        switch section.index {
        case 1:
            self.selectedAssistIndex = self.assistIndex.index(of: series.key) ?? self.selectedAssistIndex
        case 2:
            self.selectedAssistIndex2 = self.assistIndex.index(of: series.key) ?? self.selectedAssistIndex2
        default:break
        }
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

// MARK: - 自定义样式
extension ChartCustomViewController {
    
    /// 读取用户自定义样式
    ///
    /// - Returns:
    func loadUserStyle() -> CHKLineChartStyle {
        
        let seriesParams = SeriesParamList.shared.loadUserData()
        let styleParam = StyleParam.shared
        
        let style = CHKLineChartStyle()
        style.labelFont = UIFont.systemFont(ofSize: 10)
        style.lineColor = UIColor(hex: styleParam.lineColor)
        style.textColor = UIColor(hex: styleParam.textColor)
        style.selectedBGColor = UIColor(white: 0.4, alpha: 1)
        style.selectedTextColor = UIColor(hex: styleParam.selectedTextColor)
        style.backgroundColor = UIColor(hex: styleParam.backgroundColor)
        style.isInnerYAxis = styleParam.isInnerYAxis
        
        if styleParam.showYAxisLabel == "Left" {
            style.showYAxisLabel = .left
            style.padding = UIEdgeInsets(top: 16, left: 0, bottom: 4, right: 8)
            
        } else {
            style.showYAxisLabel = .right
            style.padding = UIEdgeInsets(top: 16, left: 8, bottom: 4, right: 0)
            
        }
    
        style.algorithms.append(CHChartAlgorithm.timeline)
        
        /************** 配置分区样式 **************/
        
        /// 主图
        let upcolor = (UIColor.ch_hex(styleParam.upColor), true)
        let downcolor = (UIColor.ch_hex(styleParam.downColor), true)
        let priceSection = CHSection()
        priceSection.backgroundColor = style.backgroundColor
        priceSection.titleShowOutSide = true
        priceSection.valueType = .master
        priceSection.key = "master"
        priceSection.hidden = false
        priceSection.ratios = 3
        priceSection.padding = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        
        
        /// 副图1
        let assistSection1 = CHSection()
        assistSection1.backgroundColor = style.backgroundColor
        assistSection1.valueType = .assistant
        assistSection1.key = "assist1"
        assistSection1.hidden = false
        assistSection1.ratios = 1
        assistSection1.paging = true
        assistSection1.yAxis.tickInterval = 4
        assistSection1.padding = UIEdgeInsets(top: 16, left: 0, bottom: 8, right: 0)
        
        /// 副图2
        let assistSection2 = CHSection()
        assistSection2.backgroundColor = style.backgroundColor
        assistSection2.valueType = .assistant
        assistSection2.key = "assist2"
        assistSection2.hidden = false
        assistSection2.ratios = 1
        assistSection2.paging = true
        assistSection2.yAxis.tickInterval = 4
        assistSection2.padding = UIEdgeInsets(top: 16, left: 0, bottom: 8, right: 0)
        
        /************** 添加主图固定的线段 **************/
        
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
        
        priceSection.series.append(timelineSeries)
        priceSection.series.append(priceSeries)
        
        /************** 读取用户配置中线段 **************/
        
        for series in seriesParams {
            
            if series.hidden {
                continue
            }
            
            //添加指标算法
            style.algorithms.append(contentsOf: series.getAlgorithms())
            
            //添加指标线段
            series.appendIn(masterSection: priceSection, assistSections: assistSection1, assistSection2)
        }
        
        style.sections.append(priceSection)
        if assistSection1.series.count > 0 {
            style.sections.append(assistSection1)
        }
        
        if assistSection2.series.count > 0 {
            style.sections.append(assistSection2)
        }
        
        /************** 同时设置图表外的样式背景 **************/
        self.view.backgroundColor = UIColor(hex: styleParam.backgroundColor)
        self.topView.backgroundColor = UIColor(hex: styleParam.backgroundColor)
        self.toolbar.backgroundColor = UIColor(hex: styleParam.backgroundColor)
        
        return style
    }
}

extension ChartCustomViewController: SettingListViewDelegate {
    
    func didCompletedParamsSetting() {
        self.updateUserStyle()
    }
}

extension ChartCustomViewController: ChartStyleSettingViewDelegate {
    
    func didChartStyleChanged(styleParam: StyleParam) {
        self.updateUserStyle()
    }
}

