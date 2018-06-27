# CHKLineChart

![s1.png](/screenshots/s1.png)
![s2.png](/screenshots/s2.png)![s3.png](/screenshots/s3.png)
![s4.png](/screenshots/s4.png)![s5.png](/screenshots/s5.png)

> 纯Swift4.0代码编写的K线图表组件，支持：MA,EMA,KDJ,MACD,RSI等技术指标显示。集成使用简单，二次开发扩展强大。

## Features

- 完美支持Swift4.0编译。
- 线图丰富，蜡烛图，时分图，柱状图，提供画线扩展模型。
- 目前支持MA,EMA,BOLL,SAR,KDJ,MACD,RSI等技术指标，提供指标算法扩展模型。
- 支持使用代码创建视图或使用xib/storyboard创建视图。
- 样式提供更多配置，满足更多商业定制。
- 底层采用CALayer+UIBezierPath绘制图表，大大提高性能。

## Requirements

- iOS 8+
- Xcode 8+
- Swift 4.0+
- iPhone/iPad

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org/) is a dependency manager for Cocoa projects.

You can install it with the following command:

```java
$ gem install cocoapods
```

To integrate Log into your Xcode project using CocoaPods, specify it in your Podfile:

```java
use_frameworks!

pod 'CHKLineChartKit'
```

### Manual

打开文件夹/CHKLineChart/Carthage/Build/iOS/，复制CHKLineChartKit.framework到你的项目文件夹中。在Project -> Target -> General -> Embedded Binaries，点+，导入CHKLineChartKit.framework。

## Example

详细例子，打开Example/Example.xcworkspace，参考ChartCustomViewController的例子。

应用代码片段：

```swift

import CHKLineChartKit

class ChartCustomViewController: UIViewController {

    /// 数据源
    var klineDatas = [KlineChartData]()

    /// 图表
    lazy var chartView: CHKLineChartView = {
        let chartView = CHKLineChartView(frame: CGRect.zero)
        chartView.style = .base       //默认样式
        chartView.delegate = self
        return chartView
    }()

    override func viewDidLoad() {
        self.view.addSubview(self.chartView)
    }

    override func viewDidLayoutSubviews() {
        self.chartView.frame = self.view.bounds
    }

}

// MARK: - 实现K线图表的委托方法
extension ChartCustomViewController: CHKLineChartDelegate {
    
    /// 图表显示数据总数
    func numberOfPointsInKLineChart(chart: CHKLineChartView) -> Int {
        return self.klineDatas.count
    }
    
    /// 提供图表数据源
    func kLineChart(chart: CHKLineChartView, valueForPointAtIndex index: Int) -> CHChartItem {
        let data = self.klineDatas[index]
        let item = CHChartItem()
        item.time = data.time
        item.openPrice = CGFloat(data.openPrice)
        item.highPrice = CGFloat(data.highPrice)
        item.lowPrice = CGFloat(data.lowPrice)
        item.closePrice = CGFloat(data.closePrice)
        item.vol = CGFloat(data.vol)
        return item
    }
    
    /// 自定义Y轴坐标值显示内容
    func kLineChart(chart: CHKLineChartView, labelOnYAxisForValue value: CGFloat, atIndex index: Int, section: CHSection) -> String {
        var strValue = ""
        if section.key == "volume" {
            if value / 1000 > 1 {
                strValue = (value / 1000).ch_toString(maxF: section.decimal) + "K"
            } else {
                strValue = value.ch_toString(maxF: section.decimal)
            }
        } else {
            strValue = value.ch_toString(maxF: section.decimal)
        }
        
        return strValue
    }
    
    /// 自定义X轴坐标值显示内容
    func kLineChart(chart: CHKLineChartView, labelOnXAxisForIndex index: Int) -> String {
        let data = self.klineDatas[index]
        let timestamp = data.time
        let dayText = Date.ch_getTimeByStamp(timestamp, format: "MM-dd")
        let timeText = Date.ch_getTimeByStamp(timestamp, format: "HH:mm")
        var text = ""
        //跨日，显示日期
        if dayText != self.chartXAxisPrevDay && index > 0 {
            text = dayText
        } else {
            text = timeText
        }
        self.chartXAxisPrevDay = dayText
        return text
    }
    
    
    /// 调整每个分区的小数位保留数
    ///
    /// - parameter chart:
    /// - parameter section:
    ///
    /// - returns:
    func kLineChart(chart: CHKLineChartView, decimalAt section: Int) -> Int {
        return 2
    }
}

```

## Custom Index（开发自定义指标）

本K线图表最大的一个亮点就是提供了非常容易的指标开发入口。
如何开发自己的指标呢？步骤如下：

**1. 开发者需要实现CHChartAlgorithmProtocol。例子参考CHChartAlgorithm枚举。**

```swift

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
        }
    }

    ......


}
```

**2. extension CHSeries，编写自己的线组。**

```swift

// MARK: - 工厂方法
extension CHSeries {
    
    /**
     返回一个MACD系列样式
     */
    public class func getMACD(_ difc: UIColor,
                              deac: UIColor,
                              barc: UIColor,
                              upStyle: (color: UIColor, isSolid: Bool),
                              downStyle: (color: UIColor, isSolid: Bool),
                              section: CHSection) -> CHSeries {
        let series = CHSeries()
        series.key = CHSeriesKey.macd
        let dif = CHChartModel.getLine(difc, title: "DIF", key: "\(CHSeriesKey.macd)_DIF")
        dif.section = section
        let dea = CHChartModel.getLine(deac, title: "DEA", key: "\(CHSeriesKey.macd)_DEA")
        dea.section = section
        let bar = CHChartModel.getBar(upStyle: upStyle, downStyle: downStyle, titleColor: barc, title: "MACD", key: "\(CHSeriesKey.macd)_BAR")
        bar.section = section
        series.chartModels = [bar, dif, dea]
        return series
    }
}

```

**3. 如果现有的线模型无法满足你，你可以新建类继承CHChartModel，重载drawSerie方法。**

```swift

/**
 *  圆点样式模型
 */
open class CHRoundModel: CHChartModel {

    open override func drawSerie(_ startIndex: Int, endIndex: Int) -> CAShapeLayer {
    ......
    }
}

// MARK: - 工厂方法
extension CHChartModel {

    //生成一个圆点样式
    class func getRound(upStyle: (color: UIColor, isSolid: Bool),
                        downStyle: (color: UIColor, isSolid: Bool),
                        titleColor: UIColor, title: String,
                        plotPaddingExt: CGFloat,
                        key: String) -> CHRoundModel {
        let model = CHRoundModel(upStyle: upStyle, downStyle: downStyle,
                                 titleColor: titleColor, plotPaddingExt: plotPaddingExt)
        model.title = title
        model.key = key
        return model
    }
}

```

**4. 自定义自己的图表CHKLineChartStyle，把指标算法和线组加入。**

```swift

    let style = CHKLineChartStyle()
    ......

    //配置图表处理算法
    style.algorithms = [
        CHChartAlgorithm.ema(12),       //计算MACD，必须先计算到同周期的EMA
        CHChartAlgorithm.ema(26),       //计算MACD，必须先计算到同周期的EMA
        CHChartAlgorithm.macd(12, 26, 9),
    ]

    let trendSection = CHSection()
    let macdSeries = CHSeries.getMACD(
        UIColor.ch_hex(0xDDDDDD),
        deac: UIColor.ch_hex(0xF9EE30),
        barc: UIColor.ch_hex(0xF600FF),
        upStyle: upcolor, downStyle: downcolor,
        section: trendSection)
    macdSeries.title = "MACD(12,26,9)"
    macdSeries.symmetrical = true
    trendSection.series = [macdSeries]

    style.sections = [priceSection, volumeSection, trendSection]

    let chartView = CHKLineChartView(frame: CGRect.zero)
    chartView.style = style
    ......

```

**5. 运行程序调试你的指标是否计算对了。**

## Custom Style（开发自定义样式）

通用的方案是，扩展CHKLineChartStyle编写自己的样式。

```swift

// MARK: - 扩展样式
public extension CHKLineChartStyle {
    
    //实现一个最基本的样式，开发者可以自由扩展配置样式
    public static var best: CHKLineChartStyle {
        let style = CHKLineChartStyle()
        ......
        return style
    }

    self.chartView.style = .best
}

```

## Contribution（贡献更多指标）

本人现在很少专注K线图表的开发工作，大部分时间投入到区块链的研究与开发工作，如果你感兴趣，可以[联系我](#Author)。

如果你对本K线指标的开发感兴趣，请fork项目，给大家Pull requests更多技术指标。

## Donations

如果大家觉得非常好用的话，不忘打赏一下小弟，给小弟一些鼓励。

> 支付宝：

![支付宝](/screenshots/donations/alipay.jpeg)

> 微信支付：

![微信支付](/screenshots/donations/wepay.png)

> 接收以下数字货币：

- **BTC**:  16XyEUNgwF3KX6UyMEWtpQDWWXkmqgH7V8
- **ETH**:  0x4fffdaa5dbba850ae41aa6d031a6dffd91614608
- **LTC**:  LLevkg1aUiECvY6Uda1bvDbqa38zykjLyR

## Author
<span id="Author"><span>

- Author: Chance
- Email: zhiquan911@qq.com
- QQ Group：522031421

## License

Released under [MIT License.](https://github.com/zhiquan911/CHKLineChart/blob/master/LICENSE)
