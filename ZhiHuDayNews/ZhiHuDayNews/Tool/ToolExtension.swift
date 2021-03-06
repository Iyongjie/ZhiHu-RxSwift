//
//  ToolExtension.swift
//  ZhiHuDayNews
//
//  Created by 李永杰 on 2018/8/20.
//  Copyright © 2018年 muheda. All rights reserved.
//

import UIKit


let ScreenWidth = UIScreen.main.bounds.size.width
let ScreenHeight = UIScreen.main.bounds.size.height
let NavHeight = ScreenHeight == 812 ? 88: 64

extension UIColor {
    static func rgb(_ r: CGFloat,_ g: CGFloat,_ b: CGFloat) -> UIColor {
        return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: 1.0)
    }
    static func colorFromHex(_ hex: UInt32) -> UIColor {
        return UIColor(red: CGFloat((hex & 0xFF0000) >> 16)/255.0, green: CGFloat((hex & 0xFF00) >> 8)/255.0, blue: CGFloat((hex & 0xFF))/255.0, alpha: 1.0)
    }
}

extension Int {
    func toWeekday() -> String {
        switch self {
        case 2:
            return "星期一"
        case 3:
            return "星期二"
        case 4:
            return "星期三"
        case 5:
            return "星期四"
        case 6:
            return "星期五"
        case 7:
            return "星期六"
        case 1:
            return "星期日"
        default:
            return  ""
        }
     }
}


