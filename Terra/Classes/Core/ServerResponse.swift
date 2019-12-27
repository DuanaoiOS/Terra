//
//  ServerResponse.swift
//  Terra
//
//  Created by DATree on 2019/12/26.
//

import Foundation
import Moya

public protocol ResponsePattern {
    var bodyKeyPath: String { get set }
    func verifier(response: Moya.Response) -> Bool?
    func errorContent(in reponse: Moya.Response) -> ServerErrorContent?
}

struct DefaultResponsePattern: ResponsePattern {
    
    private let codeKey: String = "code"
    
    private let messageKey: String = "msg"
    
    private let messageTypeKey: String = "msgType"
        
    private let successCodeValue: Int = 0
    
    var bodyKeyPath: String = "data"
    
    func verifier(response: Response) -> Bool? {
        guard let code = logicCode(response: response) else { return nil }
        return code == successCodeValue
    }
    
    func errorContent(in response: Response) -> ServerErrorContent? {
        guard let code = logicCode(response: response), code != successCodeValue else { return nil }
        let content = ServerErrorContent(code: code,
                                         message: message(response: response),
                                         messageType: messageType(response: response),
                                         response: response)
        return content
    }
    
    // MARK: Private
    
    private func logicCode(response: Response) -> Int? {
        let codeValue = response.dataJSON?[codeKey].object
        if let intValue = codeValue as? Int {
            return intValue
        } else if let stringValue = codeValue as? String {
            return Int(stringValue)
        }
        return nil
    }
    
    private func message(response: Response) -> String? {
        return response.dataJSON?[messageKey].object as? String
    }
    
    private func messageType(response: Response) -> ServerErrorContent.MessageType? {
        if let message = response.dataJSON?[messageTypeKey].object as? String,
            let messageType = ServerErrorContent.MessageType(rawValue: message) {
            return messageType
        }
        return nil
    }
}
