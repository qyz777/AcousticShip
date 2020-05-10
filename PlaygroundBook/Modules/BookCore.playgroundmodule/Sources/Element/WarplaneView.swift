//
//  WarplaneView.swift
//  BookCore
//
//  Created by Q YiZhong on 2020/5/10.
//

import UIKit

class WarplaneView: UIView {
    
    public var warplaneStyle: String = "warplane_1" {
        willSet {
            imageView.image = UIImage(named: newValue)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        imageView.frame = bounds
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let inset = UIEdgeInsets(top: -20, left: -20, bottom: -20, right: -20)
        let hitFrame = bounds.inset(by: inset)
        return hitFrame.contains(point)
    }

    private lazy var imageView: UIImageView = {
        let view = UIImageView(image: UIImage(named: warplaneStyle))
        return view
    }()

}
