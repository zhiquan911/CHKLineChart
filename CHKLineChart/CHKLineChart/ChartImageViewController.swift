//
//  ChartImageViewController.swift
//  CHKLineChart
//
//  Created by Chance on 2017/6/22.
//  Copyright © 2017年 bitbank. All rights reserved.
//

import UIKit

class ChartImageViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var headerView: UIView!
    var klineDatas = [(Int, Double)]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.getRemoteServiceData(size: "20")
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
                             let generator = self.getGenerator()
                            self.headerView.addSubview(generator.chartView)
                            generator.chartView.reloadData()
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
    
    func getGenerator() -> CHImageGenerator {
        let generator = CHImageGenerator(values: self.klineDatas, color: UIColor.gray, lineWidth: 1, size: CGSize(width: 500, height: 300))
        return generator
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
            return 7
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "DemoCell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "DemoCell")
        }
        let generator = self.getGenerator()
        let imageView = cell?.contentView.viewWithTag(100) as? UIImageView
//        imageView?.image = generator.image
        let view = cell?.contentView.viewWithTag(200)
//        view?.addSubview(generator.chartView)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
