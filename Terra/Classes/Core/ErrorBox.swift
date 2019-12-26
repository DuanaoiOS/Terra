//
//  ErrorBox.swift
//  Terra
//
//  Created by DATree on 2019/12/26.
//

import Foundation
import Moya

/// Display type of Error Message
///
/// - toast: Toast
/// - dialog: AlertView
/// - none: No display
public enum ErrorPresentType: String {
    case toast = "T"
    case dialog = "D"
    case none = "N"
}

/// Content of Server's Errror
public struct ServerErrorContent {
    public var code: Int
    public var message: String?
    public var messageType: ErrorPresentType?
    public var response: Moya.Response?
    
    public init(code: Int,
                message: String?,
                messageType: ErrorPresentType?,
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
}

extension BusinessError {
    
    internal var content: ServerErrorContent {
        switch self {
        case let .server(content): return content
        }
    }

    public var code: Int {
        return content.code
    }
    
    public var message: String? {
        return content.message
    }
    
    public var messageType: ErrorPresentType {
        return content.messageType ?? .none
    }
    
    public var response: Moya.Response? {
        return content.response
    }
    
    public var localizedDescription: String {
        return content.message ?? "error occurred:\(content.code)"
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
    public func show() {
        let messgae = localizedDescription
        let messageType = businessError?.messageType ?? .none
        Configuration.default.errorLauncher?(messgae, messageType)
    }
}
