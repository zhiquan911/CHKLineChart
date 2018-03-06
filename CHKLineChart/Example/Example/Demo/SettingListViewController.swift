//
//  SettingListViewController.swift
//  Example
//
//  Created by Chance on 2018/3/1.
//  Copyright © 2018年 Chance. All rights reserved.
//

import UIKit

@objc protocol SettingListViewDelegate {
    
    @objc optional func didCompletedParamsSetting()
}

class SettingListViewController: UIViewController {
    
    var seriesParam: [SeriesParam] = [SeriesParam]()
    
    weak var delegate: SettingListViewDelegate?
    
    lazy var tableView: UITableView = {
        let table = UITableView(frame: CGRect.zero, style: .plain)
        table.dataSource = self
        table.delegate = self
        return table
    }()

    lazy var footView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 100))
        return view
    }()
    
    lazy var buttonSave: UIButton = {
        let color = UIColor(hex: 0xfe9d25)
        let btn = UIButton(type: .custom)
        btn.setTitle("Reset Default", for: .normal)
        btn.setTitleColor(color, for: .normal)
        btn.layer.borderColor = color.cgColor
        btn.layer.cornerRadius = 3
        btn.layer.borderWidth = 1
        btn.layer.masksToBounds = true
        btn.addTarget(self, action: #selector(self.handleResetDefault), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.seriesParam = SeriesParamList.shared.loadUserData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.delegate?.didCompletedParamsSetting?()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /// 配置UI
    func setupUI() {
        self.view.backgroundColor = .white
        self.view.addSubview(self.tableView)
        self.footView.addSubview(self.buttonSave)
        self.tableView.tableFooterView = self.footView
        self.tableView.snp.makeConstraints { (make) in
            make.top.bottom.right.left.equalToSuperview()
        }
        self.buttonSave.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 160, height: 40))
        }
    }
    
    /// 重置默认
    @objc func handleResetDefault() {
        SeriesParamList.shared.resetDefault()
        self.seriesParam = SeriesParamList.shared.loadUserData()
        self.tableView.reloadData()
        
        let alert = UIAlertController(title: "Log", message: "Reset Default Successfully", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: { (_) -> Void in
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}


extension SettingListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.seriesParam.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: SeriesSettingCell?
        cell = tableView.dequeueReusableCell(withIdentifier: SeriesSettingCell.identify) as? SeriesSettingCell
        if cell == nil {
            cell = SeriesSettingCell()
        }
        
        let seriesParam = self.seriesParam[indexPath.row]
        cell?.configCell(seriesParam: seriesParam)
        cell?.didPressParam = {
            (c) in
            if let ip = self.tableView.indexPath(for: c) {
                let sp = self.seriesParam[ip.row]
                let vc = SettingDetailViewController()
                vc.seriesParam = sp
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        cell?.didShowChanged = {
            (c, s) in
            if let ip = self.tableView.indexPath(for: c) {
                let sp = self.seriesParam[ip.row]
                sp.hidden = !s.isOn
                _ = SeriesParamList.shared.saveUserData()
            }
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}
