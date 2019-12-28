# Terra

[![CI Status](https://img.shields.io/travis/DATree/Terra.svg?style=flat)](https://travis-ci.org/DATree/Terra)
[![Version](https://img.shields.io/cocoapods/v/Terra.svg?style=flat)](https://cocoapods.org/pods/Terra)
[![License](https://img.shields.io/cocoapods/l/Terra.svg?style=flat)](https://cocoapods.org/pods/Terra)
[![Platform](https://img.shields.io/cocoapods/p/Terra.svg?style=flat)](https://cocoapods.org/pods/Terra)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

* iOS 9.0 and above
* Swift 5.0 and above

## Installation

Terra is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Terra'
```

## Usage

### 快速使用

1. 定义一个API类型，推荐使用Enum

```swift
enum AccountAPI {
    case login(account: String, password: String)
    case logout(account: String)
}
```

2. 进行请求配置，扩展API类型，实现TargetType 协议。

```swift
extension AccountAPI: TargetType {
    
    var baseURL: URL {
        return URL(string: "https://www.google.com")!
    }
    
    var path: String {
        switch self {
        case .login:
            return "/account/login"
        case .logout:
            return "/account/logout"
        }
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var task: Moya.Task {
        var parameters = [String: Any]()
        switch self {
        case let .login(account, password):
            parameters["account"] = account
            parameters["password"] = password
        case let .logout(account):
            parameters["account"] = account
        }
        return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
    }
    
    var headers: [String : String]? {
        return [:]
    }
}
```

3. 初始化一个`MoyaProvider`,   **Terra** 可以通过`TargetType`适配器方法获取Provider实例， 默认提供了相关解析插件

```swift
let provider = AccountAPI.adapter()
```

当然直接初始化也是没问题的

```swift
let provider = MoyaProvider<AccountAPI>()
```

4. 定义数据模型 ，**Terra**支持了`BaseMappable`以及`Codable`类型的自动解析

```swift
struct Account: ImmutableMappable {
    
    var userID: String
    var name: String?
    var phone: String?
    var gender: Int?
    
    init(map: Map) throws {
        userID = try map.value("id")
        name = try? map.value("name")
        phone = try? map.value("phone")
        gender = try? map.value("gender")
    }
}
```

5. 使用`provider`进行网络请求，**Terra**支持Callback和Rx的方式

```swift
// Callback 
provider.te.requestModel(Account.self,
                                 target: .login(account: "xx", password:"xx"))
        { [weak self] (result) in
            switch result {
            case .success(let account):
                print(account.toJSON().debugDescription)
                completion(account)
            case .failure(let error):
                error.display(on: self?.view)
            }
        }
```

```swift
// RxSwift
func login() -> Observable<Account> {
    return provider.rx.requestModel(.login(account: "xx", password:"xx"))
}

// 1
login().subscribe { (event) in
        print(event.element.debugDescription)
    }.disposed(by: disposeBag)

// 2
login().subscribe(onNext: { (account) in
            print(account.toJSONString(prettyPrint: true))
        })
```



### 高级用法

使用**Terra**适配器获取的Provider实例， 默认配置了DNS解析/Params签名/业务错误码解析/请求超时等插件支持

通过`Configuration`配置相关实现逻辑

#### DNS解析

```swift
/// DNS parser
public typealias DNSParser = (_ host: String) -> String

public func setup(dnsParser: @escaping DNSParser) {
    self.dnsParser = dnsParser
}
// 配置解析逻辑
Configuration.te.setup { (host) -> String in
    // 返回host对应的ip 
}
```

#### 参数签名

```swift
/// Signature
public typealias Signer = (_ signData: Data) -> String?

public func setup(signer: @escaping Signer) {
    self.signer = signer
}
// 配置签名逻辑
Configuration.te.setup { (signData) -> String? in
    // 返回签名后的字符串 
}
```

#### 特殊错误处理

```swift
/// Special error code handle
public typealias ErrorHandler = (_ error: BusinessError) -> Void

public static func setup(errorHandler: @escaping Configuration.ErrorHandler) {
    Configuration.default.errorHandler = errorHandler
}
// 配置处理逻辑
Configuration.te.setup { (error) in
    // 处理错误 
}
```

#### 错误信息展示

```swift
/// Display error
public typealias MessageDisplayer = (_ message: String,
                                    _ messageType: ServerErrorContent.MessageType?,
                                    _ onView: UIView?) -> Void

public static func setup(messageDisplayer: @escaping Configuration.MessageDisplayer) {
    Configuration.default.msgDisplayer = messageDisplayer
}
// 配置错误展示逻辑
Configuration.te.setup { (msg, msgType, onView) in
    // 根据错误类型展示
}
```

#### 服务端响应数据匹配

```swift
/// Response format 
public protocol ResponsePattern {
    var bodyKeyPath: String { get set }
    func verifier(response: Moya.Response) -> Bool?
    func errorContent(in reponse: Moya.Response) -> ServerErrorContent?
}

public static func setup(pattern: ResponsePattern) {
    Configuration.default.responsePattern = pattern
}

/// 遵循协议
struct DefaultResponsePattern: ResponsePattern { 
  /// 数据内容的Key
    var bodyKeyPath: String = "data"
    /// 验证是否为成功响应
    func verifier(response: Response) -> Bool? {
        guard let code = logicCode(response: response) else { return nil }
        return code == successCodeValue
    }
    /// 解析服务端标准错误内容
    func errorContent(in response: Response) -> ServerErrorContent? {
        guard let code = logicCode(response: response),
              code != successCodeValue else {return nil }
        let content = ServerErrorContent(code: code,
                                         message: message(response: response),
                                         messageType: messageType(response: response),
                                         response: response)
        return content
    }
}
```

#### 请求超时设置

```swift
// 1- Configuration settings
public static func setup(timeoutIntervalForRequest: TimeInterval) {
    Configuration.default.timeoutIntervalForRequest = timeoutIntervalForRequest
}
Configuration.te.setup(timeoutIntervalForRequest: 30)

// 2 - Plugin
let requestPlugin = RequestPreparePlugin { (urlRequest, target) -> URLRequest in
    var urlRequest = urlRequest
    urlRequest.timeoutInterval = 30
    return urlRequest
}
let provider = AccountAPI.adapter(plugins: [requestPlugin])
```

也可以统一进行配置：

```swift
Configuration.te.setup(timeoutIntervalForRequest: 20,
                               responsePattern: pattern,
                               msgDisplayer: { (msg, msgType, onView) in
                                
        }, errorHandler: { (error) in
                                
        }, dnsParser: { (host) -> String in
                                
        }) { (signData) -> String? in
            
        }
```



#### 插件

1. 请求自定义插件：支持在请求发送之前修改URLRequest

```swift
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
```

2. 响应修改插件：支持在完成回调之前修改响应结果

```swift
/// Result Modifier
public final class ResultParserPlugin: PluginType {
    
    public typealias ProcessResultClosure = (_ result: Result<Response, MoyaError>, _ target: TargetType) -> Result<Response, MoyaError>
    public let processResultClosure: ProcessResultClosure
    
    public init(processResultClosure: @escaping ProcessResultClosure) {
        self.processResultClosure = processResultClosure
    }

    // MARK: Called to modify a result before completion.
    public func process(_ result: Result<Response, MoyaError>, target: TargetType) -> Result<Response, MoyaError> {
       return processResultClosure(result, target)
    }
}
```

##### Loading

支持在请求开始和结束插入Loading状态

```swift
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
```

##### Logger

支持在调试模式下输出请求过程的日志

```swift
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
```



### 网络状态

`NetStateMonitor`   是**Terra**的网络连接状态监控类，开启监控后可以获取当前网络连接状态以及环境类型

对外界同时提供了Block和Notification两种监听方式支持

#### 开启/关闭

```swift
// 开启网络监听
NetStateMonitor.te.startMonitoring()
// 关闭网络监听
NetStateMonitor.te.stopMonitoring()
```

#### 状态监听

```swift
// 1 Block
NetStateMonitor.te.addObserver(self) { (networkType, isReachable) in
	// handle
	print("networkType:\(networkType) isReachable: \(isReachable)")
}
NetStateMonitor.te.notify(observer: self) { (networkType, isReachable) in

}
 
 // 2 Notification
NotificationCenter.default
  .addObserver(self,
               selector: #selector(networkNotification(_:)),
               name: NSNotification.Name.netStatusDidChange,
               object: nil)
```



## Author

DATree, aobaoaini@gmail.com

## License

Terra is available under the MIT license. See the LICENSE file for more info.
