//
//  DNSPlugin.swift
//  Terra
//
//  Created by DATree on 2019/12/26.
//

import Foundation
import Moya

/// 用于签名
final class DNSPlugin: PluginType {

    // MARK: 修改发送请求
    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        return parseDNS(forRequest: request)
    }
    
    /// DNS解析
    ///
    /// - Parameter request：解析请求DNS
    /// - Returns: 解析结果
    private func parseDNS(forRequest request: URLRequest) -> URLRequest {
        var targetRequest = request
        if let originalHost = request.url?.host,
            let ip = Configuration.default.dnsParser?(originalHost) {
            let newURL = request.url?.absoluteString.replacingOccurrences(of: originalHost, with: ip)
            targetRequest.url = URL(string: newURL!)
            targetRequest.setValue(originalHost, forHTTPHeaderField: "host")
            return targetRequest
        }
        return request
    }
}
