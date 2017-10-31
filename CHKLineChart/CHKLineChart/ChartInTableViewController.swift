//
//  ChartInTableViewController.swift
//  CHKLineChart
//
//  Created by Chance on 2017/6/24.
//  Copyright © 2017年 bitbank. All rights reserved.
//

import UIKit
import CHKLineChartKit

class ChartInTableViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    let times: [String] = ["15min", "1min", "1day", "15min"] //选择时间，最后一个分时线
    var currencyTypes = ["btc", "eth", "etc", "ltc"]
    var klineDatas = [String : [AnyObject]]()
    var selectTimeIndex: [Int] = [0, 0, 0, 0]         //各币种选择的时段

    override func viewDidLoad() {
        super.viewDidLoad()
        for currency in self.currencyTypes {
            self.getRemoteServiceData(size: "70", symbol: currency, type: "15min")
        }
    }

    func getRemoteServiceData(size: String, symbol: String, type: String) {
        // 快捷方式获得session对象
        let session = URLSession.shared
        
        let url = URL(string: "https://www.btc123.com/kline/klineapi?symbol=chbtc\(symbol)cny&type=\(type)&size=\(size)")
        // 通过URL初始化task,在block内部可以直接对返回的数据进行处理
        let task = session.dataTask(with: url!, completionHandler: {
            [unowned self](data, response, error) in
            if let data = data {
                
                DispatchQueue.main.async {
                    /*
                     对从服务器获取到的数据data进行相应的处理.
                     */
                    do {
                        let dict = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableLeaves) as! [String: AnyObject]
                        
                        let isSuc = dict["isSuc"] as? Bool ?? false
                        if isSuc {
                            let datas = dict["datas"] as! [AnyObject]
                            self.klineDatas[symbol] = datas
                            let row = self.currencyTypes.index(of: symbol)
                            self.tableView.reloadRows(at: [IndexPath(row: row!, section: 0)],
                                                      with: UITableViewRowAnimation.automatic)
                        }
                        
                    } catch _ {
                        
                    }
                    
                }
                
                
            }
        })
        
        // 启动任务
        task.resume()
    }
    

    @IBAction func handleClosePress(sender: AnyObject?) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension ChartInTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.currencyTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: KChartCell.identifier) as! KChartCell
        cell.selectionStyle = .none
        let currencyType = self.currencyTypes[indexPath.row]
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
            self.getRemoteServiceData(size: "70", symbol: currencyType, type: time)
            cell.loadingView.isHidden = false
            cell.loadingView.startAnimating()

        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 240
    }
}
