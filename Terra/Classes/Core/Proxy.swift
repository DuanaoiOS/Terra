//
//  Proxy.swift
//  Terra
//
//  Created by DATree on 2019/12/26.
//

import Foundation

public struct TerraWrapper<Base> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

public protocol TerraCompatible {
    associatedtype Base
    static var terra: TerraWrapper<Base>.Type { get set }
    var terra: TerraWrapper<Base> { get set }
}

extension TerraCompatible {
    public static var terra: TerraWrapper<Self>.Type {
        get { return TerraWrapper<Self>.self }
        set { }
    }
    
    public var terra: TerraWrapper<Self> {
        get { return TerraWrapper(self) }
        set { }
    }
}

public struct Terra {}
