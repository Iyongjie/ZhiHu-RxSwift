//
//  HomeModel.swift
//  ZhiHuDayNews
//
//  Created by 李永杰 on 2018/8/20.
//  Copyright © 2018年 muheda. All rights reserved.
//

import Foundation
import HandyJSON

struct HomeModel: HandyJSON {
    var date:String?
    var stories:[StoryModel]?
    var top_stories:[StoryModel]?
}

struct StoryModel: HandyJSON {
    var images:[String]?
    var type:Int?
    var id:Int?
    var ga_prefix:String?
    var title:String?
    var image:String?
    var multipic: Bool?

}
