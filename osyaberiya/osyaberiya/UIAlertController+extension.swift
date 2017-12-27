//
//  UIAlertController+extension.swift
//  osyaberiya
//
//  Created by koooootake on 2017/12/17.
//  Copyright © 2017年 koooootake. All rights reserved.
//

import Foundation

extension UIAlertController {
    
    static func show(title: String, message: String) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: UtilModel.okMessage, style: .default, handler: nil)
        alertController.addAction(action)
        return alertController
    }
}
