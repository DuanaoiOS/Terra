//
//  SignaturePlugin.swift
//  Terra
//
//  Created by DATree on 2019/12/26.
//

import Foundation
import Moya

/// Signature for Params
public final class SignaturePlugin: PluginType {

    // MARK: Modify URLRequest
    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        switch target.task {
        case .requestParameters(let parameters, _):
            return addSignatureToRequest(request, with: parameters)
        default:
            return request
        }
    }
    
    private func addSignatureToRequest(_ urlRequest: URLRequest, with parameters: [String: Any]?) -> URLRequest {
        guard let parameters = parameters else { return urlRequest }
        var targetRequest = urlRequest
        do {
            let data = try JSONSerialization.data(withJSONObject: parameters, options: [])
            if let signString:String = Configuration.default.signer?(data) {
                targetRequest.setValue(signString, forHTTPHeaderField: "sign")
            }
            
        } catch {
            //Do nothing,ignore error.
        }
        return targetRequest
    }
}
