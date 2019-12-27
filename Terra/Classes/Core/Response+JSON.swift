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
        return Configuration.default.serverResponse
    }
    
    internal var bodyKey: String {
        return responsePattern.bodyKeyPath
    }
    
    internal var logicCode: Int? {
        return responsePattern.errorContent(in: self)?.code
    }
    
    internal var message: String? {
        return responsePattern.errorContent(in: self)?.message
    }
    
    internal var messageType: ServerErrorContent.MessageType? {
        return responsePattern.errorContent(in: self)?.messageType
    }
    
    var bodyDictionaryObject: [String: Any]? {
        return dataJSON?[bodyKey].dictionaryObject
    }
    
    var bodyArrayObject: [Any]? {
        return dataJSON?[bodyKey].arrayObject
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
