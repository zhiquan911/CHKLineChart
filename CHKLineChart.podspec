
Pod::Spec.new do |s|
  s.name         = "CHKLineChart"
  s.version      = "1.0.9"
  s.summary      = "纯Swift3.0代码编写的K线图表组件"
  s.description  = <<-DESC
                   纯Swift3.0代码编写的K线图表组件，支持：MA,EMA,KDJ,MACD等技术指标显示。集成使用简单，二次开发扩展强大
                   DESC

  s.homepage     = "https://github.com/zhiquan911/CHKLineChart"
  s.screenshots  = "https://github.com/zhiquan911/CHKLineChart/blob/master/demo.png?raw=true"

  s.license      = "MIT"
  s.author       = { "Chance" => "zhiquan911@qq.com" }
  s.platform     = :ios, "8.0"
  s.ios.deployment_target = '8.0'
  s.source       = { :git => "https://github.com/zhiquan911/CHKLineChart.git", :tag => s.version}
  s.source_files = "CHKLineChart/CHKLineChart/Classes/*.{swift,h,m}"
  s.requires_arc = true


end
