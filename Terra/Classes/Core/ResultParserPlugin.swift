//
//  ResultParserPlugin.swift
//  Terra
//
//  Created by DATree on 2019/12/26.
//

import Foundation
import Moya

/// 用于解析Result
public final class ResultParserPlugin: PluginType {
    
    public typealias ProcessResultClosure = (_ result: Result<Response, MoyaError>, _ target: TargetType) -> Result<Response, MoyaError>
    public let processResultClosure: ProcessResultClosure
    
    public init(processResultClosure: @escaping ProcessResultClosure) {
        self.processResultClosure = processResultClosure
    }

    // MARK: 处理响应数据
    public func process(_ result: Result<Response, MoyaError>, target: TargetType) -> Result<Response, MoyaError> {
       return processResultClosure(result, target)
    }
}
