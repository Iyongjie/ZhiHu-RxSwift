//
//  ApiManager.swift
//  ZhiHuDayNews
//
//  Created by 李永杰 on 2018/8/20.
//  Copyright © 2018年 muheda. All rights reserved.
//

import Foundation
import Moya
import HandyJSON
import SVProgressHUD
import RxSwift

let ZHBaseURL = "http://news-at.zhihu.com/api/"

let ZHHomeURL = "4/news/latest"
let ZHHomeMoreURL = "4/news/before/"
let ZHThemeListURL = "4/themes"
let ZHThemeDetailURL = "4/theme/"
let ZHNewsDetailURL = "4/news/"
let ZHNewsDetailExtraURL = "/4/story-extra/"

let LoadingPlugin = NetworkActivityPlugin { (type, target) in
        switch type {
        case .began:
            SVProgressHUD.show()
        case .ended:
            SVProgressHUD.dismiss()
    }
}

let timeoutClosure = {(endpoint: Endpoint, closure: MoyaProvider<ApiManager>.RequestResultClosure) -> Void in
    if var urlRequest = try? endpoint.urlRequest() {
        urlRequest.timeoutInterval = 20
        closure(.success(urlRequest))
    } else {
        closure(.failure(MoyaError.requestMapping(endpoint.url)))
    }
}

let ApiProvider = MoyaProvider<ApiManager>(requestClosure: timeoutClosure, plugins: [LoadingPlugin])

enum ApiManager {
    case getNewsList
    case getMoreNews(String)
    case getThemeList
    case getThemeDesc(Int)
    case getNewsDesc(Int)
    case getNewsExtraURL(Int)
}

extension ApiManager: TargetType {
    var baseURL: URL {
        return URL(string: ZHBaseURL)!
    }
    var task: Task {
        return .requestPlain
    }
    var headers: [String : String]? {
        return ["Content-type": "application/json"]
    }
    var path: String {
        switch self {
        case .getNewsList:
            return ZHHomeURL
        case .getMoreNews(let date):
            return "\(ZHHomeMoreURL)\(date)"
        case .getThemeList:
            return ZHThemeListURL
        case .getThemeDesc(let id):
            return "\(ZHThemeDetailURL)\(id)"
        case .getNewsDesc(let id):
            return "\(ZHNewsDetailURL)\(id)"
        case .getNewsExtraURL(let id):
            return "\(ZHNewsDetailExtraURL)\(id)"
        }
    }
    var method: Moya.Method {
        return .get
    }
    var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }
    var validate: Bool {
        return false
    }
}

//字典转模型
extension Response {
    func mapModel<T: HandyJSON>(_ type: T.Type) throws -> T {
        let jsonString = String(data: data, encoding: .utf8)
        guard let model = JSONDeserializer<T>.deserializeFrom(json: jsonString) else {
            throw MoyaError.jsonMapping(self)
        }
        return model
    }
}
//网络请求扩展，传入任意类型模型，可重用
extension MoyaProvider {
    @discardableResult
    open func request<T: HandyJSON>(_ target: Target,
                                    model: T.Type,
                                    completion: ((_ returnData: T?) -> Void)?) -> Cancellable? {
        return request(target, completion: { (result) in
            guard let completion = completion else { return }
            guard let returnData = try? result.value?.mapModel(model) else {
                completion(nil)
                return
            } 
            completion(returnData)
        })
    }
    
}

//RxSwift+HandyJSON扩展
extension PrimitiveSequence where TraitType == SingleTrait, ElementType == Response {
    func mapModel<T: HandyJSON>(_ type: T.Type) -> Single<T>{
        return flatMap { response -> Single<T> in
            return Single.just(try response.mapModel(T.self))
        }
    }
    
}
























