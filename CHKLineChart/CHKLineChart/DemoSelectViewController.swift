//
//  ViewController.swift
//  CHKLineChart
//
//  Created by Chance on 16/8/31.
//  Copyright © 2016年 Chance. All rights reserved.
//

import UIKit
import CHKLineChartKit

class DemoSelectViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!

    let demo: [Int: (String, String)] = [
        0: ("K线一般功能演示", "ChartDemoViewController"),
        1: ("K线风格设置演示", "CustomStyleViewController"),
        2: ("K线商业定制例子", "ChartCustomDesignViewController"),
        3: ("K线简单线段例子", "ChartFullViewController"),
        4: ("K线静态图片例子", "ChartImageViewController"),
        5: ("K线列表图表例子", "ChartInTableViewController"),
        6: ("盘口深度图表例子", "DepthChartDemoViewController"),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}

extension DemoSelectViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.demo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "DemoCell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "DemoCell")
        }
        cell?.textLabel?.text = self.demo[indexPath.row]!.0
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let story = UIStoryboard.init(name: "Main", bundle: nil)
        let name = self.demo[indexPath.row]!.1
        let vc = story.instantiateViewController(withIdentifier: name)
        self.present(vc, animated: true, completion: nil)
        
    }
    
}
