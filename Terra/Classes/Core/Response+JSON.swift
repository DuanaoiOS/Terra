//
//  Response+JSON.swift
//  Terra
//
//  Created by DATree on 2019/12/26.
//

import Foundation
import Moya
import SwiftyJSON

public extension Moya.Response {
    
    internal var codeKey: String {
        return Configuration.default.serverResponse.codeKey
    }
    
    internal var msgKey: String {
        return Configuration.default.serverResponse.messageKey
    }
    
    internal var msgTypeKey: String {
        return Configuration.default.serverResponse.messageTypeKey
    }
    
    internal var bodyKey: String {
        return Configuration.default.serverResponse.bodyKey
    }
    
    internal var logicCode: Int? {
        let codeValue = dataJSON?[codeKey].object
        if let intValue = codeValue as? Int {
            return intValue
        } else if let stringValue = codeValue as? String {
            return Int(stringValue)
        }
        return nil
    }
    
    internal var message: String? {
        return dataJSON?[msgKey].object as? String
    }
    
    internal var messageType: ErrorPresentType? {
        if let message = dataJSON?[msgTypeKey].object as? String,
            let messageType = ErrorPresentType(rawValue: message) {
            return messageType
        }
        return nil
    }
    
    var bodyDictionaryObject: [String: Any]? {
        return dataJSON?[bodyKey].dictionaryObject
    }
    
    var bodyArrayObject: [Any]? {
        return dataJSON?[bodyKey].arrayObject
    }
    
    private var dataJSON: JSON? {
        do {
            let json = try JSON(data: data)
            return json
        } catch {
            return nil
        }
    }
}
