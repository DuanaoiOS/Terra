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
    public typealias ErrorLauncher = (_ message: String, _ messageType: ServerErrorContent.MessageType?) -> Void
    /// Special error code handle
    public typealias SpecialHandler = (BusinessError) -> Void
    /// DNS parser
    public typealias DNSParser = (_ host: String) -> String
    /// Signature
    public typealias Signer = ((_ signData: Data) -> (String?))
    
    public internal(set) var errorLauncher: ErrorLauncher?
    public internal(set) var specialHandler: SpecialHandler?
    public internal(set) var dnsParser: DNSParser?
    public internal(set) var signer: Signer?
    
    public internal(set) var serverResponse: ResponsePattern = DefaultResponsePattern()
    
    public internal(set) var plugins: [PluginType] = [SignaturePlugin(), DNSPlugin(), ServerResponsePlugin()]
    
    public func setup(errorLauncher: ErrorLauncher? = nil,
                      specialHandler: SpecialHandler? = nil,
                      dnsParser: DNSParser? = nil,
                      signer: Signer? = nil,
                      serverResponse: ResponsePattern? = nil) {
        self.errorLauncher = errorLauncher
        self.specialHandler = specialHandler
        self.dnsParser = dnsParser
        self.signer = signer
        if let response = serverResponse {
            self.serverResponse = response
        }
    }
}
