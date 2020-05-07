//
//  StringExtension.swift
//  BookCore
//
//  Created by Q YiZhong on 2020/5/7.
//

import Foundation
import UIKit

extension String {
    
    static func documentPath() -> String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true).first ?? NSHomeDirectory() + "/Documents"
    }
    
    static func timestamp() -> String {
        let timeInterval: TimeInterval = NSDate().timeIntervalSince1970
        return "\(Int(timeInterval))"
    }
    
}
