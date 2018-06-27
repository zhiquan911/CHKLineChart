//
//  CHChartAlgorithm.swift
//  CHKLineChart
//
//  Created by Chance on 16/9/14.
//  Copyright © 2016年 Chance. All rights reserved.
//

import UIKit



/// 指标算法协议，用于日后开发者自由扩展编写自己的算法
public protocol CHChartAlgorithmProtocol {
    
    /// 实现该算法的处理
    /// 通过传入一个基本的K线数据模型集合给委托者，完成指标算法计算，
    /// 并把结果记录到CHChartItem的extVal字典中
    /// - Parameter datas: 传入K线数据模型集合
    /// - Returns: 算法的结果记录到CHChartItem的extVal字典中，返回一个处理后的集合
    func handleAlgorithm(_ datas: [CHChartItem]) -> [CHChartItem]
    
}

//MARK: - Equatable
//public func ==(lhs: CHChartAlgorithm, rhs: CHChartAlgorithm) -> Bool {
//    return lhs.hashValue == rhs.hashValue
//}

/**
 常用技术指标算法
 */
public enum CHChartAlgorithm: CHChartAlgorithmProtocol {
    
    case none                                   //无算法
    case timeline                               //时分
    case ma(Int)                                //简单移动平均数
    case ema(Int)                               //指数移动平均数
    case kdj(Int, Int, Int)                     //随机指标
    case macd(Int, Int, Int)                    //指数平滑异同平均线
    case boll(Int, Int)                         //布林线
    case sar(Int, CGFloat, CGFloat)             //停损转向操作点指标(判定周期，加速因子初值，加速因子最大值)
    case sam(Int)                               //SAM指标公式
    case rsi(Int)                               //RSI指标公式
    
    /**
     获取Key值的名称
     
     - parameter name: 可选的二级key
     
     - returns:
     */
    public func key(_ name: String = "") -> String {
        switch self {
        case .none:
            return ""
        case .timeline:
            return "\(CHSeriesKey.timeline)_\(name)"
        case let .ma(num):
            return "\(CHSeriesKey.ma)_\(num)_\(name)"
        case let .ema(num):
            return "\(CHSeriesKey.ema)_\(num)_\(name)"
        case .kdj(_, _, _):
            return "\(CHSeriesKey.kdj)_\(name)"
        case .macd(_, _, _):
            return "\(CHSeriesKey.macd)_\(name)"
        case .boll(_, _):
            return "\(CHSeriesKey.boll)_\(name)"
        case .sar(_, _, _):
            return "\(CHSeriesKey.sar)\(name)"
        case let .sam(num):
            return "\(CHSeriesKey.sam)_\(num)_\(name)"
        case let .rsi(num):
            return "\(CHSeriesKey.rsi)_\(num)_\(name)"
        }
    }
    
    /**
     处理算法
     
     - parameter datas:
     
     - returns:
     */
    public func handleAlgorithm(_ datas: [CHChartItem]) -> [CHChartItem] {
        switch self {
        case .none:
            return datas
        case .timeline:
            return self.handleTimeline(datas: datas)
        case let .ma(num):
            return self.handleMA(num, datas: datas)
        case let .ema(num):
            return self.handleEMA(num, datas: datas)
        case let .kdj(p1, p2, p3):
            return self.handleKDJ(p1, p2: p2, p3: p3, datas: datas)
        case let .macd(p1, p2, p3):
            return self.handleMACD(p1, p2: p2, p3: p3, datas: datas)
        case let .boll(num, k):
            return self.handleBOLL(num, k: k, datas: datas)
        case let .sar(num, minAF, maxAF):
            return self.handleSAR(num,minAF: minAF, maxAF: maxAF, datas: datas)
        case let .sam(num):
            return self.handleSAM(num, datas: datas)
        case let .rsi(num):
            return self.handleRSI(num, datas: datas)
        }
    }
    
    
}


// MARK: - 《RSI》 处理算法
extension CHChartAlgorithm {

    fileprivate func getAAndB(_ a: Int, _ b: Int, datas: [CHChartItem]) -> [CGFloat] { 
        var tA = a
        if tA < 0 {
            tA = 0
        }
        var sum: CGFloat = 0
        var dif: CGFloat = 0
        var closeT: CGFloat!
        var closeY: CGFloat!
        var result: [CGFloat] = [0, 0]
        for index in tA...b {
            if (index > tA) {
                closeT = datas[index].closePrice
                closeY = datas[index - 1].closePrice
                let c:CGFloat = closeT - closeY
                if (c > 0) {
                    sum = sum + c
                } else {
                    dif = sum + c
                }
                dif = abs(dif)
            }
        }
        result[0] = sum
        result[1] = dif
        return result
    }

    fileprivate func handleRSI(_ num: Int, datas: [CHChartItem]) -> [CHChartItem] {
    
        let defaultVal: CGFloat = 100
        let index = num - 1
        var sum: CGFloat = 0
        var dif: CGFloat = 0
        var rsi: CGFloat = 0
        
        for (i, data) in datas.enumerated() {
            if (num == 0) {
                sum = 0
                dif = 0
            } else {
                let k = i - num + 1
                let wrs:[CGFloat] = self.getAAndB(k, i, datas: datas)
                sum = wrs[0]
                dif = wrs[1]
            }
            if (dif != 0) {
                let h = sum + dif
                rsi = sum / h * 100
            } else {
                rsi = 100
            }
            
            if (i < index) {
                rsi = defaultVal
            }
            data.extVal["\(self.key(CHSeriesKey.timeline))"] = rsi
        }
        return datas
    }
}

// MARK: - 《时分价格》 处理算法
extension CHChartAlgorithm {
    
    /**
     处理时分价格运算
     使用收盘价为时分价
     - parameter datas: 数据集
     */
    fileprivate func handleTimeline(datas: [CHChartItem]) -> [CHChartItem] {
        for (_, data) in datas.enumerated() {
            data.extVal["\(self.key(CHSeriesKey.timeline))"] = data.closePrice
            data.extVal["\(self.key(CHSeriesKey.volume))"] = data.vol
        }
        return datas
    }
    
}

// MARK: - 《MA简单移动平均数》 处理算法
extension CHChartAlgorithm {
    
    /**
     处理MA运算
     
     - parameter num:   天数
     - parameter datas: 数据集
     */
    fileprivate func handleMA(_ num: Int, datas: [CHChartItem]) -> [CHChartItem] {
        for (index, data) in datas.enumerated() {
            let value = self.getMAValue(num, index: index, datas: datas)
            data.extVal["\(self.key(CHSeriesKey.timeline))"] = value.0
            data.extVal["\(self.key(CHSeriesKey.volume))"] = value.1
        }
        return datas
    }
    
    /**
     计算移动平均数MA
     
     - parameter num:   N
     - parameter index: 数据的位置
     
     - returns: MA数（价格，交易量）
     */
    fileprivate func getMAValue(_ num: Int, index: Int, datas: [CHChartItem]) -> (CGFloat?, CGFloat?) {
        var priceVal: CGFloat = 0
        var volVal: CGFloat = 0
        if index + 1 >= num {       //index + 1 >= N，累计N天内的
            for i in stride(from: index, through: index + 1 - num, by: -1) {
                volVal += datas[i].vol
                priceVal += datas[i].closePrice
            }
            volVal = volVal / CGFloat(num)
            priceVal = priceVal / CGFloat(num)
            return (priceVal, volVal)
        } else {                    //index + 1 < N，累计index + 1天内的
            for i in stride(from: index, through: 0, by: -1) {
                volVal += datas[i].vol
                priceVal += datas[i].closePrice
            }
            volVal = volVal / CGFloat(index + 1)
            priceVal = priceVal / CGFloat(index + 1)
            return (priceVal, volVal)
            // return (nil, nil)
        }
        
    }
    
}

// MARK: - 《EMA指数移动平均数》 处理算法
extension CHChartAlgorithm {
    
    /**
     处理EMA运算
     EMA（N）=2/（N+1）*（C-昨日EMA）+昨日EMA；
     EMA（12）=昨日EMA（12）*11/13+C*2/13；
     - parameter num:   天数
     - parameter datas: 数据集
     */
    fileprivate func handleEMA(_ num: Int, datas: [CHChartItem]) -> [CHChartItem] {
        var prev_ema_price: CGFloat = 0
        var prev_ema_vol: CGFloat = 0
        for (index, data) in datas.enumerated() {
            
            let c = datas[index].closePrice
            let v = datas[index].vol
            
            var ema_price: CGFloat = 0
            var ema_vol: CGFloat = 0
            //EMA（N）=2/（N+1）*（C-昨日EMA）+昨日EMA；
            if index > 0 {
                //EMA（N）=2/（N+1）*（C-昨日EMA）+昨日EMA；
                ema_price = prev_ema_price + (c - prev_ema_price) * 2 / (CGFloat(num) + 1)
                ema_vol = prev_ema_vol + (v - prev_ema_vol) * 2 / (CGFloat(num) + 1)
                
            } else {
                ema_price = c
                ema_vol = v
            }
            
            data.extVal["\(self.key(CHSeriesKey.timeline))"] = ema_price
            data.extVal["\(self.key(CHSeriesKey.volume))"] = ema_vol
            
            prev_ema_price = ema_price
            prev_ema_vol = ema_vol
        }
        return datas
    }
    
}

// MARK: - 《KDJ随机指标》 处理算法
extension CHChartAlgorithm {
    
    /**
     处理KDJ运算
     
     - parameter p1:    指标分析周期
     - parameter p2:    指标分析周期
     - parameter p3:    指标分析周期
     - parameter datas: 未处理的集合
     
     - returns: 处理好的集合
     */
    fileprivate func handleKDJ(_ p1: Int, p2: Int,p3: Int, datas: [CHChartItem]) -> [CHChartItem] {
        var prev_k: CGFloat = 50
        var prev_d: CGFloat = 50
        for (index, data) in datas.enumerated() {
            //计算RSV值
            if let rsv = self.getRSV(p1, index: index, datas: datas) {
                //计算K,D,J值
                let k: CGFloat = (2 * prev_k + rsv) / 3
                let d: CGFloat = (2 * prev_d + k) / 3
                let j: CGFloat = 3 * k - 2 * d
                
                prev_k = k
                prev_d = d
                
                data.extVal["\(self.key("K"))"] = k
                data.extVal["\(self.key("D"))"] = d
                data.extVal["\(self.key("J"))"] = j
            }
        }
        return datas
    }
    
    /**
     RSV计算
     
     - parameter num:   计算天数范围
     - parameter index: 当前的索引位
     
     - returns:
     */
    fileprivate func getRSV(_ num: Int, index: Int, datas: [CHChartItem]) -> CGFloat? {
        var rsv: CGFloat = 0
        let c = datas[index].closePrice
        var h = datas[index].highPrice
        var l = datas[index].lowPrice
        
        let block: (Int) -> Void = {
            (i) -> Void in
            
            let item = datas[i]
            
            if item.highPrice > h {
                h = item.highPrice
            }
            
            if item.lowPrice < l {
                l = item.lowPrice
            }
        }
        
        if index + 1 >= num {    //index + 1 >= N，累计N天内的
            //计算num天数内最低价，最高价
            for i in stride(from: index, through: index + 1 - num, by: -1) {
                block(i)
            }
        } else {                //index + 1 < N，累计index + 1天内的
            //计算index天数内最低价，最高价
            for i in stride(from: index, through: 0, by: -1) {
                block(i)
            }
        }
        
        if h != l {
            rsv = (c - l) / (h - l) * 100
        }
        return rsv
    }
    
}

// MARK: - 《MACD平滑异同移动平均线》 处理算法
extension CHChartAlgorithm {
    
    /**
     处理MACD运算
     EMA（N）=2/（N+1）*（C-昨日EMA）+昨日EMA；
     EMA（12）=昨日EMA（12）*11/13+C*2/13；
     - parameter num:   天数
     - parameter datas: 数据集
     */
    fileprivate func handleMACD(_ p1: Int, p2: Int,p3: Int, datas: [CHChartItem]) -> [CHChartItem] {
        var pre_dea: CGFloat = 0
        for (index, data) in datas.enumerated() {
            //EMA（p1）=2/（p1+1）*（C-昨日EMA）+昨日EMA；
            let (ema1, _) = self.getEMA(p1, index: index, datas: datas)
            //EMA（p2）=2/（p2+1）*（C-昨日EMA）+昨日EMA；
            let (ema2, _) = self.getEMA(p2, index: index, datas: datas)
            
            if ema1 != nil && ema2 != nil {
                //DIF=今日EMA（p1）- 今日EMA（p2）
                let dif = ema1! - ema2!
                //dea（p3）=2/（p3+1）*（dif-昨日dea）+昨日dea；
                let dea = pre_dea + (dif - pre_dea) * 2 / (CGFloat(p3) + 1)
                //BAR=2×(DIF－DEA)
                let bar = 2 * (dif - dea)
                
                data.extVal["\(self.key("DIF"))"] = dif
                data.extVal["\(self.key("DEA"))"] = dea
                data.extVal["\(self.key("BAR"))"] = bar
                
                pre_dea = dea
            }
        }
        return datas
    }
    
    /**
     获取某日的EMA数据
     
     - parameter num:   天数周期
     - parameter index:
     - parameter datas:
     
     - returns: //EMA的成交价和成交量
     */
    fileprivate func getEMA(_ num: Int, index: Int, datas: [CHChartItem]) -> (CGFloat?, CGFloat?) {
        let ema = CHChartAlgorithm.ema(num)
        let data = datas[index]
        let ema_price = data.extVal["\(ema.key(CHSeriesKey.timeline))"]
        let ema_vol = data.extVal["\(ema.key(CHSeriesKey.volume))"]
        return (ema_price, ema_vol)
    }
    
    /**
     获取某日的MA数据
     
     - parameter num:   天数周期
     - parameter index:
     - parameter datas:
     
     - returns: //MA的成交价和成交量
     */
    fileprivate func getMA(_ num: Int, index: Int, datas: [CHChartItem]) -> (CGFloat?, CGFloat?) {
        let ma = CHChartAlgorithm.ma(num)
        let data = datas[index]
        let ma_price = data.extVal["\(ma.key(CHSeriesKey.timeline))"]
        let ma_vol = data.extVal["\(ma.key(CHSeriesKey.volume))"]
        return (ma_price, ma_vol)
    }
}

// MARK: - 《BOLL布林线》 处理算法
extension CHChartAlgorithm {
    
    
    /// 布林线处理方法
    ///
    /// 计算公式
    /// 中轨线=N日的移动平均线
    /// 上轨线=中轨线+两倍的标准差
    /// 下轨线=中轨线－两倍的标准差
    /// 计算过程
    /// （1）计算MA
    /// MA=N日内的收盘价之和÷N
    /// （2）计算标准差MD
    /// MD=平方根（N）日的（C－MA）的两次方之和除以N
    /// （3）计算MB、UP、DN线
    /// MB=（N）日的MA
    /// UP=MB+k×MD
    /// DN=MB－k×MD
    /// （K为参数，可根据股票的特性来做相应的调整，一般默认为2）
    ///
    /// - Parameters:
    ///   - num: 天数
    ///   - k: 参数默认为2
    ///   - datas: 待处理的数据
    /// - Returns: 处理后的数据
    fileprivate func handleBOLL(_ num: Int, k: Int = 2, datas: [CHChartItem]) -> [CHChartItem] {
        var md: CGFloat = 0, mb: CGFloat = 0, up: CGFloat = 0, dn: CGFloat = 0
        for (index, data) in datas.enumerated() {
            //计算标准差
            md = self.handleBOLLSTD(num, index: index, datas: datas)
            mb = self.getMA(num, index: index, datas: datas).0 ?? 0
            up = mb + CGFloat(k) * md
            dn = mb - CGFloat(k) * md
            
            data.extVal["\(self.key("BOLL"))"] = mb
            data.extVal["\(self.key("UB"))"] = up
            data.extVal["\(self.key("LB"))"] = dn
        }
        
        return datas
    }
    
    
    /// 计算布林线中的MA平方差
    ///
    /// - Parameters:
    ///   - num: 累计的天数
    ///   - index: 当天日期
    ///   - datas: 数据集合
    /// - Returns: 结果
    fileprivate func handleBOLLSTD(_ num: Int, index: Int, datas: [CHChartItem]) -> CGFloat {
        var dx: CGFloat = 0, md: CGFloat = 0
        let ma = self.getMA(num, index: index, datas: datas).0 ?? 0
        if index + 1 >= num {       //index + 1 >= N，计算N日的平方差
            for i in stride(from: index, through: index + 1 - num, by: -1) {
                dx += pow(datas[i].closePrice - ma, 2)
            }
            md = dx / CGFloat(num)
        } else {                    //index + 1 < N，计算index + 1日的平方差
            for i in stride(from: index, through: 0, by: -1) {
                dx += pow(datas[i].closePrice - ma, 2)
            }
            md = dx / CGFloat(index + 1)
        }
        //平方根
        md = pow(md, 0.5)
        return md
    }
}

// MARK: - 《SAR指标》 处理算法
extension CHChartAlgorithm {
    
    
    
    /// SAR指标又叫抛物线指标或停损转向操作点指标
    ///
    /// 计算Tn周期的SAR值为例，计算公式如下：
    /// SAR(Tn)=SAR(Tn-1)+AF(Tn)*[EP(Tn-1)-SAR(Tn-1)]
    /// 其中，SAR(Tn)为第Tn周期的SAR值，SAR(Tn-1)为第(Tn-1)周期的值
    /// AF为加速因子(或叫加速系数)，EP为极点价(最高价或最低价)
    /// 在计算SAR值时，要注意以下几项原则：
    /// 1、初始值SAR(T0)的确定
    /// 若T1周期中SAR(T1)上涨趋势，则SAR(T0)为T0周期的最低价，若T1周期下跌趋势，则SAR(T0)为T0周期 的最高价；
    /// 2、极点价EP的确定
    /// 若Tn周期为上涨趋势（SAR在K线下方），EP(Tn-1)为Tn-1周期的最高价，若Tn周期为下跌趋势（SAR在K线上方），EP(Tn-1)为Tn-1周期的最低价；
    /// 3、加速因子AF的确定
    /// (a)加速因子初始值为0.02，即AF(T0)=0.02；
    /// (b)若Tn-1，Tn周期都为上涨趋势时，当Tn周期的最高价>Tn-1周期的最高价,则AF(Tn)=AF(Tn-1)+0.02， 当Tn周期的最高价<=Tn-1周期的最高价,则AF(Tn)=AF(Tn-1)，但加速因子AF最高不超过0.2；
    /// (c)若Tn-1，Tn周期都为下跌趋势时，当Tn周期的最低价<Tn-1周期的最低价,则AF(Tn)=AF(Tn-1)+0.02， 当Tn周期的最低价>=Tn-1周期的最低价,则AF(Tn)=AF(Tn-1)；
    /// (d)任何一次行情的转变，加速因子AF都必须重新由0.02起算；
    /// 比如，Tn-1周期为上涨趋势，Tn周期为下跌趋势(或Tn-1下跌，Tn上涨)，AF(Tn)需重新由0.02为基础进 行计算，即AF(Tn)=AF(T0)=0.02；
    /// (e)加速因子AF最高不超过0.2,当AF>0.2时，维持最大值；
    /// 4、确定今天的SAR值
    /// (a)通过公式SAR(Tn)=SAR(Tn-1)+AF(Tn)*[EP(Tn-1)-SAR(Tn-1)]，计算出Tn周期的值；
    /// (b)若Tn周期为上涨趋势，当SAR(Tn)>Tn周期的收盘价，则Tn周期最终 SAR值应为基准周期段的最高价中的最大值，
    /// 当SAR(Tn)<=Tn周期的收盘价，则Tn周期最终SAR值为SAR(Tn)，即 SAR=SAR(Tn)；
    /// (c)若Tn周期为下跌趋势，当SAR(Tn)<Tn周期的收盘价，则Tn周期最终 SAR值应为基准周期段的最低价中的最小值，
    /// 当SAR(Tn)>=Tn周期的收盘价，则Tn周期最终SAR值为SAR(Tn)，即 SAR=SAR(Tn)；
    /// 5、SAR指标周期的计算基准周期的参数为2，如2日、2周、2月等，其计算周期的参数变动范围为2—8。（多数推荐4）
    /// 6、SAR指标的计算方法和过程比较烦琐，对于投资者来说只要掌握其演算过程和原理，在实际操作中并不 需要投资者自己计算SAR值，更重要的是投资者要灵活掌握和运用SAR指标的研判方法和功能。
    ///
    /// - Parameter num: 基准周期数N
    /// - Parameter minAF: 加速因子AF最小值（初始值）
    /// - Parameter maxAF: 加速因子AF最大值
    /// - Parameter datas: 待处理的数据集合
    /// - Returns: 处理后的数据集合
    fileprivate func handleSAR(_ num: Int, minAF: CGFloat, maxAF: CGFloat, datas: [CHChartItem]) -> [CHChartItem] {
        
        var sar: CGFloat = 0, af: CGFloat = minAF, ep: CGFloat = 0
        var pre_data: CHChartItem!
        var isUP: Bool = true              //true：上涨趋势，false：下跌趋势
        
        //这个指标至少2条数据才显示
        guard num >= 2 && datas.count >= 2 else {
            return datas
        }
        
        /// 1、初始值SAR(T0)的确定
        /// 若T1周期中SAR(T1)上涨趋势，则SAR(T0)为T0周期的最低价，若T1周期下跌趋势，则SAR(T0)为T0周期 的最高价；
        if datas[1].closePrice > datas[0].closePrice {
            sar = datas[0].lowPrice
            isUP = true
        } else {
            sar = datas[0].highPrice
            isUP = false
        }
        
        //记录第1日
        pre_data = datas[0]
        
        for (index, data) in datas.enumerated() {
            
            if index > 0 {      //忽略第一天
                
                //确定今天的SAR值
                let finalSAR = self.getFinalSAR(num: num, sar: sar, index: index, isUP: isUP, datas: datas)
                
                //出现行情反转，充值AF加速因子
                if isUP != finalSAR.1 {
                    af = minAF
                }
                
                sar = finalSAR.0
                isUP = finalSAR.1
                
            }
            
            data.extVal["\(self.key())"] = sar
            
            //预算下一天的sar值
            
            /// SAR(Tn)=SAR(Tn-1)+AF(Tn)*[EP(Tn-1)-SAR(Tn-1)]
            /// SAR(1) = SAR(0) + AF(1)*[EP(0)-SAR(0)] 第1天
            /// 2、极点价EP的确定
            /// 若Tn周期为上涨趋势（SAR在K线下方），EP(Tn-1)为Tn-1周期的最高价，若Tn周期为下跌趋势（SAR在K线上方），EP(Tn-1)为Tn-1周期的最低价；
            
            if isUP {
                ep = pre_data.highPrice
            } else {
                ep = pre_data.lowPrice
            }
            
            /// 3、加速因子AF的确定
            /// (a)加速因子初始值为0.02，即AF(T0)=0.02；
            /// (b)若Tn-1，Tn周期都为上涨趋势时，当Tn周期的最高价>Tn-1周期的最高价,则AF(Tn)=AF(Tn-1)+0.02， 当Tn周期的最高价<=Tn-1周期的最高价,则AF(Tn)=AF(Tn-1)，但加速因子AF最高不超过0.2；
            /// (c)若Tn-1，Tn周期都为下跌趋势时，当Tn周期的最低价<Tn-1周期的最低价,则AF(Tn)=AF(Tn-1)+0.02， 当Tn周期的最低价>=Tn-1周期的最低价,则AF(Tn)=AF(Tn-1)；
            /// (d)任何一次行情的转变，加速因子AF都必须重新由0.02起算；
            /// 比如，Tn-1周期为上涨趋势，Tn周期为下跌趋势(或Tn-1下跌，Tn上涨)，AF(Tn)需重新由0.02为基础进 行计算，即AF(Tn)=AF(T0)=0.02；
            /// (e)加速因子AF最高不超过0.2,当AF>0.2时，维持最大值；
            if isUP {
                if data.highPrice > pre_data.highPrice {
                    af = af + minAF
                }
            } else {
                if data.lowPrice < pre_data.lowPrice {
                    af = af + minAF
                }
            }
            
            if af > maxAF {
                af = maxAF
            }
            

            sar = sar + af * (ep - sar)
            
            //记录明天的sar值
            data.extVal["\(self.key("tomorrow"))"] = sar
            

            pre_data = data
            
            
        }
        
        return datas
    }
    
    
    /// 确定当天最终的SAR值
    ///
    /// - Parameters:
    ///   - num: 趋势判断周期
    ///   - sar: 预算的sar值
    ///   - index: 该周期位置
    ///   - isUP: 趋势
    ///   - datas: 数据集合
    /// - Returns: 最终值，是否行情翻转
    func getFinalSAR(num: Int, sar: CGFloat, index: Int, isUP: Bool, datas: [CHChartItem]) -> (CGFloat, Bool) {
        
        /// 4、确定今天的SAR值
        /// (a)通过公式SAR(Tn)=SAR(Tn-1)+AF(Tn)*[EP(Tn-1)-SAR(Tn-1)]，计算出Tn周期的值；
        /// (b)若Tn周期为上涨趋势，当SAR(Tn)>Tn周期的收盘价，则Tn周期最终 SAR值应为num天周期段的最高价中的最大值，
        /// 当SAR(Tn)<=Tn周期的收盘价，则Tn周期最终SAR值为SAR(Tn)，即 SAR=SAR(Tn)；
        /// (c)若Tn周期为下跌趋势，当SAR(Tn)<Tn周期的收盘价，则Tn周期最终 SAR值应为num天周期的最低价中的最小值，
        /// 当SAR(Tn)>=Tn周期的收盘价，则Tn周期最终SAR值为SAR(Tn)，即 SAR=SAR(Tn)；
        
        
        var finalSAR: CGFloat = sar
        var finalIsUP: Bool = isUP
        var start = index
        if isUP {
            if sar > datas[index].closePrice {  //收盘跌破SAR，转向做空
                //以今天开始数前num天的最高价
                repeat {
                    finalSAR = max(datas[start].highPrice, finalSAR) //获取最大值
                    start -= 1  //递减直到num天前
                } while start >= max(index - num + 1, 0)
                
                finalIsUP = false
            }
        } else {
            if sar < datas[index].closePrice {  //收盘突破SAR，转向做多
                //以今天开始数前num天的最低价
                repeat {
                    finalSAR = min(datas[start].lowPrice, finalSAR) //获取最小值
                    start -= 1  //递减直到num天前
                } while start >= max(index - num + 1, 0)
                
                finalIsUP = true
            }
        }
        
        return (finalSAR, finalIsUP)
    }
}

// MARK: - 《SAM一线天指标》 处理算法
extension CHChartAlgorithm {
    
    /**
     处理SAM运算
     1.计算每个点往后num周期内的最高交易量，最后少于num的条数，只计算最后个数的最高交易量
     2.在主图蜡烛柱边框加颜色显示
     3.在主图收盘价记录点线
     4.在副图交易量柱边框加颜色显示
     5.在副图交易量记录点线
     - parameter num:   天数
     - parameter datas: 数据集
     */
    fileprivate func handleSAM(_ num: Int, datas: [CHChartItem]) -> [CHChartItem] {
        var max_vol_price: CGFloat = 0  //最大交易量的收盘价
        var max_vol: CGFloat = 0        //最大交易量
        var max_index: Int = 0          //最大交易量的位置
        for (index, data) in datas.enumerated() {
            
            //超过了num周期都没找到最大值，重新在index后num个寻找
            if index - max_index == num {
                max_vol_price = 0
                max_vol = 0
                max_index = 0
                for j in (index - num + 1)...index {
                    
                    let c = datas[j].closePrice
                    let v = datas[j].vol
                    
                    if v > max_vol {
                        max_vol_price = c
                        max_vol = v
                        max_index = j
                    }
                }
                
                //重置最大值之后的计算数值
                for j in max_index...index {
                    datas[j].extVal["\(self.key(CHSeriesKey.timeline))"] = max_vol_price
                    datas[j].extVal["\(self.key(CHSeriesKey.volume))"] = max_vol
                }
                
            } else {
                //每位移一个数，计算是否最大交易量
                let c = datas[index].closePrice
                let v = datas[index].vol
                
                if v > max_vol {
                    max_vol_price = c
                    max_vol = v
                    max_index = index
                }
                
            }
            
            if index > num - 1 {
                data.extVal["\(self.key(CHSeriesKey.timeline))"] = max_vol_price
                data.extVal["\(self.key(CHSeriesKey.volume))"] = max_vol
                
                //记录填充颜色的最大值
                let priceName = "\(CHSeriesKey.timeline)_BAR"
                let volumeName = "\(CHSeriesKey.volume)_BAR"
                let maxData = datas[max_index]
                maxData.extVal["\(self.key(priceName))"] = max_vol_price
                maxData.extVal["\(self.key(volumeName))"] = max_vol
            } else if index == num - 1 {
                //补充开头没有画的线
                for j in max_index...index {
                    datas[j].extVal["\(self.key(CHSeriesKey.timeline))"] = max_vol_price
                    datas[j].extVal["\(self.key(CHSeriesKey.volume))"] = max_vol
                }
            }
            
        }
        
        //绘制最后一段的线
        for j in max_index..<datas.count {
            datas[j].extVal["\(self.key(CHSeriesKey.timeline))"] = max_vol_price
            datas[j].extVal["\(self.key(CHSeriesKey.volume))"] = max_vol
        }
        
        return datas
    }
    
}
