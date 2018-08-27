//
//  NewsDetailModel.swift
//  ZhiHuDayNews
//
//  Created by 李永杰 on 2018/8/24.
//  Copyright © 2018年 muheda. All rights reserved.
//

import Foundation
import HandyJSON

struct NewsDetailModel: HandyJSON {
    
    var body: String?
    var image_source: String?
    var title: String?
    var image: String?
    var share_url: String?
    var js: [Any]?
    var ga_prefix: String?
    var images: [String]?
    var type: Int?
    var id: Int?
    var css: [String]?
     
}
