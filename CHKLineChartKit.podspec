
Pod::Spec.new do |s|
  s.name         = "CHKLineChartKit"
  s.version      = "2.3.1"
  s.summary      = "纯Swift4.0代码编写的K线图表组件"
  s.description  = <<-DESC
                   纯Swift4.0代码编写的K线图表组件，支持：MA,EMA,KDJ,MACD等技术指标显示。集成使用简单，二次开发扩展强大
                   DESC

  s.homepage     = "https://github.com/zhiquan911/CHKLineChart"
  s.screenshots  = "https://raw.githubusercontent.com/zhiquan911/CHKLineChart/master/screenshots/s1.png"

  s.license      = "MIT"
  s.author       = { "Chance" => "zhiquan911@qq.com" }
  s.platform     = :ios, "8.0"
  s.ios.deployment_target = '8.0'
  s.source       = { :git => "https://github.com/zhiquan911/CHKLineChart.git", :tag => s.version}
  s.source_files = "CHKLineChart/CHKLineChart/Classes/*.{swift,h,m}"
  s.requires_arc = true


end

#提交命令：pod trunk push CHKLineChartKit.podspec
