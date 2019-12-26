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

enum API {
    case one
}

extension API: TargetType {
    var baseURL: URL {
        return URL(string: "https://www.google.com")!
    }
    
    var path: String {
        return ""
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Moya.Task {
        return .requestPlain
    }
    
    var headers: [String : String]? {
        return [:]
    }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        API.adapter()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

