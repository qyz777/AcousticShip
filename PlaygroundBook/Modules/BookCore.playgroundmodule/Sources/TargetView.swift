//
//  TargetView.swift
//  BookCore
//
//  Created by Q YiZhong on 2020/2/29.
//

import UIKit

enum TargetType {
    case normal
    case failed
}

class TargetView: UIView {
    
    var type: TargetType = .normal
    
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
