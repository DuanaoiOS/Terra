//
//  TargetTypeAddable.swift
//  Terra
//
//  Created by DATree on 2019/12/26.
//

import Moya

private let sampleData = Data()

public extension TargetType {
    var method: Moya.Method { return .post }
    var sampleData: Data { return sampleData }
}
