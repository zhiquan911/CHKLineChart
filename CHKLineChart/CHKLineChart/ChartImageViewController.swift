//
//  ChartImageViewController.swift
//  CHKLineChart
//
//  Created by Chance on 2017/6/22.
//  Copyright © 2017年 bitbank. All rights reserved.
//

import UIKit
import CHKLineChartKit

class ChartImageViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    var klineDatas = [(Int, Double)]()
    let imageSize: CGSize = CGSize(width: 80, height: 30)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.getRemoteServiceData(size: "800")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func getRemoteServiceData(size: String) {
        // 快捷方式获得session对象
        let session = URLSession.shared
        
        let url = URL(string: "https://www.btc123.com/kline/klineapi?symbol=chbtcbtccny&type=15min&size=\(size)")
        // 通过URL初始化task,在block内部可以直接对返回的数据进行处理
        let task = session.dataTask(with: url!, completionHandler: {
            (data, response, error) in
            if let data = data {
                
                DispatchQueue.main.async {
                    /*
                     对从服务器获取到的数据data进行相应的处理.
                     */
                    do {
                        let dict = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableLeaves) as! [String: AnyObject]
                        
                        let isSuc = dict["isSuc"] as? Bool ?? false
                        if isSuc {
                            let datas = dict["datas"] as! [[Double]]
                            self.klineDatas = datas.map {
                                (Int($0[0] / 1000), Double($0[4]))
                            }
                            NSLog("chart.datas = \(datas.count)")
                            self.tableView.reloadData()
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

extension ChartImageViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.klineDatas.count > 0 {
            return 20
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DemoCell")
        cell?.selectionStyle = .none
        
        let imageView = cell?.contentView.viewWithTag(100) as? UIImageView
        let start = indexPath.row * 40
        var end = start + 40 - 1
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
            backgroundColor: UIColor.ch_hex(0xF5F5F5),
            lineColor: UIColor.ch_hex(0xA4AAB3),
            size: imageSize)
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
