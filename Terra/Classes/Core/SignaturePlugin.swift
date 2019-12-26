//
//  SignaturePlugin.swift
//  Terra
//
//  Created by DATree on 2019/12/26.
//

import Foundation
import Moya

/// 用于签名
final class SignaturePlugin: PluginType {

    // MARK: 修改发送请求
    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        switch target.task {
        case .requestParameters(let parameters, _):
            return addSignatureToRequest(request, with: parameters)
        default:
            return request
        }
    }
    
    /// 为参数添加签名
    ///
    /// - Parameters:
    ///   - urlRequest: 原始请求实例
    ///   - parameters: 参数
    /// - Returns: 签名后的参数
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
