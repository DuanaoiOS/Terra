//
//  BusinessErrorPlugin.swift
//  Terra
//
//  Created by DATree on 2019/12/26.
//

import Foundation
import Moya

/// 用于解析Result
final class BusinessErrorPlugin: PluginType {
    
    private let successCode = 0

    // MARK: 处理响应数据
    public func process(_ result: Result<Response, MoyaError>, target: TargetType) -> Result<Response, MoyaError> {
        switch result {
        case .success(let response):
            guard let code = response.logicCode else { return result }
            if code == successCode {
                return .success(response)
            } else {
                let content = ServerErrorContent(code: code,
                                                 message: response.message,
                                                 messageType: response.messageType,
                                                 response: response)
                let error = BusinessError.server(content: content)
                // 处理特殊错误code
                Configuration.default.specialHandler?(error)
                return .failure(.underlying(error, response))
            }
        case .failure: return result
        }
    }
}
