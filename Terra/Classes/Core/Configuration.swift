//
//  Configuration.swift
//  Terra
//
//  Created by DATree on 2019/12/26.
//

import Foundation
import Moya

/// Display error
public typealias MessageDisplayer = (_ message: String,
                                    _ messageType: ServerErrorContent.MessageType?,
                                    _ onView: UIView?) -> Void
/// Special error code handle
public typealias ErrorHandler = (_ error: BusinessError) -> Void
/// DNS parser
public typealias DNSParser = (_ host: String) -> String
/// Signature
public typealias Signer = (_ signData: Data) -> String?

public let defaultTimeoutInterval: TimeInterval = 30

/// User-defined
final class Configuration {
        
    static let `default`: Configuration = Configuration()
    private init() {}
    
    fileprivate(set) var msgDisplayer: MessageDisplayer?
    fileprivate(set) var errorHandler: ErrorHandler?
    fileprivate(set) var dnsParser: DNSParser?
    fileprivate(set) var signer: Signer?
    
    fileprivate(set) var timeoutIntervalForRequest = defaultTimeoutInterval
    fileprivate(set) var responsePattern: ResponsePattern = DefaultPattern()
    fileprivate(set) lazy var plugins: [PluginType] = [
        SignaturePlugin(),
        DNSPlugin(),
        ServerResponsePlugin(),
        RequestPreparePlugin.timeoutSettings()
    ]
}

public extension Terra {
    
    static func setup(dnsParser: @escaping DNSParser) {
        Configuration.default.dnsParser = dnsParser
    }
    
    static func setup(signer: @escaping Signer) {
        Configuration.default.signer = signer
    }
    
    static func setup(errorHandler: @escaping ErrorHandler) {
        Configuration.default.errorHandler = errorHandler
    }
    
    static func setup(messageDisplayer: @escaping MessageDisplayer) {
        Configuration.default.msgDisplayer = messageDisplayer
    }
    
    static func setup(pattern: ResponsePattern) {
        Configuration.default.responsePattern = pattern
    }
    
    static func setup(timeoutIntervalForRequest: TimeInterval) {
        Configuration.default.timeoutIntervalForRequest = timeoutIntervalForRequest
    }
}
