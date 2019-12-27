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

enum API {
    case login(account: String, password: String)
    case logout(account: String)
}

extension API: TargetType {
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
    
    let provider = API.adapter()
    let disposeBag = DisposeBag()
    
    private func fetchData() {
        
        login { (account) in
            // Reload UI with account
        }
        
        login().subscribe { (event) in
            print(event.element.debugDescription)
        }.disposed(by: disposeBag)
    }
    
    func login(completion: @escaping (Account) -> Void) {
        provider.te.requestModel(Account.self, target: .login(account: "xx", password:"xx")) { (result) in
            switch result {
            case .success(let account):
                print(account.toJSON().debugDescription)
                completion(account)
            case .failure(let error):
                error.display()
            }
        }
    }
    
    func login() -> Observable<Account> {
        return provider.rx.requestModel(.login(account: "xx", password:"xx"))
    }
}

