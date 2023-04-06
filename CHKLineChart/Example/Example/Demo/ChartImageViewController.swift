//
//  ChartImageViewController.swift
//  CHKLineChart
//
//  Created by Chance on 2017/6/22.
//  Copyright © 2017年 atall.io. All rights reserved.
//

import UIKit
import CHKLineChartKit

class ChartImageViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    var klineDatas = [(Int, Double)]()
    let imageSize: CGSize = CGSize(width: 80, height: 30)
    let dataSize = 40

    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchChartDatas(symbol: "BTC-USD", type: "15m")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /// 拉取数据
    func fetchChartDatas(symbol: String, type: String) {
        ChartDatasFetcher.shared.getRemoteChartData(
            symbol: symbol,
            timeType: type,
            size: 70) {
                [weak self](flag, chartsData) in
                if flag && chartsData.count > 0 {
                    self?.klineDatas = chartsData.map {
                        ($0.time, $0.closePrice)
                    }
                    self?.tableView.reloadData()
                    
                }
        }
    }
    
}

extension ChartImageViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.klineDatas.count > 0 {
            return self.klineDatas.count / self.dataSize + 1
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DemoCell")
        cell?.selectionStyle = .none
        
        let imageView = cell?.contentView.viewWithTag(100) as? UIImageView
        let start = indexPath.row * self.dataSize
        var end = start + self.dataSize - 1
        if end >= self.klineDatas.count {
            end = self.klineDatas.count - 1
        }
        let data = self.klineDatas[start...end]
        let time = Date.ch_getTimeByStamp(data[start].0, format: "HH:mm") + "~" + Date.ch_getTimeByStamp(data[end].0, format: "HH:mm")
        cell?.textLabel?.text = time
        //生成图表图片
        imageView?.image = CHChartImageGenerator.share.getImage(
            by: Array(data),
            lineWidth: 1,
            backgroundColor: UIColor.white,
            lineColor: UIColor.ch_hex(0xA4AAB3),
            size: imageSize)
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
