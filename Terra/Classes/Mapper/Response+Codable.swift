//
//  Response+Codabe.swift
//  Terra
//
//  Created by DATree on 2019/12/30.
//

import Foundation
import SwiftyJSON
import Moya

extension Response {
    
    public func mapArray<T: Decodable>(_ type: T.Type, atKeyPath keyPath: String) throws -> [T] {
      guard let array = (try mapJSON() as? NSDictionary)?.value(forKeyPath: keyPath) as? [[String : Any]] else {
        throw MoyaError.jsonMapping(self)
      }
      return array.compactMap {JSON($0).decodable(of: type)}
    }
}

extension JSON {
    public init<T: Encodable>(encodable: T) {
        do {
            try self.init(data: JSONEncoder().encode(encodable))
        } catch {
            self.init()
        }
    }
    
    public func decodable<T: Decodable>(of type: T.Type) -> T? {
        do {
            return try JSONDecoder().decode(type, from: rawData())
        } catch {
            return nil
        }
    }
}
