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
public typealias TerraMapperCompletion<T: BaseMappable> = (_ result: Result<T, MoyaError>) -> Void
public typealias TerraMapperListCompletion<T: BaseMappable> = (_ result: Result<[T], MoyaError>) -> Void
public typealias TerraCodableCompletion<T: Decodable> = (_ result: Result<T, MoyaError>) -> Void

extension MoyaProvider: TerraCompatible {}

// MARK: Convenience Adapter

extension TargetType {
    public static func adapter(plugins: [PluginType] = Configuration.default.plugins) -> MoyaProvider<Self> {
        return MoyaProvider<Self>(plugins: plugins)
    }
}

// MARK: Keypath of Response Body:  JSON to Model

public enum BodyKeyPath {
    
    case `default`
    case custom(String)
    
    var keyPath: String {
        switch self {
        case .default:
            return Configuration.default.responsePattern.bodyKeyPath
        case .custom(let keyPath):
            return keyPath
        }
    }
}

// MARK: Terra Extensions Of Request

extension Terra where Base: MoyaProviderType {
    
    @discardableResult
    public func requestModel<T: BaseMappable>( _ type: T.Type,
                                               target: Base.Target,
                                               keyPath: BodyKeyPath = .default,
                                               callbackQueue: DispatchQueue? = nil,
                                               progress: Moya.ProgressBlock? = nil,
                                               completion: @escaping TerraMapperCompletion<T>) -> Cancellable {
        
        return base.request(target, callbackQueue: callbackQueue, progress: progress) { (result) in
            switch result {
            case .success(let response):
                do {
                    let keyPath = keyPath.keyPath
                    let model = try (keyPath.isEmpty ? response.mapObject(T.self) : response.mapObject(T.self, atKeyPath: keyPath))
                    completion(.success(model))
                } catch {
                    if error is MoyaError {
                        completion(.failure(error as! MoyaError))
                    } else {
                        completion(.failure(.underlying(error, response)))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    @discardableResult
    public func requestModelList<T: BaseMappable>( _ type: T.Type,
                                                   target: Base.Target,
                                                   keyPath: BodyKeyPath = .default,
                                                   callbackQueue: DispatchQueue? = nil,
                                                   progress: Moya.ProgressBlock? = nil,
                                                   completion: @escaping TerraMapperListCompletion<T>) -> Cancellable {
        return base.request(target, callbackQueue: callbackQueue, progress: progress) { (result) in
            switch result {
            case .success(let response):
                do {
                    let keyPath = keyPath.keyPath
                    let modelList = try (keyPath.isEmpty ? response.mapArray(T.self) : response.mapArray(T.self, atKeyPath: keyPath))
                    completion(.success(modelList))
                } catch {
                    if error is MoyaError {
                        completion(.failure(error as! MoyaError))
                    } else {
                        completion(.failure(.underlying(error, response)))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    @discardableResult
    public func requestModel<T: Decodable>( _ type: T.Type,
                                            target: Base.Target,
                                            keyPath: BodyKeyPath = .default,
                                            callbackQueue: DispatchQueue? = nil,
                                            progress: Moya.ProgressBlock? = nil,
                                            completion: @escaping TerraCodableCompletion<T>) -> Cancellable {
        
        return base.request(target, callbackQueue: callbackQueue, progress: progress) { (result) in
            switch result {
            case .success(let response):
                do {
                    let keyPath = keyPath.keyPath
                    let model = try response.map(T.self, atKeyPath: keyPath)
                    completion(.success(model))
                } catch {
                    if error is MoyaError {
                        completion(.failure(error as! MoyaError))
                    } else {
                        completion(.failure(.underlying(error, response)))
                    }
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
                .takeLast(1)
                .mapObject(T.self, atKeyPath: keyPath.keyPath)
                .observeOn(MainScheduler.instance)
        }
        return request(token, callbackQueue: callbackQueue)
            .asObservable()
            .takeLast(1)
            .mapObject(T.self)
            .observeOn(MainScheduler.instance)
    }
    
    func requestModelList<T: BaseMappable>(_ token: Base.Target,
                                           keyPath: BodyKeyPath = .default,
                                           callbackQueue: DispatchQueue? = nil) -> Observable<[T]> {
        if !keyPath.keyPath.isEmpty {
            return request(token, callbackQueue: callbackQueue)
                .asObservable()
                .takeLast(1)
                .mapArray(T.self, atKeyPath: keyPath.keyPath)
                .observeOn(MainScheduler.instance)
        }
        return request(token, callbackQueue: callbackQueue)
            .asObservable()
            .takeLast(1)
            .mapArray(T.self)
            .observeOn(MainScheduler.instance)
    }
    
    func requestModel<T: Decodable>(_ token: Base.Target,
                                    keyPath: BodyKeyPath = .default,
                                    callbackQueue: DispatchQueue? = nil) -> Observable<T> {
        return request(token, callbackQueue: callbackQueue)
            .asObservable()
            .takeLast(1)
            .map(T.self, atKeyPath: keyPath.keyPath)
            .observeOn(MainScheduler.instance)
    }
    
    //  Single
    
    func requestModel<T: BaseMappable>(_ token: Base.Target,
                                       keyPath: BodyKeyPath = .default,
                                       callbackQueue: DispatchQueue? = nil) -> Single<T> {
        return requestModel(token,
                            keyPath: keyPath,
                            callbackQueue: callbackQueue)
            .asSingle()
    }
    
    func requestModelList<T: BaseMappable>(_ token: Base.Target,
                                           keyPath: BodyKeyPath = .default,
                                           callbackQueue: DispatchQueue? = nil) -> Single<[T]> {
        return requestModelList(token,
                                keyPath: keyPath,
                                callbackQueue: callbackQueue)
            .asSingle()
    }
    
    func requestModel<T: Decodable>(_ token: Base.Target,
                                    keyPath: BodyKeyPath = .default,
                                    callbackQueue: DispatchQueue? = nil) -> Single<T> {
        return requestModel(token,
                            keyPath: keyPath,
                            callbackQueue: callbackQueue)
            .asSingle()
    }
}
