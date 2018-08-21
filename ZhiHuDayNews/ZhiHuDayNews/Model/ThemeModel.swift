//
//  ThemeModel.swift
//  ZhiHuDayNews
//
//  Created by 李永杰 on 2018/8/20.
//  Copyright © 2018年 muheda. All rights reserved.
//

import Foundation
import HandyJSON

struct ThemeModel: HandyJSON {
    var limit:String?
    var subscribed:[Any]?
    var others:[OtherModel]?
}

struct OtherModel:HandyJSON {
    var color:String?
    var thumbnail:String?
    var description:String?
    var name:String?
    var id:Int?
}
