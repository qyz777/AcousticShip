//
//  TargetView.swift
//  BookCore
//
//  Created by Q YiZhong on 2020/2/29.
//

import UIKit

let TARGET_SIZE: CGFloat = 50

class TargetView: UIView {
    
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
        let view = UIImageView()
        return view
    }()

}
