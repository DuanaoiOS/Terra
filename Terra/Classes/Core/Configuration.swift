//
//  Configuration.swift
//  Terra
//
//  Created by DATree on 2019/12/26.
//

import Foundation

/// 使用初始配置类
public final class Configuration {
    
    static let defaultResultKeyPath = "data"
    
    public static let `default`: Configuration = Configuration()
    private init() {}
    
    /// 错误信息展示处理
    public typealias ErrorLauncher = (_ message: String, _ messageType: ErrorPresentType) -> Void
    /// 特殊错误处理
    public typealias SpecialHandler = (BusinessError) -> Void
    /// dns解析处理
    public typealias DNSParser = (_ host: String) -> String
    /// 请求参数签名
    public typealias Signer = ((_ signData: Data) -> (String?))
    
    public internal(set) var errorLauncher: ErrorLauncher?
    public internal(set) var specialHandler: SpecialHandler?
    public internal(set) var dnsParser: DNSParser?
    public internal(set) var signer: Signer?
    
    public internal(set) var responseBodyKeyPath = Configuration.defaultResultKeyPath
    
    public func setup(errorLauncher: ErrorLauncher? = nil,
                      specialHandler: SpecialHandler? = nil,
                      dnsParser: DNSParser? = nil,
                      signer: Signer? = nil,
                      responseBodyKeyPath: String? = nil) {
        self.errorLauncher = errorLauncher
        self.specialHandler = specialHandler
        self.dnsParser = dnsParser
        self.signer = signer
        if let keyPath = responseBodyKeyPath {
            self.responseBodyKeyPath = keyPath
        }
    }
}
