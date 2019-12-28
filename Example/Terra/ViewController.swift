//
//  ViewController.swift
//  Terra
//
//  Created by DATree on 12/26/2019.
//  Copyright (c) 2019 DATree. All rights reserved.
//

import UIKit
import Terra
import Moya
import ObjectMapper
import RxSwift
import ReactiveSwift

enum AccountAPI {
    case login(account: String, password: String)
    case logout(account: String)
}

extension AccountAPI: TargetType {
    
    var baseURL: URL {
        return URL(string: "https://www.google.com")!
    }
    
    var path: String {
        switch self {
        case .login:
            return "/account/login"
        case .logout:
            return "/account/logout"
        }
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var task: Moya.Task {
        var parameters = [String: Any]()
        switch self {
        case let .login(account, password):
            parameters["account"] = account
            parameters["password"] = password
        case let .logout(account):
            parameters["account"] = account
        }
        return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
    }
    
    var headers: [String : String]? {
        return [:]
    }
}

struct Account: ImmutableMappable {
    
    var userID: String
    var name: String?
    var phone: String?
    var gender: Int?
    
    init(map: Map) throws {
        userID = try map.value("id")
        name = try? map.value("name")
        phone = try? map.value("phone")
        gender = try? map.value("gender")
    }
}

class ViewController: UIViewController {
    
    let provider = AccountAPI.adapter()
    let disposeBag = DisposeBag()
    
    private func fetchData() {
        
        login { (account) in
            // Reload UI with account
        }
        
        provider.rx.requestModel(Account.self, token: .logout(account: ""))
            .asObservable()
            .takeLast(1)
            .observeOn(MainScheduler.instance)
            .subscribe { (event) in
                print(event.debugDescription)
        }.disposed(by: disposeBag)
        
        provider.rx.requestModel(Account.self, token: .logout(account: "xx"))
            .subscribe(onSuccess: { (account) in
                print(account)
        }) { (error) in
            print(error.localizedDescription)
        }.disposed(by: disposeBag)
        
        provider.reactive.requestModel(Account.self, token: .logout(account: ""))
            .start { [weak self] (event) in
                switch event {
                case .value(let account):
                    print(account.toJSON().debugDescription)
                case .failed(let error):
                    error.display(on: self?.view)
                default: break
                }
        }
    }
    
    func login(completion: @escaping (Account) -> Void) {
        provider.te.requestModel(Account.self,
                                 target: .login(account: "xx", password:"xx"))
        { [weak self] (result) in
            switch result {
            case .success(let account):
                print(account.toJSON().debugDescription)
                completion(account)
            case .failure(let error):
                error.display(on: self?.view)
            }
        }
    }

}

