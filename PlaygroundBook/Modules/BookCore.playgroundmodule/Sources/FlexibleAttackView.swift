//
//  FlexibleAttackView.swift
//  BookCore
//
//  Created by Q YiZhong on 2020/2/29.
//

import UIKit

class FlexibleAttackView: UIView {
    
    var level: CGFloat = 0 {
        willSet {
            guard let sv = superview else { return }
            //adjust
            height = min(110 + newValue * 1500, sv.height)
            flexibleView.height = height - 90
            flexibleView.y = fistImageView.frame.maxY
            y = sv.height - height
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(fistImageView)
        addSubview(flexibleView)
        flexibleView.x = fistImageView.center.x - 10
        flexibleView.y = fistImageView.frame.maxY
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    lazy var fistImageView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "fist"))
        view.frame = CGRect(x: 0, y: 0, width: 90, height: 90)
        return view
    }()
    
    lazy var flexibleView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 20))
        view.backgroundColor = UIColor.hex(0xDEB09E)
        return view
    }()

}
