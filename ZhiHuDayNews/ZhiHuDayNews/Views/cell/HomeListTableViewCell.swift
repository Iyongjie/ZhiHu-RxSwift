//
//  HomeListTableViewCell.swift
//  ZhiHuDayNews
//
//  Created by 李永杰 on 2018/8/22.
//  Copyright © 2018年 muheda. All rights reserved.
//

import UIKit

class HomeListTableViewCell: UITableViewCell {

    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .black
        lab.font = UIFont.systemFont(ofSize: 15)
        lab.textAlignment = .left
        lab.numberOfLines = 0
        return lab
    }()
    
    lazy var imageV: UIImageView = {
        let iv = UIImageView()
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    lazy var moreV: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.image = UIImage(named: "Home_Morepic")
        return iv
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configUI() {
        self.contentView.addSubview(titleLab)
        self.contentView.addSubview(imageV)
        imageV.addSubview(moreV)
        imageV.snp.makeConstraints { (make) in
            make.width.equalTo(75)
            make.height.equalTo(60)
            make.right.equalTo(-15)
            make.centerY.equalToSuperview()
        }
        titleLab.snp.makeConstraints { (make) in
            make.top.leading.equalTo(15)
            make.right.lessThanOrEqualTo(imageV.snp.left)
        }
        moreV.snp.makeConstraints { (make) in
            make.bottom.right.equalToSuperview()
            make.width.equalTo(32)
            make.height.equalTo(14)
        }
    }
}
