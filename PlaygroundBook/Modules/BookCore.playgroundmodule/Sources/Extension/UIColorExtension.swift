//
//  UIColorExtension.swift
//  BookCore
//
//  Created by Q YiZhong on 2020/5/7.
//

import Foundation
import UIKit

extension UIColor {
    
    static func hex(_ hex: Int, alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
                       green: CGFloat((hex & 0xFF00) >> 8) / 255.0,
                       blue: CGFloat(hex & 0xFF) / 255.0,
                       alpha: 1.0)
    }
    
}
