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
    case unkown
}

extension BusinessError {
    
    internal var content: ServerErrorContent? {
        switch self {
        case let .server(content): return content
        case .unkown: return nil
        }
    }

    public var code: Int? {
        return content?.code
    }
    
    public var message: String? {
        return content?.message
    }
    
    public var messageType: ServerErrorContent.MessageType {
        return content?.messageType ?? .none
    }
    
    public var response: Moya.Response? {
        return content?.response
    }
    
    public var localizedDescription: String {
        switch self {
        case .server(let content):
            return content.message ?? "error occurred:\(content.code)"
        default:
            return "error occurred: unkown"
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
