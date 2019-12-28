//
//  Proxy.swift
//  Terra
//
//  Created by DATree on 2019/12/26.
//

import Foundation

public struct Terra<Base> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

public protocol TerraCompatible {
    associatedtype Base
    static var terra: Terra<Base>.Type { get set }
    var terra: Terra<Base> { get set }
}

extension TerraCompatible {
    public static var terra: Terra<Self>.Type {
        get { return Terra<Self>.self }
        set { }
    }
    
    public var terra: Terra<Self> {
        get { return Terra(self) }
        set { }
    }
}
