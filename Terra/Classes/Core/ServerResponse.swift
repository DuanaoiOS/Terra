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

public struct DefaultServerResponse: ServerResponse {
    
    public var codeKey: String = "code"
    
    public var messageKey: String = "msg"
    
    public var messageTypeKey: String = "msgType"
    
    public var bodyKey: String = "data"
    
    public var successCodeValue: Int = 0
}
