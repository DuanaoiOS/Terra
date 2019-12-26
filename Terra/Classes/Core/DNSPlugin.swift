//
//  DNSPlugin.swift
//  Terra
//
//  Created by DATree on 2019/12/26.
//

import Foundation
import Moya

public final class DNSPlugin: PluginType {

    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        return parseDNS(forRequest: request)
    }
    
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
