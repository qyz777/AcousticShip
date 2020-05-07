//
//  GuidedMissileView.swift
//  BookCore
//
//  Created by Q YiZhong on 2020/5/7.
//

import UIKit

let GUIDED_MISSILE_HEIGHT: CGFloat = 60
let GUIDED_MISSILE_WIDTH: CGFloat = 20

class GuidedMissileView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
    }

    lazy var imageView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "guided_missile"))
        return view
    }()

}
