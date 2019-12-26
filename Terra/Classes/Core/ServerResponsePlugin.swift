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
            guard let code = response.logicCode else { return result }
            if code == Configuration.default.serverResponse.successCodeValue {
                return .success(response)
            } else {
                let content = ServerErrorContent(code: code,
                                                 message: response.message,
                                                 messageType: response.messageType,
                                                 response: response)
                let error = BusinessError.server(content: content)
                Configuration.default.specialHandler?(error)
                return .failure(.underlying(error, response))
            }
        case .failure: return result
        }
    }
}
