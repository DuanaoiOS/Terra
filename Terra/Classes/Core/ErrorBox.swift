//
//  ErrorBox.swift
//  Terra
//
//  Created by DATree on 2019/12/26.
//

import Foundation
import Moya


/// 消息显示类型
///
/// - toast: 用Toast显示
/// - dialog: 用AlertView显示
/// - none: 不显示
public enum ErrorPresentType: String {
    case toast = "T"
    case dialog = "D"
    case none = "N"
}

/// 服务端错误内容
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

/// 业务错误类型
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
        return content.message ?? "发生错误：\(content.code)"
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

// 错误显示
extension MoyaError {
    public func show() {
        let messgae = localizedDescription
        let messageType = businessError?.messageType ?? .none
        Configuration.default.errorLauncher?(messgae, messageType)
    }
}
