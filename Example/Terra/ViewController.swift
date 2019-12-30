//
//  ViewController.swift
//  Terra
//
//  Created by DATree on 12/26/2019.
//  Copyright (c) 2019 DATree. All rights reserved.
//

import UIKit
import Terra
import Moya
import RxSwift
import ReactiveSwift

class ViewController: UIViewController {
    
    private var repos = [Repository]()
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rxDownloadRepositories("DuanaoiOS")
            .subscribe(onNext: { (repos) in
                self.repos = repos
            }, onError: { (error) in
                print(error.localizedDescription)
            }).disposed(by: disposeBag)
        
        reactDownloadRepositories("DuanaoiOS").start { (event) in
            switch event {
            case .value(let repos):
                self.repos = repos
            case .failed(let error):
                error.display(on: self.view)
            default: break
            }
        }
    }
    
    fileprivate func showAlert(_ title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func downloadRepositories(_ username: String) {
        gitHubProvider.terra
            .requestModelList(Repository.self, target: .userRepositories(username)) { [weak self] (result) in
                guard let `self` = self else {return}
                switch result {
                case .success(let repos):
                    self.repos = repos
                case .failure(let error):
                    error.display(on: self.view)
                }
        }
    }
    
    func rxDownloadRepositories(_ username: String) -> Observable<[Repository]> {
        return gitHubProvider.rx
            .requestModelList(Repository.self, token: .userRepositories(username))
            .asObservable()
            .take(1)
            .observeOn(MainScheduler.instance)
    }
    
    func reactDownloadRepositories(_ username: String) -> SignalProducer<[Repository], MoyaError> {
        return gitHubProvider.reactive
            .requestModelList(Repository.self, token: .userRepositories(username))
            .take(last: 1)
            .observe(on: QueueScheduler.main)
    }
    
    func downloadZen() {
        gitHubProvider.terra.requestString(.zen, keyPath: .custom("")) { result in
            var message = "Couldn't access API"
            if case let .success(response) = result {
                message = response
            }
            self.showAlert("Zen", message: message)
        }
    }
}

