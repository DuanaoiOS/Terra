//
//  RequestPreparePlugin.swift
//  Terra
//
//  Created by DATree on 2019/12/26.
//

import Foundation
import Moya

/// URLRequest of Custom-ized
public final class RequestPreparePlugin: PluginType {

    public typealias RequestPrepareClosure = (_ request: URLRequest, _ target: TargetType) -> URLRequest
    public let requestPrepareClosure: RequestPrepareClosure
    
    public init(requestPrepareClosure: @escaping RequestPrepareClosure) {
        self.requestPrepareClosure = requestPrepareClosure
    }

    // MARK: Called to modify a request before sending
    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        return requestPrepareClosure(request, target)
    }
}
