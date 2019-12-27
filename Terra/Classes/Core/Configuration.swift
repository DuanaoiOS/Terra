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
    public typealias MessageDisplayer = (_ message: String, _ messageType: ServerErrorContent.MessageType?, _ onView: UIView?) -> Void
    /// Special error code handle
    public typealias ErrorHandler = (_ error: BusinessError) -> Void
    /// DNS parser
    public typealias DNSParser = (_ host: String) -> String
    /// Signature
    public typealias Signer = (_ signData: Data) -> String?
    
    public internal(set) var msgDisplayer: MessageDisplayer?
    public internal(set) var errorHandler: ErrorHandler?
    public internal(set) var dnsParser: DNSParser?
    public internal(set) var signer: Signer?
    
    public internal(set) var responsePattern: ResponsePattern = DefaultResponsePattern()
    public internal(set) lazy var plugins: [PluginType] = [
        SignaturePlugin(),
        DNSPlugin(),
        ServerResponsePlugin(),
        RequestPreparePlugin.timeoutSettings()
    ]
    
    public static let defaultTimeoutInterval: TimeInterval = 20
    public internal(set) var timeoutIntervalForRequest = Configuration.defaultTimeoutInterval
    
    public func setup(
                    timeoutIntervalForRequest: TimeInterval = Configuration.defaultTimeoutInterval,
                    responsePattern: ResponsePattern? = nil,
                    msgDisplayer: MessageDisplayer? = nil,
                    errorHandler: ErrorHandler? = nil,
                    dnsParser: DNSParser? = nil,
                    signer: Signer? = nil) {
        if let pattern = responsePattern {
            self.responsePattern = pattern
        }
        self.timeoutIntervalForRequest = timeoutIntervalForRequest
        self.msgDisplayer = msgDisplayer
        self.errorHandler = errorHandler
        self.dnsParser = dnsParser
        self.signer = signer
    }
}
