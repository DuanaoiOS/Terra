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
            guard let content = Configuration.default.serverResponse.errorContent(in: response) else { return result }
                let error = BusinessError.server(content: content)
                Configuration.default.specialHandler?(error)
                return .failure(.underlying(error, response))
        case .failure: return result
        }
    }
}
