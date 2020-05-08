//
//  HealthValueView.swift
//  BookCore
//
//  Created by Q YiZhong on 2020/5/8.
//

import UIKit

class HealthValueView: UIView {
    
    public var health = 0 {
        willSet {
            subviews.forEach { $0.removeFromSuperview() }
            var offset: CGFloat = 0
            for _ in 0..<newValue {
                let view = UIImageView(image: UIImage(named: "health"))
                addSubview(view)
                view.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
                view.x = offset
                offset += 45
            }
        }
    }

}
