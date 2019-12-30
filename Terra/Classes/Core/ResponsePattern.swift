//
//  ServerResponse.swift
//  Terra
//
//  Created by DATree on 2019/12/26.
//

import Foundation
import Moya
import SwiftyJSON

public protocol ResponsePattern {
    typealias KeyPathType = [String]
    var codeKeyPath: KeyPathType {get}
    var messageKeyPath: KeyPathType {get}
    var messageTypeKeyPath: KeyPathType {get}
    var resultBodyKeyPath: KeyPathType {get}

    var responseIsSuccess: (_ response: Moya.Response) -> Bool {get}
    var codeValue: (_ response: Moya.Response) -> Int? {get}
    var messageValue: (_ response: Moya.Response) -> String? {get}
    var messageTypeValue: (_ response: Moya.Response) -> ServerErrorContent.MessageType? {get}
    
    var errorContent: (_ response: Moya.Response) -> ServerErrorContent? {get}
}

public extension ResponsePattern {
    var errorContent: (Response) -> ServerErrorContent? {
        return { response in
            guard let code = self.codeValue(response) else {
                return nil
            }
            return ServerErrorContent(code: code,
                                      message: self.messageValue(response),
                                      messageType: self.messageTypeValue(response),
                                      response: response)
        }
    }
}

struct DefaultPattern: ResponsePattern {
    
    var codeKeyPath: KeyPathType {
        return ["code"]
    }
    
    var messageKeyPath: KeyPathType {
        return ["msg"]
    }
    
    var messageTypeKeyPath: KeyPathType {
        return ["msgType"]
    }
    
    var resultBodyKeyPath: KeyPathType {
        return ["data"]
    }
    
    var responseIsSuccess: (Response) -> Bool {
        return { response in
            return self.codeValue(response) == 0
        }
    }
    
    var codeValue: (Response) -> Int? {
        return { response in
            guard let code = response.dataJSON?[self.codeKeyPath] else {
                return nil
            }
            switch code.type {
            case .number:
                return code.int
            case .string:
                return Int(code.stringValue)
            default:
                return nil
            }
        }
    }
    
    var messageValue: (Response) -> String? {
        return { response in
            return response.dataJSON?[self.messageKeyPath].string
        }
    }

    var messageTypeValue: (Response) -> ServerErrorContent.MessageType? {
        return { response in
            guard let msgType = response.dataJSON?[self.messageTypeKeyPath].string,
            let type = ServerErrorContent.MessageType(rawValue: msgType) else { return nil }
            return type
        }
    }
}

extension Array where Element == String {
    var keyPath: String {
        return joined(separator: ".")
    }
}
