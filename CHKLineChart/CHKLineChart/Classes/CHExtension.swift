//
//  CHExtension.swift
//  CHKLineChart
//
//  Created by 麦志泉 on 16/9/8.
//  Copyright © 2016年 bitbank. All rights reserved.
//

import Foundation
import UIKit

//String类扩展
extension String {
    
    /**
     计算文字的宽度
     
     - parameter width:
     - parameter font:
     
     - returns:
     */
    func ch_heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGSize {
        let constraintRect = CGSize(width: width, height: CGFloat.max)
        let boundingBox = self.boundingRectWithSize(constraintRect, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        return boundingBox.size
    }
    
}
