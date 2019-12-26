//
//  RequestPreparePlugin.swift
//  Terra
//
//  Created by DATree on 2019/12/26.
//

import Foundation
import Moya

/// 用于配置URLRequest
public final class RequestPreparePlugin: PluginType {

    public typealias RequestPrepareClosure = (_ request: URLRequest, _ target: TargetType) -> URLRequest
    public let requestPrepareClosure: RequestPrepareClosure
    
    public init(requestPrepareClosure: @escaping RequestPrepareClosure) {
        self.requestPrepareClosure = requestPrepareClosure
    }

    // MARK: 修改发送请求
    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        return requestPrepareClosure(request, target)
    }
}
