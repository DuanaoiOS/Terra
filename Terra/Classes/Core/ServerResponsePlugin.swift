//
//  ServerResponsePlugin.swift
//  Terra
//
//  Created by DATree on 2019/12/26.
//

import Foundation
import Moya

public final class ServerResponsePlugin: PluginType {
    
    public func process(_ result: Result<Response, MoyaError>, target: TargetType) -> Result<Response, MoyaError> {
        switch result {
        case .success(let response):
            let pattern = Configuration.default.responsePattern
            guard !pattern.responseIsSuccess(response) else {
                return result
            }
            guard let content = pattern.errorContent(response) else {
                return .failure(.underlying(BusinessError.unkown, response))
            }
            let error = BusinessError.server(content: content)
            Configuration.default.errorHandler?(error)
            return .failure(.underlying(error, response))
        case .failure: return result
        }
    }
}
