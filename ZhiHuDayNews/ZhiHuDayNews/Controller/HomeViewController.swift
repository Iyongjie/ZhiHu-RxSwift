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
    
    //MARK: 属性
    var newsDate = ""
    var titleNum = Variable(0)
    
    var dataArr = Variable([SectionModel<String,StoryModel>]())
    var bannerArr = [StoryModel]()
    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String,StoryModel>>(configureCell: {(dataSource,tv,indexPath,model) in
        let cell = tv.dequeueReusableCell(withIdentifier: "homeListCellId") as! HomeListTableViewCell
        cell.titleLab.text = model.title
        cell.imageV.kf.setImage(with: URL(string: (model.images?.first)!))
        cell.moreV.isHidden = !(model.multipic ?? false)
        return cell
    })
    let disposeBag = DisposeBag()
    
    lazy var navView: CustomNav = {
        let nav = CustomNav(frame: CGRect(x: 0, y: 0, width: Int(ScreenWidth), height: NavHeight))
        return nav
    }()
    lazy var bannerView: ZCycleView = {
        let banner = ZCycleView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenWidth*200/375))
        banner.scrollDirection = .horizontal
        banner.timeInterval = 2
        banner.isAutomatic = true
        banner.isInfinite = true
        banner.imageContentMode = .scaleAspectFill
        return banner
    }()
    lazy var homeTableView:UITableView = {
        let table = UITableView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight), style: .plain)
        table.register(HomeListTableViewCell.self, forCellReuseIdentifier: "homeListCellId")
        return table
    }()
    //MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            homeTableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        //MARK: 请求数据,添加视图
        requestData()
        self.view.addSubview(homeTableView)
        homeTableView.tableHeaderView = bannerView
        bannerView.delegate = self
        self.view.addSubview(navView)
        
        //MARK: 配置rx
        configRxTable()
        
        dataArr
            .asObservable()
        .bind(to: homeTableView.rx.items(dataSource: dataSource))
        .disposed(by: disposeBag)
        
        titleNum
            .asObservable()
            .distinctUntilChanged()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (num) in
                if num == 0 {
                    self.navView.navTitle.value = "今日要闻"
                } else {
                    if let date = DateInRegion.init(self.dataSource[num].model, formats: ["yyyyMMdd"]){
                     self.navView.navTitle.value = "\(date.month)月\(date.day)日\(date.weekday.toWeekday())"
                    }
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
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }

    //MARK: 私有方法
    private func configRxTable() {
        //UITableViewDelegate
        
        homeTableView
            .rx
            .modelSelected(StoryModel.self)
            .subscribe(onNext: { (model) in
                self.homeTableView.deselectRow(at: self.homeTableView.indexPathForSelectedRow!, animated: true)
                let web = DetailViewController()
                self.dataArr.value.forEach { (sectionModel) in
                    sectionModel.items.forEach({ (storyModel) in
                        web.idArr.append(storyModel.id!)
                    })
                }
                web.id = model.id!
                self.navigationController?.pushViewController(web, animated: true)
            })
            .disposed(by: disposeBag)
        homeTableView
            .rx
            .willDisplayCell
            .subscribe(onNext: { cell,indexPath in
                if indexPath.section == self.dataArr.value.count - 1 && indexPath.row == 0 {
                    self.requestMoreData()
                }
                self.titleNum.value = (self.homeTableView.indexPathsForVisibleRows?.reduce(Int.max) { (result, ind) -> Int in return min(result, ind.section) })!
            })
            .disposed(by: disposeBag)
         
        homeTableView
            .rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        //UIScrollViewDelegate
        homeTableView
        .rx
        .didScroll
            .subscribe(onNext:{
                    self.navView.backgroundColor = UIColor.colorFromHex(0x3F8DD0).withAlphaComponent(self.homeTableView.contentOffset.y / 200)
                    self.navView.refreshView.pullToRefresh(progress: -self.homeTableView.contentOffset.y / 64)
            })
        .disposed(by: disposeBag)
        
        homeTableView
        .rx
        .didEndDecelerating
            .subscribe(onNext: {
                self.navView.refreshView.resetLayer()
            })
        .disposed(by: disposeBag)
        
        homeTableView
        .rx
        .didEndDragging
            .subscribe({_ in
                if self.homeTableView.contentOffset.y <= -64 {
                    self.navView.refreshView.beginRefresh {
                        self.requestData()
                    }
                }
            })
        .disposed(by: disposeBag)
        
    }
    
    private func requestData() {

        ApiProvider
            .rx
            .request(ApiManager.getNewsList)
            .mapModel(HomeModel.self)
            .subscribe(onSuccess: { (model) in
                self.dataArr.value = [SectionModel(model: model.date!, items: model.stories!)]
                var imgArr = [String]()
                var titleArr = [String]()
                for story in model.top_stories! {
                    imgArr.append(story.image!)
                    titleArr.append(story.title!)
                }
                self.bannerArr = model.top_stories!
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

//RxSwift没有tableview相关方法，用原生实现
extension HomeViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section > 0 {
            return UILabel().then {
                $0.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 38)
                $0.backgroundColor = UIColor.rgb(63, 141, 208)
                $0.textColor = .white
                $0.font = UIFont.systemFont(ofSize: 15)
                $0.textAlignment = .center
                
                if let date = DateInRegion.init(self.dataSource[section].model, formats: ["yyyyMMdd"]) {
                    $0.text = "\(date.month)月\(date.day)日\(date.weekday.toWeekday())"
                }
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

extension HomeViewController: ZCycleViewProtocol {
    func cycleViewDidScrollToIndex(_ index: Int) {
        
    }
    func cycleViewDidSelectedIndex(_ index: Int) {
        let model = self.bannerArr[index]
        let web = DetailViewController()
        self.bannerArr.forEach { (storyModel) in
            web.idArr.append(storyModel.id!)
        }
        web.id = model.id!
        self.navigationController?.pushViewController(web, animated: true)
    }
}




