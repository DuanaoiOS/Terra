//
//  ErrorBox.swift
//  Terra
//
//  Created by DATree on 2019/12/26.
//

import Foundation
import Moya

/// Content of Server's Errror
public struct ServerErrorContent {
    /// Display type of Error Message
    ///
    /// - toast: Toast
    /// - dialog: AlertView
    /// - none: No display
    public enum MessageType: String {
        case toast = "T"
        case dialog = "D"
        case none = "N"
    }

    public var code: Int
    public var message: String?
    public var messageType: MessageType?
    public var response: Moya.Response?
    
    public init(code: Int,
                message: String?,
                messageType: MessageType?,
                response: Moya.Response?) {
        self.code = code
        self.message = message
        self.messageType = messageType
        self.response = response
    }
}

/// Enum of business error
public enum BusinessError: Swift.Error {
    case server(content: ServerErrorContent)
    case unkown(Moya.Response)
}

extension BusinessError {
    
    internal var content: ServerErrorContent? {
        switch self {
        case let .server(content): return content
        case .unkown: return nil
        }
    }

    public var code: Int? {
        switch self {
        case let .server(content): return content.code
        case .unkown: return NSURLErrorUnknown
        }
    }
    
    public var message: String? {
        switch self {
        case let .server(content): return content.message
        case .unkown: return "未知错误"
        }
    }
    
    public var messageType: ServerErrorContent.MessageType {
        switch self {
        case let .server(content):
            return content.messageType ?? .none
        case .unkown:
            return .toast
        }
    }
    
    public var response: Moya.Response? {
        switch self {
        case let .server(content):
            return content.response
        case let .unkown(response):
            return response
        }
    }
    
    public var localizedDescription: String {
        switch self {
        case .server(let content):
            return content.message ?? "发生错误:\(content.code)"
        default:
            return "未知错误"
        }
    }
    
    public func display(on view: UIView? = nil) {
        Configuration.default
            .msgDisplayer?(localizedDescription, messageType, view)
    }
}

extension MoyaError {
   public var businessError: BusinessError? {
        switch self {
        case .underlying(let error, _):
            return error as? BusinessError
        default:
            return nil
        }
    }
}

// extension of display error
extension MoyaError {
    public func display(on view: UIView? = nil) {
        if let business = businessError {
            business.display(on: view)
        } else {
            let messgae = errorDescription ?? localizedDescription
            Configuration.default.msgDisplayer?(messgae, .toast, view)
        }
    }
}
