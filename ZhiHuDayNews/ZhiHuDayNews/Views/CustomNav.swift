//
//  CustomNav.swift
//  ZhiHuDayNews
//
//  Created by 李永杰 on 2018/8/22.
//  Copyright © 2018年 muheda. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift

class CustomNav: UIView {

    let disposeBag = DisposeBag()
    
    var navTitle = Variable("今日要闻")
 
    let sideButton = UIButton().then {
        $0.setImage(UIImage(named: "menu"), for: .normal)
    }
    let titleLab = UILabel().then {
        $0.textColor = .white
        $0.font = UIFont.boldSystemFont(ofSize: 18)
        $0.textAlignment = .center
    }
    let refreshView = RefreshView().then {_ in
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
        self.titleLab.text = navTitle.value
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configUI() {
        self.addSubview(sideButton)
        self.addSubview(titleLab)
        
        sideButton.snp.makeConstraints { (make) in
            make.leading.equalTo(8)
            make.width.height.equalTo(44)
            make.centerY.equalTo(titleLab)
        }
        
        let titleWidth = self.textSize(text: navTitle.value, font: UIFont.boldSystemFont(ofSize: 18), maxSize: CGSize(width: 240, height: CGFloat(MAXFLOAT))).width + 20
        titleLab.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-10)
            make.width.equalTo(titleWidth)
            make.height.equalTo(20)
        }
        self.addSubview(refreshView)
        refreshView.snp.makeConstraints { (make) in
            make.right.equalTo(titleLab.snp.left).offset(-8)
            make.centerY.equalTo(titleLab)
            make.width.height.equalTo(40)
        }
        
        navTitle
            .asObservable()
            .distinctUntilChanged()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (text) in
                self.titleLab.text = text
                
                let titleWidth = self.textSize(text: self.navTitle.value, font: UIFont.boldSystemFont(ofSize: 18), maxSize: CGSize(width: 240, height: CGFloat(MAXFLOAT))).width + 20
                self.titleLab.snp.remakeConstraints({ (make) in
                    make.centerX.equalToSuperview()
                    make.bottom.equalToSuperview().offset(-10)
                    make.width.equalTo(titleWidth)
                    make.height.equalTo(20)
                })
            })
            .disposed(by: disposeBag)
        
    }

    //方法
    func textSize(text : String , font : UIFont , maxSize : CGSize) -> CGSize{
        return text.boundingRect(with: maxSize, options: [.usesLineFragmentOrigin], attributes: [NSAttributedStringKey.font : font], context: nil).size
    }

}
