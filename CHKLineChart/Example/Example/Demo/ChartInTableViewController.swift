//
//  ChartInTableViewController.swift
//  CHKLineChart
//
//  Created by Chance on 2017/6/24.
//  Copyright © 2017年 atall.io. All rights reserved.
//

import UIKit
import CHKLineChartKit

class ChartInTableViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    //选择时间
    let times: [String] = [
        "5m", "15m", "1H", "1D",
        ]
    
    //选择交易对
    let exPairs: [String] = [
        "BTC-USD", "ETH-USD", "LTC-USD",
        "DOGE-USD", "FIL-USD", "SOL-USD",
        ]
    
    var klineDatas = [String : [KlineChartData]]()
    var selectTimeIndex: [Int] = [0, 0, 0, 0, 0, 0]         //各币种选择的时段

    override func viewDidLoad() {
        super.viewDidLoad()
        for pair in self.exPairs {
            self.fetchChartDatas(symbol: pair, type: times[0])
        }
    }

    /// 拉取数据
    func fetchChartDatas(symbol: String, type: String) {
        ChartDatasFetcher.shared.getRemoteChartData(
            symbol: symbol,
            timeType: type,
            size: 70) {
                [weak self](flag, chartsData) in
                if flag && chartsData.count > 0 {
                    self?.klineDatas[symbol] = chartsData
                    let row = self?.exPairs.index(of: symbol)
                    self?.tableView.reloadRows(at: [IndexPath(row: row!, section: 0)],
                                              with: UITableViewRowAnimation.automatic)
                    
                }
        }
    }    
}

extension ChartInTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.exPairs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: KChartCell.identifier) as! KChartCell
        cell.selectionStyle = .none
        let currencyType = self.exPairs[indexPath.row]
        cell.currency = currencyType
        let selectedTime = self.selectTimeIndex[indexPath.row]
        cell.segTimes.selectedSegmentIndex = selectedTime
        let isTime = selectedTime == self.times.count - 1 ? true : false
        if let datas = self.klineDatas[currencyType], datas.count > 0 {
            cell.loadingView.isHidden = true
            cell.loadingView.stopAnimating()
            cell.reloadData(datas: datas, isTime: isTime)
        } else {
            cell.loadingView.isHidden = false
            cell.loadingView.startAnimating()
        }
        
        cell.updateTime = {
            [unowned self](index) -> Void in
             self.selectTimeIndex[indexPath.row] = index
            let time = self.times[index]
            self.fetchChartDatas(symbol: currencyType, type: time)
            cell.loadingView.isHidden = false
            cell.loadingView.startAnimating()

        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 240
    }
}
