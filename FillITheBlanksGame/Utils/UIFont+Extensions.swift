//
//  UIFont+Extensions.swift
//  FillITheBlanksGame
//
//  Created by MacBook on 8/22/22.
//

import Foundation
import UIKit

extension UIFont {
    func preferredFont(withTextStyle textStyle: UIFont.TextStyle, maxSize: CGFloat) -> UIFont {
        // Get the descriptor
        let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: textStyle)

        // Return a font with the minimum size
        return UIFont(descriptor: fontDescriptor, size: min(fontDescriptor.pointSize, maxSize))
    }
    
    func withTraits(traits:UIFontDescriptor.SymbolicTraits) -> UIFont {
        let descriptor = fontDescriptor.withSymbolicTraits(traits)
        return UIFont(descriptor: descriptor!, size: 0) //size 0 means keep the size as it is
    }

    func bold() -> UIFont {
        return withTraits(traits: .traitBold)
    }

    func italic() -> UIFont {
        return withTraits(traits: .traitItalic)
    }
}
