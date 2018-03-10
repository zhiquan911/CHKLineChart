//
//  ChartStyleSettingViewController.swift
//  Example
//
//  Created by Chance on 2018/3/6.
//  Copyright © 2018年 Chance. All rights reserved.
//

import UIKit

@objc protocol ChartStyleSettingViewDelegate {
    
    @objc optional func didChartStyleChanged(styleParam: StyleParam)
}

class ChartStyleSettingViewController: UIViewController {
    
    var rowHeight: CGFloat {
        return 44
    }
    
    var rowCount: Int {
        return 4
    }
    
    lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        return view
    }()
    
    lazy var tableStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.distribution = .fillEqually
        s.spacing = 0
        s.alignment = .fill
        return s
    }()
    
    lazy var labelTheme: UILabel = {
        let view = UILabel()
        view.text = "Theme Style"
        
        return view
    }()
    
    var themes: [String] {
        return [
            "Dark",
            "Light"
        ]
    }
    
    lazy var segmentTheme: UISegmentedControl = {
        let view = UISegmentedControl()
        view.insertSegment(withTitle: self.themes[0], at: 0, animated: true)
        view.insertSegment(withTitle: self.themes[1], at: 1, animated: true)
        return view
    }()
    
    lazy var labelYAxisSide: UILabel = {
        let view = UILabel()
        view.text = "YAxis Side"
        
        return view
    }()
    
    var yAxisSides: [String] {
        return [
            "Left",
            "Right"
        ]
    }
    
    lazy var segmentYAxisSide: UISegmentedControl = {
        let view = UISegmentedControl()
        view.insertSegment(withTitle: self.yAxisSides[0], at: 0, animated: true)
        view.insertSegment(withTitle: self.yAxisSides[1], at: 1, animated: true)
        return view
    }()
    
    lazy var labelCandleColor: UILabel = {
        let view = UILabel()
        view.text = "Candle Color"
        return view
    }()
    
    var candleColors: [String] {
        return [
            "Red/Green",
            "Green/Red"
        ]
    }
    
    lazy var segmentCandleColor: UISegmentedControl = {
        let view = UISegmentedControl()
        view.insertSegment(withTitle: self.candleColors[0], at: 0, animated: true)
        view.insertSegment(withTitle: self.candleColors[1], at: 1, animated: true)
        return view
    }()
    
    lazy var labelInnerYAxis: UILabel = {
        let view = UILabel()
        view.text = "Inner YAxis"
        
        return view
    }()
    
    lazy var switchInnerYAxis: UISwitch = {
        let view = UISwitch()
        return view
    }()
    
    
    
    var selectedTheme: Int = 0
    
    var selectedYAxisSide: Int = 1
    
    var selectedCandleColor: Int = 1
    
    var delegate: ChartStyleSettingViewDelegate?

    var styleParam = StyleParam.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        
        self.segmentTheme.selectedSegmentIndex = self.themes.index(of: self.styleParam.theme) ?? self.selectedTheme
        self.segmentYAxisSide.selectedSegmentIndex = self.yAxisSides.index(of: self.styleParam.showYAxisLabel) ?? self.selectedYAxisSide
        self.segmentCandleColor.selectedSegmentIndex = self.candleColors.index(of: self.styleParam.candleColors) ?? self.selectedCandleColor
        self.switchInnerYAxis.isOn = self.styleParam.isInnerYAxis
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.saveStyle()
        self.delegate?.didChartStyleChanged?(styleParam: self.styleParam)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ChartStyleSettingViewController {
    
    func setupUI() {
        self.view.backgroundColor = .white
        self.view.addSubview(self.scrollView)
        
        let row1 = UIStackView()
        row1.axis = .horizontal
        row1.distribution = .equalSpacing
        row1.spacing = 0
        row1.alignment = .center
        
        row1.addArrangedSubview(self.labelTheme)
        row1.addArrangedSubview(self.segmentTheme)
        
        let row2 = UIStackView()
        row2.axis = .horizontal
        row2.distribution = .equalSpacing
        row2.spacing = 0
        row2.alignment = .center
        
        row2.addArrangedSubview(self.labelYAxisSide)
        row2.addArrangedSubview(self.segmentYAxisSide)
        
        let row3 = UIStackView()
        row3.axis = .horizontal
        row3.distribution = .equalSpacing
        row3.spacing = 0
        row3.alignment = .center
        
        row3.addArrangedSubview(self.labelCandleColor)
        row3.addArrangedSubview(self.segmentCandleColor)
        
        let row4 = UIStackView()
        row4.axis = .horizontal
        row4.distribution = .equalSpacing
        row4.spacing = 0
        row4.alignment = .center
        
        row4.addArrangedSubview(self.labelInnerYAxis)
        row4.addArrangedSubview(self.switchInnerYAxis)
        
        self.tableStack.addArrangedSubview(row1)
        self.tableStack.addArrangedSubview(row2)
        self.tableStack.addArrangedSubview(row3)
        self.tableStack.addArrangedSubview(row4)
        
        self.scrollView.addSubview(self.tableStack)
        
        self.scrollView.snp.makeConstraints { (make) in
            make.top.bottom.right.left.equalToSuperview()
        }
        
        self.tableStack.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(CGFloat(self.rowCount) * self.rowHeight)
            make.width.equalTo(self.view.snp.width).multipliedBy(0.9)
        }
    }
    
    /// 保存已选风格
    func saveStyle() {
        let theme = self.themes[self.segmentTheme.selectedSegmentIndex]
        let yAxisSide = self.yAxisSides[self.segmentYAxisSide.selectedSegmentIndex]
        let candleColors = self.candleColors[self.segmentCandleColor.selectedSegmentIndex]
        
        self.styleParam.theme = theme
        self.styleParam.candleColors = candleColors
        self.styleParam.showYAxisLabel = yAxisSide
        self.styleParam.isInnerYAxis = self.switchInnerYAxis.isOn
        
        var upcolor: UInt, downcolor: UInt
        var lineColors: [UInt]
        
        if theme == "Dark" {
            self.styleParam.backgroundColor = 0x232732
            self.styleParam.textColor = 0xcccccc
            self.styleParam.selectedTextColor = 0xcccccc
            self.styleParam.lineColor = 0x333333
            upcolor = 0x00bd9a
            downcolor = 0xff6960
            lineColors = [
                0xDDDDDD,
                0xF9EE30,
                0xF600FF,
            ]
        } else {
            self.styleParam.backgroundColor = 0xffffff
            self.styleParam.textColor = 0x808080
            self.styleParam.selectedTextColor = 0xcccccc
            self.styleParam.lineColor = 0xcccccc
            upcolor = 0x1E932B
            downcolor = 0xF80D1F
            lineColors = [
                0x4E9CC1,
                0xF7A23B,
                0xF600FF,
            ]
        }
        
        if self.segmentCandleColor.selectedSegmentIndex == 0 {
            self.styleParam.upColor = downcolor
            self.styleParam.downColor = upcolor
        } else {
            self.styleParam.upColor = upcolor
            self.styleParam.downColor = downcolor
        }
        
        self.styleParam.lineColors = lineColors
        _ = self.styleParam.saveUserData()
    }
}
