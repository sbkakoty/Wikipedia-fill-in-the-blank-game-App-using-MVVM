//
//  UIButton+Extension.swift
//  FillITheBlanksGame
//
//  Created by MacBook on 8/23/22.
//

import Foundation
import UIKit

extension UIButton {
    
    func shadow() -> UIButton {
        
        let view = UIButton()
        view.layer.shadowColor = UIColor.lightGray.cgColor
        view.layer.shadowOffset = CGSize(width: 2.0, height: 4.0)
        view.layer.shadowOpacity = 0.5
        view.layer.shadowRadius = 3.0
        view.layer.masksToBounds = false
        view.layer.cornerRadius = 0.0
        return view
    }
}
