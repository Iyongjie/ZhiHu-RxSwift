//
//  BannerCell.swift
//  ZhiHuDayNews
//
//  Created by 李永杰 on 2018/8/21.
//  Copyright © 2018年 muheda. All rights reserved.
//

import UIKit
import SnapKit
import Then

class BannerCell: UICollectionViewCell {
 
    let img = UIImageView().then {_ in
    }
    
    private let maskImg = UIImageView().then {
        $0.image = UIImage(named: "Home_Image_Mask")
    }
    
    let titleLab = UILabel().then {
        $0.textAlignment = .center
        $0.textColor = .white
        $0.font = UIFont.boldSystemFont(ofSize: 21)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   private func configUI() {
        self.contentView.addSubview(img)
        img.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
        
        self.contentView.addSubview(maskImg)
        maskImg.snp.makeConstraints({ (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(self.contentView.frame.size.height/2)
        })
        
        self.contentView.addSubview(titleLab)
        titleLab.snp.makeConstraints { (make) in
            make.leading.equalTo(8)
            make.right.equalTo(-8)
            make.bottom.equalTo(-20)
            make.height.equalTo(50)
        }
    }
    
}
