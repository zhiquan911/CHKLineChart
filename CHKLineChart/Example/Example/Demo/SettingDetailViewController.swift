//
//  SettingDetailViewController.swift
//  Example
//
//  Created by Chance on 2018/3/1.
//  Copyright © 2018年 Chance. All rights reserved.
//

import UIKit

class SettingDetailViewController: UIViewController {

    var seriesParam: SeriesParam!
    
    lazy var tableView: UITableView = {
        let table = UITableView(frame: CGRect.zero, style: .plain)
        table.dataSource = self
        table.delegate = self
        return table
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /// 配置UI
    func setupUI() {
        self.view.backgroundColor = .white
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.top.bottom.right.left.equalToSuperview()
        }
    }
}


extension SettingDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.seriesParam.params.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: SeriesSettingDetailCell?
        cell = tableView.dequeueReusableCell(withIdentifier: SeriesSettingDetailCell.identify) as? SeriesSettingDetailCell
        if cell == nil {
            cell = SeriesSettingDetailCell()
        }
        
        let param = self.seriesParam.params[indexPath.row]
        cell?.configCell(param: param)
        cell?.didStepperChanged = {
            (c, s) in
            if let ip = self.tableView.indexPath(for: c) {
                let sc = self.seriesParam.params[ip.row]
                sc.value = s.value
                _ = SeriesParamList.shared.saveUserData()
            }
        }
        return cell!
    }
    
}
