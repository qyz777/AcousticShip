//
//  TargetView.swift
//  BookCore
//
//  Created by Q YiZhong on 2020/2/29.
//

import UIKit

let TARGET_SIZE: CGFloat = UIFont.systemFont(ofSize: 50).pointSize + 5

class TargetView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        label.frame = bounds
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    lazy var label: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 50)
        view.text = "😈"
        return view
    }()

}
