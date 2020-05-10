//
//  StartView.swift
//  BookCore
//
//  Created by Q YiZhong on 2020/3/7.
//

import UIKit

class StartView: UIView {
    
    private var timer: Timer?
    
    var completeClosure: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(startButton)
        addSubview(infoLabel)
        addSubview(numberLabel)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        startButton.sizeToFit()
        startButton.center = CGPoint(x: width / 2.0, y: height / 2.0)
        numberLabel.center = CGPoint(x: width / 2.0, y: height / 2.0)
        infoLabel.sizeToFit()
        infoLabel.y = startButton.frame.maxY
        infoLabel.center.x = startButton.center.x
    }
    
    @objc
    func start() {
        startButton.isHidden = true
        infoLabel.isHidden = true
        numberLabel.isHidden = false
        var index = 2
        timer = Timer(timeInterval: 1, repeats: true, block: { [unowned self] (t) in
            guard index > 0 else {
                self.timer?.invalidate()
                self.removeFromSuperview()
                self.completeClosure?()
                return
            }
            self.numberLabel.text = "\(index)"
            index -= 1
        })
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    private lazy var startButton: UIButton = {
        let view = UIButton(type: .custom)
        view.setTitle("Start", for: .normal)
        view.setTitleColor(.white, for: .normal)
        view.titleLabel?.font = UIFont.systemFont(ofSize: 60, weight: .semibold)
        view.addTarget(self, action: #selector(start), for: .touchUpInside)
        return view
    }()
    
    private lazy var infoLabel: UILabel = {
        let view = UILabel()
        view.text = "Tap to start!"
        view.textColor = .white
        view.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        view.textAlignment = .center
        return view
    }()
    
    private lazy var numberLabel: UILabel = {
        let view = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 60))
        view.text = "3"
        view.textColor = .white
        view.font = UIFont.systemFont(ofSize: 60, weight: .light)
        view.isHidden = true
        view.textAlignment = .center
        return view
    }()

}
