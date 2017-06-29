//
//  Flash.swift
//  ToDoDemo
//
//  Created by panxinyu on 2017-29-06.
//  Copyright © 2017年 panxinyu. All rights reserved.
//

import UIKit

extension UIViewController {
    typealias AlertCallback =  ((UIAlertAction) -> Void)

    func flash(title: String, message: String, callback: AlertCallback? = nil) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.alert)

        let okAction = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.default,
            handler: callback)

        alertController.addAction(okAction)

        self.present(alertController, animated: true, completion: nil)
    }
}
