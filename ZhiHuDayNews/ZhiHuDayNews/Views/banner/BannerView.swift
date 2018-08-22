//
//  BannerView.swift
//  ZhiHuDayNews
//
//  Created by 李永杰 on 2018/8/21.
//  Copyright © 2018年 muheda. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Kingfisher

protocol BannerDelegate {
    func selectedItem(model: StoryModel)
    func scrollTo(index: Int)
}

class BannerView: UICollectionView {

    let modelArr = Variable([StoryModel]())
    let disposeBag = DisposeBag()
    let offY = Variable(0.0)
    var bannerDelegate: BannerDelegate?
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        self.register(BannerCell.self, forCellWithReuseIdentifier: "BannerCell")
        
        configUI()
        //初始化属性
        isPagingEnabled = true
        showsHorizontalScrollIndicator = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configUI () {
    
        contentOffset.x = ScreenWidth
        modelArr
            .asObservable()
            .bind(to: rx.items(cellIdentifier: "BannerCell",cellType: BannerCell.self)) {
                row, model, cell in

                cell.img.kf.setImage(with: URL(string: model.image!))
                cell.titleLab.text = model.title
        }
        .disposed(by: disposeBag)
        
        rx.setDelegate(self as UIScrollViewDelegate).disposed(by: disposeBag)

        offY
        .asObservable()
            .subscribe(onNext: { (offy) in
                self.visibleCells.forEach({ (cell) in
                    let cell = cell as! BannerCell
                    cell.img.frame.origin.y = CGFloat.init(offy)
                    cell.img.frame.size.height = 200 - CGFloat.init(offy)
                })
            })
        .disposed(by: disposeBag)
        
        rx
            .modelSelected(StoryModel.self)
            .subscribe(onNext: { (model) in
                self.bannerDelegate?.selectedItem(model: model)
            })
            .disposed(by: disposeBag)
    }
}

extension BannerView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x == CGFloat.init(modelArr.value.count - 1) * ScreenWidth {
            scrollView.contentOffset.x = ScreenWidth
        }
        else if scrollView.contentOffset.x == 0 {
            scrollView.contentOffset.x = CGFloat.init(modelArr.value.count - 2) * ScreenWidth
        }
        bannerDelegate?.scrollTo(index: Int(scrollView.contentOffset.x / ScreenWidth) - 1)
    }
    
}













