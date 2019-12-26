//
//  ServerResponse.swift
//  Terra
//
//  Created by DATree on 2019/12/26.
//

import Foundation

public protocol ServerResponse {
    var codeKey: String {get set}
    var messageKey: String {get set}
    var messageTypeKey: String {get set}
    var bodyKey: String {get set}
    var successCodeValue: Int {get set}
}

struct DefaultServerResponse: ServerResponse {
    
    var codeKey: String = "code"
    
    var messageKey: String = "msg"
    
    var messageTypeKey: String = "msgType"
    
    var bodyKey: String = "data"
    
    var successCodeValue: Int = 0
}
