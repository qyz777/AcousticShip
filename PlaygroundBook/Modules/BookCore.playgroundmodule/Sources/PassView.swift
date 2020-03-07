//
//  PassView.swift
//  BookCore
//
//  Created by Q YiZhong on 2020/3/7.
//

import UIKit

class PassView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(leftLabel)
        addSubview(rightLabel)
        addSubview(centerLabel)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        leftLabel.x = 0
        leftLabel.y = 0
        rightLabel.x = width - rightLabel.width
        rightLabel.y = 0
        centerLabel.center = CGPoint(x: 200, y: 100)
    }
    
    private lazy var leftLabel: UILabel = {
        let view = UILabel()
        view.text = "🎉  🥳"
        view.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        view.sizeToFit()
        return view
    }()
    
    private lazy var rightLabel: UILabel = {
        let view = UILabel()
        view.text = "🎉  🥳"
        view.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        view.sizeToFit()
        view.transform = .init(scaleX: -1, y: 1)
        return view
    }()
    
    lazy var centerLabel: UILabel = {
        let view = UILabel()
        view.text = "Pass!"
        view.font = UIFont.systemFont(ofSize: 60, weight: .bold)
        view.textColor = .systemGreen
        view.sizeToFit()
        return view
    }()

}
