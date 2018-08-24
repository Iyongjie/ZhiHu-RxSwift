//
//  DetailWebView.swift
//  ZhiHuDayNews
//
//  Created by 李永杰 on 2018/8/23.
//  Copyright © 2018年 muheda. All rights reserved.
//

import UIKit
import WebKit

class DetailWebView: WKWebView {
    var img = UIImageView().then { (make) in
        make.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 200)
        make.contentMode = .scaleAspectFill
        make.clipsToBounds = true
    }
    var maskImg = UIImageView().then { (make) in
        make.frame = CGRect(x: 0, y: 100, width: ScreenWidth, height: 100)
        make.image = UIImage(named: "Home_Image_Mask")
    }
    var titleLabel = UILabel().then { (make) in
        make.frame = CGRect(x: 15, y: 150, width: ScreenWidth - 30, height: 26)
        make.font = UIFont.boldSystemFont(ofSize: 21)
        make.numberOfLines = 2
        make.textColor = .white
    }
    var imgLabel: UILabel = {
        let lab = UILabel()
        lab.frame = CGRect(x: 15, y: 180, width: ScreenWidth - 30, height: 16)
        lab.font = UIFont.boldSystemFont(ofSize: 10)
        lab.textAlignment = .right
        lab.textColor = .white
        return lab
    }()
    
    var previousLab = UILabel().then { (make) in
        make.frame = CGRect(x: 15, y: -38, width: ScreenWidth - 30, height: 20)
        make.font = UIFont.systemFont(ofSize: 15)
        make.text = "载入上一篇"
        make.textAlignment = .center
        make.textColor = UIColor.colorFromHex(0x777777)
    }
    var nextLab = UILabel().then { (make) in
        make.frame = CGRect(x: 15, y: ScreenHeight + 30, width: ScreenHeight - 30, height: 20)
        make.font = UIFont.systemFont(ofSize: 15)
        make.text = "载入上一篇"
        make.textAlignment = .center
        make.textColor = UIColor.colorFromHex(0x777777)
    }
    var waitView = UIView().then { (make) in
        
    }
    
    
    
    
    
    
}
