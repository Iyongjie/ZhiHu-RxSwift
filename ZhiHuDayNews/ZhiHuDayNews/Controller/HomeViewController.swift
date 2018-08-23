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
import SwiftDate

class HomeViewController: UIViewController {
    
    //MARK: property
    
    var newsDate = ""
    var titleNum = Variable(0)
    
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
        banner.imageContentMode = .scaleAspectFill
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
        
        titleNum
            .asObservable()
            .distinctUntilChanged()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (num) in
                if num == 0 {
                    self.navView.titleLab.text = "今日要闻"
                } else {
                    self.navView.titleLab.text = self.dataSource[num].model
                }
            })
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
                self.navView.refreshView.endRefresh()
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
        if indexPath.section == dataArr.value.count - 1 && indexPath.row == 0 {
            requestMoreData()
        }
        self.titleNum.value = (tableView.indexPathsForVisibleRows?.reduce(Int.max) { (result, ind) -> Int in return min(result, ind.section) })!

    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section > 0 {
            return UILabel().then {
                $0.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 38)
                $0.backgroundColor = UIColor.rgb(63, 141, 208)
                $0.textColor = .white
                $0.font = UIFont.systemFont(ofSize: 15)
                $0.textAlignment = .center
                $0.text = self.dataSource[section].model
            }
        }
        return UIView()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return 38
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
}

extension HomeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) { 
        navView.backgroundColor = UIColor.colorFromHex(0x3F8DD0).withAlphaComponent(scrollView.contentOffset.y / 200)
        navView.refreshView.pullToRefresh(progress: -scrollView.contentOffset.y / 64)
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.contentOffset.y <= -64 {
            navView.refreshView.beginRefresh {
                self.requestData()
            }
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        navView.refreshView.resetLayer()
    }
}

extension HomeViewController: ZCycleViewProtocol {
    func cycleViewDidScrollToIndex(_ index: Int) {
        
    }
    func cycleViewDidSelectedIndex(_ index: Int) {
        print("点击了\(index)张图片")
    }
}




