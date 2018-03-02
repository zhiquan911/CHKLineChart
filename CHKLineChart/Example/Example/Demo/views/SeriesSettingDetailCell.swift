//
//  SeriesSettingDetailCell.swift
//  Example
//
//  Created by Chance on 2018/3/2.
//  Copyright © 2018年 Chance. All rights reserved.
//

import UIKit

class SeriesSettingDetailCell: UITableViewCell {
    
    typealias DidStepperChanged = (_ cell :SeriesSettingDetailCell, _ s: UIStepper) -> Void
    
    var didStepperChanged: DidStepperChanged?
    
    static let identify: String = "SeriesSettingDetailCell"
    
    lazy var labelTitle: UILabel = {
        let v = UILabel()
        v.textColor = .black
        return v
    }()
    
    lazy var labelValue: UILabel = {
        let v = UILabel()
        v.textColor = .black
        return v
    }()
    
    lazy var stepper: UIStepper = {
        let v = UIStepper()
        v.addTarget(self, action: #selector(self.handleStepperChanged(s:)), for: .touchUpInside)
        return v
    }()
    
    init() {
        super.init(style: .default, reuseIdentifier: SeriesSettingDetailCell.identify)
        self.setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setupUI() {
        
        self.contentView.addSubview(self.labelTitle)
        self.contentView.addSubview(self.labelValue)
        self.contentView.addSubview(self.stepper)
        
        self.labelValue.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(15)
            make.width.equalTo(60)
        }
        
        self.labelTitle.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(self.labelValue.snp.right).offset(15)
            make.right.equalTo(self.stepper.snp.left).offset(15)
        }
        
        self.stepper.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(15)
        }
    }
    
    func configCell(param: SeriesParamControl) {
    
        self.stepper.minimumValue = param.min
        self.stepper.maximumValue = param.max
        self.stepper.stepValue = param.step
        self.stepper.value = param.value
        
        self.labelValue.text = param.value.toString()
        self.labelTitle.text = param.note + "(" + param.min.toString() + "-" + param.max.toString() + ")"
    }

    @objc func handleStepperChanged(s: UIStepper) {
        let newValue = s.value
        self.labelValue.text = newValue.toString()
        self.didStepperChanged?(self, s)
    }
    
    
}
