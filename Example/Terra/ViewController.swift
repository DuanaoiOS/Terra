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
        return .requestPlain
    }
    
    var headers: [String : String]? {
        return [:]
    }
}

struct Account: ImmutableMappable {
    var userID: String
    var name: String?
    
    init(map: Map) throws {
        userID = try map.value("id")
        name = try? map.value("name")
    }
}

class ViewController: UIViewController {
    
    lazy var provider = API.adapter()
    
    private func fetchData() {
        provider.te.requestModel(.logout(account: "xx")) { (result: Result<Account, MoyaError>) in
            switch result {
            case .success(let account):
                print(account.toJSON().debugDescription)
                // Reload UI with account
            case .failure(let error):
                error.display()
            }
        }
    }
}

