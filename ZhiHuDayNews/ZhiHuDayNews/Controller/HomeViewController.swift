//
//  ViewController.swift
//  ZhiHuDayNews
//
//  Created by 李永杰 on 2018/8/17.
//  Copyright © 2018年 muheda. All rights reserved.
//

import UIKit
import Then
import Moya
import RxSwift
import RxCocoa
import RxDataSources
import ZCycleView

class HomeViewController: UIViewController {
    
    //MARK: property
    
    var newsDate = ""
    let dataArr = Variable([SectionModel<String,StoryModel>]())
    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String,StoryModel>>(configureCell: {(dataSource,tv,indexPath,model) in
        let cell = tv.dequeueReusableCell(withIdentifier: "homeListCellId") as! HomeListTableViewCell
        cell.titleLab.text = model.title
        cell.imageV.kf.setImage(with: URL(string: (model.images?.first)!))
        cell.moreV.isHidden = !(model.multipic ?? false)
        return cell
    })
    let disposeBag = DisposeBag()
    
    var navView: CustomNav = {
        let nav = CustomNav(frame: CGRect(x: 0, y: 0, width: Int(ScreenWidth), height: NavHeight))
        return nav
    }()
    var bannerView: ZCycleView = {
        let banner = ZCycleView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenWidth*200/375))
        banner.scrollDirection = .horizontal
        banner.timeInterval = 2
        banner.isAutomatic = true
        banner.isInfinite = true
        return banner
    }()
    var homeTableView:UITableView = {
        let table = UITableView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight), style: .plain)
        table.register(HomeListTableViewCell.self, forCellReuseIdentifier: "homeListCellId")
        return table
    }()
    //MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestData()
        
        self.view.addSubview(homeTableView)
        if #available(iOS 11.0, *) {
            homeTableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        homeTableView.tableHeaderView = bannerView
        bannerView.delegate = self
        self.view.addSubview(navView)
        
        dataArr
            .asObservable()
        .bind(to: homeTableView.rx.items(dataSource: dataSource))
        .disposed(by: disposeBag)
        
        homeTableView
            .rx
            .modelSelected(StoryModel.self)
            .subscribe(onNext: { (model) in
                self.homeTableView.deselectRow(at: self.homeTableView.indexPathForSelectedRow!, animated: true)
  
            })
            .disposed(by: disposeBag)
        
        homeTableView
            .rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        return .lightContent
    }

    //MARK: private func
    private func requestData() { 
        ApiProvider
            .rx
            .request(ApiManager.getNewsList).mapModel(HomeModel.self)
            .subscribe(onSuccess: { (model) in
                self.dataArr.value = [SectionModel(model: model.date!, items: model.stories!)]
                var imgArr = [String]()
                var titleArr = [String]()
                for story in model.top_stories! {
                    imgArr.append(story.image!)
                    titleArr.append(story.title!)
                }
                self.bannerView.setUrlsGroup(imgArr, titlesGroup: titleArr)
                self.newsDate = model.date!
            })
            .disposed(by: disposeBag)
    }
    private func requestMoreData() {
        ApiProvider
            .rx
            .request(ApiManager.getMoreNews(newsDate))
            .mapModel(HomeModel.self)
            .subscribe(onSuccess: { (model) in
                    self.dataArr.value.append(SectionModel(model: model.date!, items: model.stories!))
                    self.newsDate = model.date!
            })
            .disposed(by: disposeBag)
    }

}


extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
}

extension HomeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) { 
        navView.backgroundColor = UIColor.colorFromHex(0x3F8DD0).withAlphaComponent(scrollView.contentOffset.y / 200)

    }
}

extension HomeViewController: ZCycleViewProtocol {
    func cycleViewDidScrollToIndex(_ index: Int) {
        print("滚动到了\(index+1)图片")
    }
    func cycleViewDidSelectedIndex(_ index: Int) {
        print("点击了\(index+1)图片")
    }
}




