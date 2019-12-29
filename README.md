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

定义一个API类型，推荐使用Enum

```swift
public enum GitHub {
    case zen
    case userProfile(String)
    case userRepositories(String)
}
```

进行请求配置，扩展API类型，实现TargetType 协议。

```swift
extension GitHub: TargetType {
    public var baseURL: URL { return URL(string: "https://api.github.com")! }
    public var path: String {
        switch self {
        case .zen:
            return "/zen"
        case .userProfile(let name):
            return "/users/\(name.urlEscaped)"
        case .userRepositories(let name):
            return "/users/\(name.urlEscaped)/repos"
        }
    }
    public var method: Moya.Method {
        return .get
    }
    public var task: Task {
        switch self {
        case .userRepositories:
            return .requestParameters(parameters: ["sort": "pushed"], encoding: URLEncoding.default)
        default:
            return .requestPlain
        }
    }
    public var validationType: ValidationType {
        switch self {
        case .zen:
            return .successCodes
        default:
            return .none
        }
    }
    public var sampleData: Data {
        switch self {
        case .zen:
            return "Half measures are as bad as nothing at all.".data(using: String.Encoding.utf8)!
        case .userProfile(let name):
            return "{\"login\": \"\(name)\", \"id\": 100}".data(using: String.Encoding.utf8)!
        case .userRepositories(let name):
            return "[{\"name\": \"\(name)\"}]".data(using: String.Encoding.utf8)!
        }
    }
    public var headers: [String: String]? {
        return nil
    }
}
```

初始化一个`MoyaProvider`,   **Terra** 可以通过`TargetType`适配器方法获取Provider实例， 默认提供了相关解析插件

```swift
let gitHubProvider = GitHub.adapter(plugins: [NetworkLoggerPlugin.plugin()])
```

当然直接初始化也是没问题的

```swift
let gitHubProvider = MoyaProvider<GitHub>()
```

定义数据模型 ，**Terra**支持了`BaseMappable`以及`Codable`类型的自动解析

```swift
struct Repository: ImmutableMappable {
  var keysURL: String
  var statusesURL: String
  var issuesURL: String
  var defaultBranch: String
  var issueEventsURL: String?
  var id: Int
  var owner: Owner
  /**
  ....
  
  */
  init(map: Map) {
    keysURL = (try? map.value("keys_url")) ?? ""
    statusesURL = (try? map.value("statuses_url")) ?? ""
    issuesURL = (try? map.value("issues_url")) ?? ""
    defaultBranch = (try? map.value("default_branch")) ?? ""
    issueEventsURL = (try? map.value("issues_events_url")) ?? ""
    id = try! map.value("id")
    owner = try! map.value("owner")
  }
}
```

使用`provider`进行网络请求，**Terra**支持

* Callback
* RxSwift
* ReactiveSwift

```swift
// Callback 
func downloadRepositories(_ username: String) {
        gitHubProvider.terra
            .requestModelList(Repository.self, target: .userRepositories(username)) {
              [weak self] (result) in
                guard let `self` = self else {return}
                switch result {
                case .success(let repos):
                    self.repos = repos
                case .failure(let error):
                    error.display(on: self.view)
                }
        }
    }
```

```swift
// RxSwift
func downloadRepositories(_ username: String) -> Observable<[Repository]> {
    return gitHubProvider.rx
        .requestModelList(Repository.self, token: .userRepositories(username))
        .asObservable()
        .take(1)
        .observeOn(MainScheduler.instance)
}
        
rxDownloadRepositories("DuanaoiOS")
            .subscribe(onNext: { (repos) in
                self.repos = repos
            }, onError: { (error) in
                print(error.localizedDescription)
            }).disposed(by: disposeBag)
```

```swift
// ReactiveSwift
func reactDownloadRepositories(_ username: String) -> SignalProducer<[Repository], MoyaError> {
    return gitHubProvider.reactive
        .requestModelList(Repository.self, token: .userRepositories(username))
        .take(last: 1)
        .observe(on: QueueScheduler.main)
}

reactDownloadRepositories("DuanaoiOS").start { (event) in
    switch event {
    case .value(let repos):
        self.repos = repos
    case .failed(let error):
        error.display(on: self.view)
    default: break
    }
}
```



### 进阶用法

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
Configuration.terra.setup { (host) -> String in
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
Configuration.terra.setup { (signData) -> String? in
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
Configuration.terra.setup { (error) in
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
Configuration.terra.setup { (msg, msgType, onView) in
    // 根据错误类型展示
}
```

#### 服务端响应数据自定义解析

```swift
/// Response format 
public protocol ResponsePattern {
    typealias KeyPathType = [String]
    var codeKeyPath: KeyPathType {get}
    var messageKeyPath: KeyPathType {get}
    var messageTypeKeyPath: KeyPathType {get}
    var resultBodyKeyPath: KeyPathType {get}

    var responseIsSuccess: (_ response: Moya.Response) -> Bool {get}
    var codeValue: (_ response: Moya.Response) -> Int? {get}
    var messageValue: (_ response: Moya.Response) -> String? {get}
    var messageTypeValue: (_ response: Moya.Response) -> ServerErrorContent.MessageType? {get}
    
    var errorContent: (_ response: Moya.Response) -> ServerErrorContent? {get}
}
```

#### 请求超时设置

```swift
// 1- Configuration settings
public static func setup(timeoutIntervalForRequest: TimeInterval) {
    Configuration.default.timeoutIntervalForRequest = timeoutIntervalForRequest
}
Configuration.terra.setup(timeoutIntervalForRequest: 30)

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
Configuration.terra.setup(timeoutIntervalForRequest: 20,
                               responsePattern: pattern,
                               msgDisplayer: { (msg, msgType, onView) in
                                
        }, errorHandler: { (error) in
                                
        }, dnsParser: { (host) -> String in
                                
        }) { (signData) -> String? in
            
        }
```



#### 插件

* 请求自定义插件：支持在请求发送之前修改URLRequest

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

* 响应修改插件：支持在完成回调之前修改响应结果

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
NetStateMonitor.terra.startMonitoring()
// 关闭网络监听
NetStateMonitor.terra.stopMonitoring()
```

#### 状态监听

```swift
// 1 Block
NetStateMonitor.terra.addObserver(self) { (networkType, isReachable) in
	// handle
	print("networkType:\(networkType) isReachable: \(isReachable)")
}
NetStateMonitor.terra.notify(observer: self) { (networkType, isReachable) in

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
