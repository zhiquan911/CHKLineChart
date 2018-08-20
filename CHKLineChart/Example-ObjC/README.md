#背景：kline绘制开源框架是用swift语言来实现的。OC项目中直接调用存在问题，本实例是用以解决此问题。

#存在问题：OC项目不能直接使用swift框架，问题在于框架中部分属性不能被OC调用。如果在框架中添加@objc来修饰，也不能完全解决问题。

#解决思路：可以先使用swift将kline绘制框架进行一层包装，实现过程中要注意暴露出来的属性、方法采用@objc修饰，能被OC调用。然后OC项目调用包装好的类。

#涉及问题：
##1、OC项目通常采用cocoapods来进行包管理，实例中kline绘制框架也同样如此。
##2、封装的swfit类需要调用OC中的模型（当然也可以用swift来实现此数据模型），存在swift调用OC代码的情况。
##3、封装好的swift类会在OC方法中调用，存在OC调用swift代码的情况。

#友情链接：
##OC使用cocoapods导入swift库注意（https://blog.csdn.net/flowerr_/article/details/77506114）
##OC项目中使用Swift（https://blog.csdn.net/mengxiangyue/article/details/50753839）
##iOS OC项目调用Swift类（https://blog.csdn.net/u010407865/article/details/62886943）
##王巍大神的 @OBJC和DYNAMIC（http://swifter.tips/objc-dynamic/）
##swift: @objc的使用（https://blog.csdn.net/apple_app/article/details/51208824）
