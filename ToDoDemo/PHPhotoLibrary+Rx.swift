//
//  PHPhotoLibrary+Rx.swift
//  ToDoDemo
//
//  Created by panxinyu on 2017-29-06.
//  Copyright © 2017年 panxinyu. All rights reserved.
//

import Foundation
import Photos
import RxSwift

extension PHPhotoLibrary {
    static var isAuthorized: Observable<Bool> {
        return Observable.create { observer in
            DispatchQueue.main.async {
                if authorizationStatus() == .authorized {
                    observer.onNext(true)
                    observer.onCompleted()
                } else {
                    requestAuthorization {
                        observer.onNext($0 == .authorized)
                        observer.onCompleted()
                    }
                }
            }
            return Disposables.create()
        }
    }
}
