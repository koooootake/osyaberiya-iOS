//
//  LayoutModel.swift
//  osyaberiya
//
//  Created by koooootake on 2017/12/19.
//  Copyright © 2017年 koooootake. All rights reserved.
//

import Foundation

class LayoutModel: NSObject {
    
    static func dropShadow(view: UIView) {
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowOffset = CGSize(width: 0, height: 3)
        view.layer.shadowRadius = 3 // ぼかし量
        
        view.layer.shadowPath = UIBezierPath(roundedRect: view.bounds, cornerRadius: view.frame.width / 2).cgPath
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = UIScreen.main.scale
    }
    
    static func buttonAnimation(button: UIButton) {
        //アニメーション
        button.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        UIView.animate(withDuration: 1.0,
                       delay: 0,
                       usingSpringWithDamping: 0.15,
                       initialSpringVelocity: 5.0,
                       options: .allowUserInteraction,
                       animations: {
                        button.transform = .identity
        }, completion: nil)
    }
}
