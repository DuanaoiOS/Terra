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
    
    internal var responsePattern: ResponsePattern {
        return Configuration.default.responsePattern
    }
    
    internal var logicCode: Int? {
        return responsePattern.codeValue(self)
    }
    
    internal var message: String? {
        return responsePattern.messageValue(self)
    }
    
    internal var messageType: ServerErrorContent.MessageType? {
        return responsePattern.messageTypeValue(self)
    }
    
    var bodyDictionaryObject: [String: Any]? {
        return dataJSON?[responsePattern.resultBodyKeyPath].dictionaryObject
    }
    
    var bodyArrayObject: [Any]? {
        return dataJSON?[responsePattern.resultBodyKeyPath].arrayObject
    }
    
    internal var dataJSON: JSON? {
        do {
            let json = try JSON(data: data)
            return json
        } catch {
            return nil
        }
    }
}
