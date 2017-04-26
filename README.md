# CHKLineChart

![demo2.png](https://github.com/zhiquan911/CHKLineChart/blob/master/demo.png)

> 纯Swift3.0代码编写的K线图表组件，支持：MA,EMA,KDJ,MACD等技术指标显示。集成使用简单，二次开发扩展强大。

## Features

- 完美支持Swift3.0编译
- 支持显示蜡烛图，交易量图，及MA,EMA,KDJ,MACD等技术指标图表
- 支持使用代码创建视图或使用xib/storyboard创建视图
- 集成使用简单，二次开发扩展强大


## Requirements

- iOS 8+
- Xcode 8+
- Swift 3.0+
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

pod 'CHKLineChart'
```

##Example

把项目classes文件夹导入到项目或采用cocoaPos集成，在使用的viewController，导入框架

```swift

import CHKLineChart

```

```swift
var chartView: CHKLineChartView!

override func viewDidLoad() {
    self.chartView = CHKLineChartView()
    self.chartView.style = .base       //默认样式
    self.chartView.delegate = self
    self.chartView.frame = self.view.bounds
    self.view.addSubview(self.chartView)
}
```

实现图表的数据源代理方法

```swift
func numberOfPointsInKLineChart(_ chart: CHKLineChartView) -> Int {
    return self.klineDatas.count
}

func kLineChart(_ chart: CHKLineChartView, valueForPointAtIndex index: Int) -> CHChartItem {
    let data = self.klineDatas[index] as! [Double]
    let item = CHChartItem()
    item.time = Int(data[0] / 1000)
    item.openPrice = CGFloat(data[1])
    item.highPrice = CGFloat(data[2])
    item.lowPrice = CGFloat(data[3])
    item.closePrice = CGFloat(data[4])
    item.vol = CGFloat(data[5])
    return item
}

func kLineChart(_ chart: CHKLineChartView, labelOnYAxisForValue value: CGFloat, section: CHSection) -> String {
    var strValue = ""
    if value / 10000 > 1 {
        strValue = (value / 10000).ch_toString(maxF: 2) + "万"
    } else {
        strValue = value.ch_toString(maxF: 2)
    }
    return strValue
}
    
func kLineChart(_ chart: CHKLineChartView, labelOnXAxisForIndex index: Int) -> String {
    let data = self.klineDatas[index] as! [Double]
    let timestamp = Int(data[0])
    return Date.getTimeByStamp(timestamp, format: "HH:mm")
}

/// 点击图标返回点击的位置和数据对象
///
/// - Parameters:
///   - chart:
///   - index:
///   - item: 
func kLineChart(chart: CHKLineChartView, didSelectAt index: Int, item: CHChartItem) {
    NSLog("selected index = \(index)")
    NSLog("selected item closePrice = \(item.closePrice)")
}

```

自定义样式例子，查看CustomStyleViewController里面的实现代码

更详细集成方法，根据实际的例子请查看源代码中的demo

## Author

- Author:Chance 
- Email:zhiquan911@qq.com
- QQ:76405896
- Wechat:zhiquan911

## Donations

为了让开发者更积极分享技术，开源程序代码，我们发起数字货币捐助计划，捐款只接收以下货币。

- **BTC Address**:  3G4NdQQyCJK1RS5URb4h5KogWEyR4Mk16A

## License

Released under [MIT License.](https://github.com/zhiquan911/CHKLineChart/blob/master/LICENSE) 
