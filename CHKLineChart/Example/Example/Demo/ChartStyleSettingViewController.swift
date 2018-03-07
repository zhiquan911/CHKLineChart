//
//  ChartStyleSettingViewController.swift
//  Example
//
//  Created by Chance on 2018/3/6.
//  Copyright © 2018年 Chance. All rights reserved.
//

import UIKit

@objc protocol ChartStyleSettingViewDelegate {
    
    @objc optional func didChartStyleChanged(theme: Int, yAxisSide: Int, candleColor: Int)
}

class ChartStyleSettingViewController: UIViewController {
    
    var rowHeight: CGFloat {
        return 44
    }
    
    var rowCount: Int {
        return 3
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
    
    lazy var segmentTheme: UISegmentedControl = {
        let view = UISegmentedControl()
        view.insertSegment(withTitle: "Dark", at: 0, animated: true)
        view.insertSegment(withTitle: "Light", at: 1, animated: true)
        return view
    }()
    
    lazy var labelYAxisSide: UILabel = {
        let view = UILabel()
        view.text = "YAxis Side"
        
        return view
    }()
    
    lazy var segmentYAxisSide: UISegmentedControl = {
        let view = UISegmentedControl()
        view.insertSegment(withTitle: "Left", at: 0, animated: true)
        view.insertSegment(withTitle: "Right", at: 1, animated: true)
        return view
    }()
    
    lazy var labelCandleColor: UILabel = {
        let view = UILabel()
        view.text = "Candle Color"
        return view
    }()
    
    lazy var segmentCandleColor: UISegmentedControl = {
        let view = UISegmentedControl()
        view.insertSegment(withTitle: "Red/Green", at: 0, animated: true)
        view.insertSegment(withTitle: "Green/Red", at: 1, animated: true)
        return view
    }()
    
    var selectedTheme: Int = 0
    
    var selectedYAxisSide: Int = 1
    
    var selectedCandleColor: Int = 1
    
    var delegate: ChartStyleSettingViewDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.segmentTheme.selectedSegmentIndex = self.selectedTheme
        self.segmentYAxisSide.selectedSegmentIndex = self.selectedYAxisSide
        self.segmentCandleColor.selectedSegmentIndex = self.selectedCandleColor
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.delegate?.didChartStyleChanged?(theme: self.selectedTheme, yAxisSide: self.selectedYAxisSide, candleColor: self.selectedCandleColor)
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
        row1.distribution = .fillEqually
        row1.spacing = 0
        row1.alignment = .center
        
        row1.addArrangedSubview(self.labelTheme)
        row1.addArrangedSubview(self.segmentTheme)
        
        let row2 = UIStackView()
        row2.axis = .horizontal
        row2.distribution = .fillEqually
        row2.spacing = 0
        row2.alignment = .center
        
        row2.addArrangedSubview(self.labelYAxisSide)
        row2.addArrangedSubview(self.segmentYAxisSide)
        
        let row3 = UIStackView()
        row3.axis = .horizontal
        row3.distribution = .fillEqually
        row3.spacing = 0
        row3.alignment = .center
        
        row3.addArrangedSubview(self.labelCandleColor)
        row3.addArrangedSubview(self.segmentCandleColor)
        
        self.tableStack.addArrangedSubview(row1)
        self.tableStack.addArrangedSubview(row2)
        self.tableStack.addArrangedSubview(row3)
        
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
}
