//
//  FailedView.swift
//  LiveViewTestApp
//
//  Created by Q YiZhong on 2020/3/7.
//

import UIKit

class FailedView: UIView {

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
        centerLabel.sizeToFit()
        centerLabel.center = CGPoint(x: width / 2.0, y: height / 2.0)
        leftLabel.sizeToFit()
        leftLabel.x = centerLabel.x - leftLabel.width - 5
        leftLabel.center.y = centerLabel.center.y
        rightLabel.sizeToFit()
        rightLabel.x = centerLabel.frame.maxX + 5
        rightLabel.center.y = centerLabel.center.y
    }
    
    private lazy var leftLabel: UILabel = {
        let view = UILabel()
        view.text = "😤"
        view.font = UIFont.systemFont(ofSize: 100, weight: .bold)
        view.sizeToFit()
        return view
    }()
    
    private lazy var rightLabel: UILabel = {
        let view = UILabel()
        view.text = "😤"
        view.font = UIFont.systemFont(ofSize: 100, weight: .bold)
        view.sizeToFit()
        view.transform = .init(scaleX: -1, y: 1)
        return view
    }()
    
    lazy var centerLabel: UILabel = {
        let view = UILabel()
        view.text = "Failed"
        view.font = UIFont.systemFont(ofSize: 60, weight: .bold)
        view.textColor = .systemRed
        view.sizeToFit()
        return view
    }()

}
