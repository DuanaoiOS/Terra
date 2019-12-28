//
//  ReachabilityManager.swift
//  vt-socket
//
//  Created by DATree on 2019/9/16.
//

import Foundation
import CoreTelephony
import SystemConfiguration
import Alamofire

private var associatedObjectKey: Void?

extension Notification.Name {
    
    public static var netBecomeReachable: Notification.Name {
        return Notification.Name("ReachabilityManager.BecomeReachable.Notification")
    }
    
    public static var netReachableDidChange: Notification.Name {
        return Notification.Name("ReachabilityManager.ReachableDidChange.Notification")
    }
    
    public static var netStatusDidChange: Notification.Name {
        return Notification.Name("ReachabilityManager.StatusDidChange.Notification")
    }
}

public enum NetworkType: Int {
    case wifi = 1
    case wwan4G = 2
    case wwan3G = 3
    case wwan2G = 4
    case notReachable = 5
    
    func isWifi() -> Bool {
        return self == .wifi
    }
    
    func isWwan() -> Bool {
        return self == .wwan2G || self == .wwan3G || self == .wwan4G
    }
}

public typealias NetStatusCallback = (_ networkType: NetworkType, _ isReachable: Bool) -> Void

protocol NetStatusService {
    var accessType: NetworkType { get }
    var isReachable: Bool { get }
    func addObserver(_ observer: AnyObject, _ block: @escaping NetStatusCallback)
}

public class NetStateMonitor: NetStatusService {
    
    public static let `default` = NetStateMonitor()
    private let networkInfo = CTTelephonyNetworkInfo()
    private let cellularData = CTCellularData.init()
    fileprivate let reachabilityManager = NetworkReachabilityManager()

    public private(set) var observers: NSHashTable<AnyObject>
    public private(set) var accessType: NetworkType = .notReachable {
        didSet {
            if oldValue != accessType {
                NotificationCenter.default
                    .post(name: NSNotification.Name.netStatusDidChange, object: nil)
                isReachable = accessType != .notReachable
            }
        }
    }
    public private(set) var isReachable: Bool = false {
        didSet {
            if oldValue != isReachable {
                NotificationCenter.default
                    .post(name: NSNotification.Name.netReachableDidChange, object: nil)
                if isReachable {
                   NotificationCenter.default
                    .post(name: NSNotification.Name.netBecomeReachable, object: nil)
                }
            }
        }
    }
    
    private init() {
        observers = NSHashTable(options: .weakMemory)
        guard let manager = reachabilityManager else { return }
        accessType = self.accessTypeFor(connection: manager.networkReachabilityStatus)
    }
    
    internal func addObserver(_ observer: AnyObject, _ block: @escaping NetStatusCallback) {
        objc_setAssociatedObject(observer,
                                 &associatedObjectKey, block,
                                 .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        self.observers.add(observer)
        block(self.accessType, self.isReachable)
    }
    
    fileprivate func notify(observer: AnyObject, callback: @escaping NetStatusCallback) {
        self.addObserver(observer, callback)
    }
    
    fileprivate func updateNetwork(connection: NetworkReachabilityManager.NetworkReachabilityStatus) {
        self.accessType = accessTypeFor(connection: connection)
        let observers = self.observers.allObjects
        for observer in observers {
            let block = objc_getAssociatedObject(observer, &associatedObjectKey)
            guard let callback = block as? NetStatusCallback else { return}
            callback(self.accessType, self.isReachable)
        }
//        if self.accessType == .notReachable {
//            let extraInfo = ["celluarState": celluarState.rawValue, "isRestricted": celluarState == .restricted] as [String: Any]
//            Logger.debug("nonet, celluar restrict info ", extraInfo: extraInfo)
//        }
    }
    
    private func accessTypeFor(connection: NetworkReachabilityManager.NetworkReachabilityStatus) -> NetworkType {
        let wwanType = networkInfo.wwanType()
        switch connection {
        case .reachable(let connectionType):
            switch connectionType {
            case .ethernetOrWiFi:
                return .wifi
            case .wwan:
                switch wwanType {
                case .wwan2G: return .wwan2G
                case .wwan3G: return .wwan3G
                case .wwan4G: return .wwan4G
                case .unknown: return .wwan4G
                }
            }
        case .unknown, .notReachable:
            return .notReachable
        }
    }
}

extension CTTelephonyNetworkInfo {
    fileprivate enum WwanType: Int {
        case wwan2G
        case wwan3G
        case wwan4G
        case unknown
    }
    
    fileprivate func wwanType() -> WwanType {
        var type: WwanType = .unknown
        guard let carrierType = self.currentRadioAccessTechnology else {
//            Logger.debug("can not get carrier type")
            return .unknown
        }
//        DispatchQueue.main.once {
//            Logger.debug("carriertype is \(carrierType)")
//        }
        switch carrierType {
        case CTRadioAccessTechnologyGPRS,
             CTRadioAccessTechnologyEdge,
             CTRadioAccessTechnologyCDMA1x:
            type = .wwan2G
        case CTRadioAccessTechnologyWCDMA,
             CTRadioAccessTechnologyHSDPA,
             CTRadioAccessTechnologyHSUPA,
             CTRadioAccessTechnologyCDMAEVDORev0,
             CTRadioAccessTechnologyCDMAEVDORevA,
             CTRadioAccessTechnologyCDMAEVDORevB,
             CTRadioAccessTechnologyeHRPD:
            type = .wwan3G
        case CTRadioAccessTechnologyLTE:
            type = .wwan4G
        default: type = .unknown
        }
        return type
    }
}

extension NetStateMonitor: TerraCompatible {}

extension Terra where Base: NetStateMonitor {
    
    // MARK: - Monitoring
    
    public static func startMonitoring() {
        NetStateMonitor.default.reachabilityManager?.startListening()
        NetStateMonitor.default.reachabilityManager?.listener = { NetStateMonitor.default.updateNetwork(connection: $0) }
    }
    
     public static func stopMonitoring() {
        NetStateMonitor.default.reachabilityManager?.stopListening()
    }
    
     // MARK: - Observer
    
    public static func addObserver(_ observer: AnyObject, _ block: @escaping NetStatusCallback) {
        NetStateMonitor.default.addObserver(observer, block)
    }
    
    public static func notify(observer: AnyObject, callback: @escaping NetStatusCallback) {
        NetStateMonitor.default.notify(observer: observer, callback: callback)
    }
}
