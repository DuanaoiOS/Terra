//
//  Terra.swift
//  Terra
//
//  Created by DATree on 2019/12/26.
//

import Foundation
import Moya
import ObjectMapper
import RxSwift

// MARK: Typealias Of Completion
public typealias TerraModelCompletion<T: BaseMappable> = (_ result: Result<T, MoyaError>) -> Void
public typealias TerraModelListCompletion<T: BaseMappable> = (_ result: Result<[T], MoyaError>) -> Void

extension MoyaProvider: TerraCompatible {}

// MARK: Convenience Adapter

extension TargetType {
    public static func adapter(plugins: [PluginType] = []) -> MoyaProvider<Self> {
        let allPlugins: [PluginType] = [SignaturePlugin(), DNSPlugin(), ServerResponsePlugin()] + plugins
        return MoyaProvider<Self>(plugins: allPlugins)
    }
}

// MARK: Keypath of Response Body:  JSON to Model

public enum BodyKeyPath {
    
    case `default`
    case custom(String)
    
    var keyPath: String {
        switch self {
        case .default:
            return Configuration.default.serverResponse.bodyKey
        case .custom(let keyPath):
            return keyPath
        }
    }
}

// MARK: Terra Extensions Of Request

extension Terra where Base: MoyaProviderType {
    
    @discardableResult
    public func requestModel<T: BaseMappable>(_ target: Base.Target,
                                              keyPath: BodyKeyPath = .default,
                                              callbackQueue: DispatchQueue? = nil,
                                              progress: Moya.ProgressBlock? = nil,
                                              completion: @escaping TerraModelCompletion<T>) -> Cancellable {
        
        return base.request(target, callbackQueue: callbackQueue, progress: progress) { (result) in
            switch result {
            case .success(let response):
                do {
                    let keyPath = keyPath.keyPath
                    let model = try (keyPath.isEmpty ? response.mapObject(T.self) : response.mapObject(T.self, atKeyPath: keyPath))
                    completion(.success(model))
                } catch MoyaError.jsonMapping {
                    completion(.failure(MoyaError.jsonMapping(response)))
                } catch {
                    completion(.failure(.underlying(error, response)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    @discardableResult
    public func requestModelList<T: BaseMappable>(_ target: Base.Target,
                                                   keyPath: BodyKeyPath = .default,
                                                   callbackQueue: DispatchQueue? = nil,
                                                   progress: Moya.ProgressBlock? = nil,
                                                   completion: @escaping TerraModelListCompletion<T>) -> Cancellable {
        return base.request(target, callbackQueue: callbackQueue, progress: progress) { (result) in
            switch result {
            case .success(let response):
                do {
                    let keyPath = keyPath.keyPath
                    let modelList = try (keyPath.isEmpty ? response.mapArray(T.self) : response.mapArray(T.self, atKeyPath: keyPath))
                    completion(.success(modelList))
                } catch MoyaError.jsonMapping {
                    completion(.failure(MoyaError.jsonMapping(response)))
                } catch {
                    completion(.failure(.underlying(error, response)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

// MARK: Rx Extensions Of Request
public extension Reactive where Base: MoyaProviderType {
    
    //  Observable
    
    func requestModel<T: BaseMappable>(_ token: Base.Target,
                                       keyPath: BodyKeyPath = .default,
                                       callbackQueue: DispatchQueue? = nil) -> Observable<T> {
        if !keyPath.keyPath.isEmpty {
            return request(token, callbackQueue: callbackQueue)
                .asObservable()
                .mapObject(T.self,
                           atKeyPath: keyPath.keyPath)
        }
        return request(token, callbackQueue: callbackQueue)
            .asObservable()
            .mapObject(T.self)
    }
    
    func requestModelList<T: BaseMappable>(_ token: Base.Target,
                                           keyPath: BodyKeyPath = .default,
                                           callbackQueue: DispatchQueue? = nil) -> Observable<[T]> {
        if !keyPath.keyPath.isEmpty {
            return request(token, callbackQueue: callbackQueue)
                .asObservable()
                .mapArray(T.self,
                          atKeyPath: keyPath.keyPath)
        }
        return request(token, callbackQueue: callbackQueue)
            .asObservable()
            .mapArray(T.self)
    }
    
    //  Single
    
    func requestModel<T: BaseMappable>(_ token: Base.Target,
                                       keyPath: BodyKeyPath = .default,
                                       callbackQueue: DispatchQueue? = nil) -> Single<T> {
        if !keyPath.keyPath.isEmpty {
            return request(token, callbackQueue: callbackQueue)
                .mapObject(T.self,
                           atKeyPath: keyPath.keyPath)
        }
        return request(token, callbackQueue: callbackQueue)
            .mapObject(T.self)
    }
    
    func requestModelList<T: BaseMappable>(_ token: Base.Target,
                                           keyPath: BodyKeyPath = .default,
                                           callbackQueue: DispatchQueue? = nil) -> Single<[T]> {
        if !keyPath.keyPath.isEmpty {
            return request(token, callbackQueue: callbackQueue)
                .mapArray(T.self,
                          atKeyPath: keyPath.keyPath)
        }
        return request(token, callbackQueue: callbackQueue)
            .mapArray(T.self)
    }
}
