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
    
    internal var logicCode: Int? {
        if let intValue = dataJSON?["code"].object as? Int {
            return intValue
        } else if let stringValue = dataJSON?["code"].object as? String {
            return Int(stringValue)
        }
        return nil
    }
    
    internal var message: String? {
        return dataJSON?["msg"].object as? String
    }
    
    internal var messageType: ErrorPresentType? {
        if let message = dataJSON?["errType"].object as? String,
            let messageType = ErrorPresentType.init(rawValue: message) {
            return messageType
        }
        return nil
    }
    
    var bodyDictionaryObject: [String: Any]? {
        return dataJSON?["data"].dictionaryObject
    }
    
    var bodyArrayObject: [Any]? {
        return dataJSON?["data"].arrayObject
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
