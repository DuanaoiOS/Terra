//
//  Plugins.swift
//  Terra
//
//  Created by DATree on 2019/12/27.
//

import Moya

extension NetworkActivityPlugin {
    
    public class func plugin(start: @escaping (_ target: TargetType) -> Void,
                             end: @escaping (_ target: TargetType) -> Void) -> NetworkActivityPlugin {
        return NetworkActivityPlugin { changeType, target  in
               switch changeType {
               case .began:
                   start(target)
               case .ended:
                   end(target)
               }
           }
    }
}

extension NetworkLoggerPlugin {
    
    class func reversedPrint(_ separator: String, terminator: String, items: Any...) {
        #if DEBUG
        items.forEach {print($0, separator: separator, terminator: terminator)}
        #endif
    }
    
    public class func plugin(verbose: Bool = true) -> NetworkLoggerPlugin {
        return NetworkLoggerPlugin(verbose: verbose,
                                   output: reversedPrint,
                                   responseDataFormatter: { (data: Data) -> Data in
            do {
                let dataAsJSON = try JSONSerialization.jsonObject(with: data)
                let prettyData =  try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
                return prettyData
            } catch {
                return data
            }
        })
    }
}

extension RequestPreparePlugin {
    
    public class func timeoutSettings(interval: TimeInterval? = nil) -> RequestPreparePlugin {
        return RequestPreparePlugin { (urlRequest, target) -> URLRequest in
            var urlRequest = urlRequest
            urlRequest.timeoutInterval = interval ?? Configuration.default.timeoutIntervalForRequest
            return urlRequest
        }
    }
}
