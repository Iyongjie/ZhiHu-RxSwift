//
//  RefreshView.swift
//  ZhiHuDayNews
//
//  Created by 李永杰 on 2018/8/22.
//  Copyright © 2018年 muheda. All rights reserved.
//

import UIKit

class RefreshView: UIView {

    let circleLayer = CAShapeLayer()
    let indicatorView = UIActivityIndicatorView().then {
        $0.frame = CGRect(x: 0, y: 0, width: 16, height: 16)
    }
    fileprivate var refreshing = false
    fileprivate var endRef = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createCircleLayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        circleLayer.position = CGPoint(x: frame.width/2, y: frame.height/2)
        indicatorView.center = CGPoint(x: frame.width/2, y: frame.height/2)
    }
    
    private func createCircleLayer() {
        circleLayer.path = UIBezierPath(arcCenter: CGPoint(x: 8, y: 8), radius: 8, startAngle: CGFloat(Double.pi), endAngle: CGFloat(Double.pi + 2*Double.pi), clockwise: true).cgPath
        circleLayer.strokeColor = UIColor.white.cgColor
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeStart = 0.0
        circleLayer.strokeEnd = 0.0
        circleLayer.lineWidth = 1.0
        circleLayer.lineCap = kCALineCapRound
        circleLayer.bounds = CGRect(x: 0, y: 0, width: 16, height: 16)
        circleLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        layer.addSublayer(circleLayer)
        
    }
}

extension RefreshView {
    //向下拖拽视图准备刷新的过程会响应
    func pullToRefresh(progress: CGFloat) {
        circleLayer.strokeEnd = progress
    }
    //开始刷新
    func beginRefresh(begin: @escaping () -> Void) {
        if refreshing {
            //防止刷新未结束又开始刷新
            return
        }
        refreshing = true
        circleLayer.removeFromSuperlayer()
        addSubview(indicatorView)
        indicatorView.startAnimating()
        begin()
    }
    //结束刷新
    func endRefresh() {
        refreshing = false
        indicatorView.stopAnimating()
        indicatorView.removeFromSuperview()
    }
    //重制刷新控件
    func resetLayer() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.createCircleLayer()
        }
    }
}



















