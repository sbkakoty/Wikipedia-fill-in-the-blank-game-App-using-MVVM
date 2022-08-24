//
//  UILabel+Extension.swift
//  FillITheBlanksGame
//
//  Created by MacBook on 8/23/22.
//

import Foundation
import UIKit

extension UILabel {
    
    func shadow() -> UILabel {
        
        let view = UILabel()
        view.shadowColor = UIColor.gray
        view.shadowOffset = CGSize(width: 1, height: 1)
        view.shadowColor = UIColor.gray
        
        return view
    }
    
    func rectForText() -> CGSize {
        let attrString = NSAttributedString.init(string: self.text!, attributes: [NSAttributedString.Key.font:self.font!])
        let rect = attrString.boundingRect(with: CGSize(width: self.frame.width, height:999), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        let size = CGSize(width: rect.size.width, height: rect.size.height)
        return size
    }
}
