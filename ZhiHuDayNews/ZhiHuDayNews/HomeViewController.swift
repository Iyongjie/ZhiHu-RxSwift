//
//  ViewController.swift
//  ZhiHuDayNews
//
//  Created by 李永杰 on 2018/8/17.
//  Copyright © 2018年 muheda. All rights reserved.
//

import UIKit
import Then

class HomeViewController: UIViewController {
    var storiesArr = [StoryModel]()
    var top_stories = [StoryModel]()
  
    var bannerView: BannerView = {
        let lay = UICollectionViewFlowLayout()
        lay.itemSize = CGSize(width: ScreenWidth, height: 200)
        lay.scrollDirection = .horizontal
        lay.minimumLineSpacing = 0
        lay.minimumInteritemSpacing = 0
        let banner = BannerView(frame: CGRect(x: 0, y: 100, width: ScreenWidth, height: 200), collectionViewLayout: lay)
        return banner
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(bannerView)
        ApiProvider.request(ApiManager.getNewsList, model: HomeModel.self) { [weak self] (resultData) in
            self?.storiesArr = (resultData?.stories)!
            self?.top_stories = (resultData?.top_stories)!
            self?.bannerView.modelArr.value = (resultData?.top_stories)!
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

