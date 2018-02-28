//
//  SectionHeaderView.swift
//  CHKLineChart
//
//  Created by Chance on 2017/7/14.
//  Copyright © 2017年 atall.io. All rights reserved.
//

import UIKit
import SnapKit
import CHKLineChartKit

class SectionHeaderView: UIView {

    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var buttonSet: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupUI() {
        
        self.buttonSet = UIButton(type: .custom)
        self.buttonSet.setTitle("设置", for: .normal)
        self.buttonSet.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        self.buttonSet.setTitleColor(UIColor.white, for: .normal)
        self.buttonSet.backgroundColor = UIColor.darkGray
        self.buttonSet.layer.cornerRadius = 2
        self.addSubview(self.buttonSet)
        
        self.buttonSet.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(2)
            make.top.bottom.equalToSuperview().offset(2)
            make.width.equalTo(30)
        }
        
//        self.buttonSet.frame = CGRect(x: 0, y: 1, width: 30, height: 20)
        
        self.labelTitle = UILabel()
        self.labelTitle.textColor = UIColor.white
        self.labelTitle.font = UIFont.systemFont(ofSize: 10)
        self.labelTitle.backgroundColor = UIColor.clear
        self.addSubview(self.labelTitle)
        
        self.labelTitle.snp.makeConstraints { (make) in
            make.left.equalTo(self.buttonSet.snp.right).offset(8)
            make.top.bottom.equalToSuperview().offset(2)
            make.right.equalToSuperview()
        }

    }

}
