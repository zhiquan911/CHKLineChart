//
//  TickerTopView.swift
//  Example
//
//  Created by Chance on 2018/2/27.
//  Copyright © 2018年 Chance. All rights reserved.
//

import UIKit
import CHKLineChartKit

class TickerTopView: UIView {

    /// 价格
    lazy var labelPrice: UILabel = {
        let view = UILabel()
        view.textColor = UIColor(hex: 0x00bd9a)
        view.font = UIFont.systemFont(ofSize: 26)
        return view
    }()

    /// 涨跌
    lazy var labelRise: UILabel = {
        let view = UILabel()
        view.textColor = UIColor(hex: 0xfe9d25)
        view.font = UIFont.systemFont(ofSize: 12)
        return view
    }()
    
    /// 开盘
    lazy var labelOpen: UILabel = {
        let view = UILabel()
        view.textColor = UIColor(hex: 0xfe9d25)
        view.font = UIFont.systemFont(ofSize: 12)
        return view
    }()
    
    /// 最高
    lazy var labelHigh: UILabel = {
        let view = UILabel()
        view.textColor = UIColor(hex: 0xfe9d25)
        view.font = UIFont.systemFont(ofSize: 12)
        return view
    }()
    
    /// 收盘
    lazy var labelClose: UILabel = {
        let view = UILabel()
        view.textColor = UIColor(hex: 0xfe9d25)
        view.font = UIFont.systemFont(ofSize: 12)
        return view
    }()
    
    /// 最低
    lazy var labelLow: UILabel = {
        let view = UILabel()
        view.textColor = UIColor(hex: 0xfe9d25)
        view.font = UIFont.systemFont(ofSize: 12)
        return view
    }()
    
    /// 交易量
    lazy var labelVol: UILabel = {
        let view = UILabel()
        view.textColor = UIColor(hex: 0xfe9d25)
        view.font = UIFont.systemFont(ofSize: 12)
        return view
    }()
    
    /// 交易额
    lazy var labelTurnover: UILabel = {
        let view = UILabel()
        view.textColor = UIColor(hex: 0xfe9d25)
        view.font = UIFont.systemFont(ofSize: 12)
        return view
    }()
    
    /// 价格±
    lazy var labelMargin: UILabel = {
        let view = UILabel()
        view.textColor = UIColor(hex: 0xfe9d25)
        view.font = UIFont.systemFont(ofSize: 12)
        return view
    }()
    
    
    /// 左侧列
    lazy var stackLeft: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.distribution = .fillEqually
        s.spacing = 0
        s.alignment = .fill
        
        return s
    }()
    
    /// 右侧列
    lazy var stackRight: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.distribution = .fillEqually
        s.spacing = 0
        s.alignment = .fill
        
        return s
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
    }
    
    
    /// 配置UI
    func setupUI() {
        
        self.addSubview(self.stackLeft)
        self.addSubview(self.stackRight)
        
        let l1 = UIStackView()
        l1.axis = .horizontal
        l1.distribution = .fillEqually
        l1.spacing = 8
        l1.alignment = .fill
        
        l1.addArrangedSubview(self.labelMargin)
        l1.addArrangedSubview(self.labelRise)
        
        self.stackLeft.addArrangedSubview(self.labelPrice)
        self.stackLeft.addArrangedSubview(l1)
        
        let r1 = UIStackView()
        r1.axis = .horizontal
        r1.distribution = .fillEqually
        r1.spacing = 8
        r1.alignment = .fill
        
        r1.addArrangedSubview(self.labelHigh)
        r1.addArrangedSubview(self.labelOpen)
        
        let r2 = UIStackView()
        r2.axis = .horizontal
        r2.distribution = .fillEqually
        r2.spacing = 8
        r2.alignment = .fill
        
        r2.addArrangedSubview(self.labelLow)
        r2.addArrangedSubview(self.labelClose)
        
        let r3 = UIStackView()
        r3.axis = .horizontal
        r3.distribution = .fillEqually
        r3.spacing = 8
        r3.alignment = .fill
        
        r3.addArrangedSubview(self.labelVol)
        r3.addArrangedSubview(self.labelTurnover)
        
        self.stackRight.addArrangedSubview(r1)
        self.stackRight.addArrangedSubview(r2)
        self.stackRight.addArrangedSubview(r3)
        
        self.setupConstraints()
    }
    
    /// 配置布局
    func setupConstraints() {
        
        self.stackLeft.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalTo(self.stackRight.snp.left)
            make.top.bottom.equalToSuperview()
        }
        
        self.stackRight.snp.makeConstraints { (make) in
            make.width.equalTo(self.stackLeft.snp.width)
            make.right.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }
    }
    
    /// 更新数据
    ///
    /// - Parameter data:
    func update(data: KlineChartData) {
        self.labelPrice.text = "\(data.closePrice)"
        self.labelRise.text = "\(data.amplitudeRatio.toString(maxF: 2))%"
        self.labelMargin.text = "\(data.amplitude.toString(maxF: 4))"
        
        self.labelOpen.text = "O" + " " + "\(data.openPrice.toString(maxF: 4))"
        self.labelHigh.text = "H" + " " + "\(data.highPrice.toString(maxF: 4))"
        self.labelLow.text = "L" + " " + "\(data.lowPrice.toString(maxF: 4))"
        self.labelClose.text = "C" + " " + "\(data.closePrice.toString(maxF: 4))"
        self.labelVol.text = "V" + " " + "\(data.vol.toString(maxF: 2))"
        let turnover = data.vol * data.closePrice
        self.labelTurnover.text = "T" + " " + "\(turnover.toString(maxF: 2))"
    }
}
