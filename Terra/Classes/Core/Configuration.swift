//
//  Configuration.swift
//  Terra
//
//  Created by DATree on 2019/12/26.
//

import Foundation
import Moya

/// User-defined
public final class Configuration {
        
    public static let `default`: Configuration = Configuration()
    private init() {}
    
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
    
    fileprivate(set) var msgDisplayer: MessageDisplayer?
    fileprivate(set) var errorHandler: ErrorHandler?
    fileprivate(set) var dnsParser: DNSParser?
    fileprivate(set) var signer: Signer?
    
    fileprivate(set) var responsePattern: ResponsePattern = DefaultPattern()
    public internal(set) lazy var plugins: [PluginType] = [
        SignaturePlugin(),
        DNSPlugin(),
        ServerResponsePlugin(),
        RequestPreparePlugin.timeoutSettings()
    ]
    
    public static let defaultTimeoutInterval: TimeInterval = 20
    public internal(set) var timeoutIntervalForRequest = Configuration.defaultTimeoutInterval
}

extension Configuration: TerraCompatible {}

extension Terra where Base: Configuration {
    
    public static func setup(dnsParser: @escaping Configuration.DNSParser) {
        Configuration.default.dnsParser = dnsParser
    }
    
    public static func setup(signer: @escaping Configuration.Signer) {
        Configuration.default.signer = signer
    }
    
    public static func setup(errorHandler: @escaping Configuration.ErrorHandler) {
        Configuration.default.errorHandler = errorHandler
    }
    
    public static func setup(messageDisplayer: @escaping Configuration.MessageDisplayer) {
        Configuration.default.msgDisplayer = messageDisplayer
    }
    
    public static func setup(pattern: ResponsePattern) {
        Configuration.default.responsePattern = pattern
    }
    
    public static func setup(timeoutIntervalForRequest: TimeInterval) {
        Configuration.default.timeoutIntervalForRequest = timeoutIntervalForRequest
    }
    
    
    public static func setup(
                    timeoutIntervalForRequest: TimeInterval = Configuration.defaultTimeoutInterval,
                    responsePattern: ResponsePattern? = nil,
                    msgDisplayer: Configuration.MessageDisplayer? = nil,
                    errorHandler: Configuration.ErrorHandler? = nil,
                    dnsParser: Configuration.DNSParser? = nil,
                    signer: Configuration.Signer? = nil) {
        Configuration.default.timeoutIntervalForRequest = timeoutIntervalForRequest
        if let pattern = responsePattern {
            Configuration.default.responsePattern = pattern
        }
        if let msgDisplayer = msgDisplayer {
            Configuration.default.msgDisplayer = msgDisplayer
        }
        if let errorHandler = errorHandler {
            Configuration.default.errorHandler = errorHandler
        }
        if let dnsParser = dnsParser {
            Configuration.default.dnsParser = dnsParser
        }
        if let signer = signer {
            Configuration.default.signer = signer
        }
    }
}
