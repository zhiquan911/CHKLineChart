//
//  ChartDatasFetcher.swift
//  Example
//
//  Created by Chance on 2018/2/27.
//  Copyright © 2018年 Chance. All rights reserved.
//

import UIKit
import SwiftyJSON

class ChartDatasFetcher: NSObject {
    
    /// 接口地址
    var apiURL = "https://www.okex.com/api/v1/"

    /// 全局唯一实例
    static let shared: ChartDatasFetcher = {
        let instance = ChartDatasFetcher()
        return instance
    }()
    
    /// 获取服务API的K线数据
    ///
    /// - Parameters:
    ///   - symbol: 市场
    ///   - timeType: 时间周期
    ///   - size: 数据条数
    ///   - callback:
    func getRemoteChartData(symbol: String, timeType: String, size: Int,
                            callback:@escaping (Bool, [KlineChartData]) -> Void) {

        // 快捷方式获得session对象
        let session = URLSession.shared
        
        let url = URL(string: self.apiURL + "kline.do?symbol=\(symbol)&type=\(timeType)&size=\(size)")
        // 通过URL初始化task,在block内部可以直接对返回的数据进行处理
        let task = session.dataTask(with: url!, completionHandler: {
            (data, response, error) in
            if let data = data {
                
                DispatchQueue.main.async {
                    
                    var marketDatas = [KlineChartData]()
                    
                    /*
                     对从服务器获取到的数据data进行相应的处理.
                     */
                    do {
                        let json = try JSON(data: data)
                        let chartDatas = json.arrayValue
                        for data in chartDatas {
                            let marektdata = KlineChartData(json: data.arrayValue)
                            marketDatas.append(marektdata)
                        }
                        
                        callback(true, marketDatas)
                        
                    } catch _ {
                        callback(false, marketDatas)
                    }
                }
                
                
            }
        })
        
        // 启动任务
        task.resume()
    }
    
    
}
