//
//  See LICENSE folder for this template’s licensing information.
//
//  Abstract:
//  A source file which is part of the auxiliary module named "BookCore".
//  Provides the implementation of the "always-on" live view.
//

import UIKit
import PlaygroundSupport

@objc(BookCore_LiveViewController)
public class LiveViewController: UIViewController, PlaygroundLiveViewMessageHandler, PlaygroundLiveViewSafeAreaContainer {
    
    var audioRecorder: AudioRecorder?
    var displayLink: CADisplayLink?
    var lastCenterX: CGFloat = 0
    
    var timer: Timer?
    
    /*
    public func liveViewMessageConnectionOpened() {
        // Implement this method to be notified when the live view message connection is opened.
        // The connection will be opened when the process running Contents.swift starts running and listening for messages.
    }
    */

    /*
    public func liveViewMessageConnectionClosed() {
        // Implement this method to be notified when the live view message connection is closed.
        // The connection will be closed when the process running Contents.swift exits and is no longer listening for messages.
        // This happens when the user's code naturally finishes running, if the user presses Stop, or if there is a crash.
    }
    */

    public func receive(_ message: PlaygroundValue) {
        // Implement this method to receive messages sent from the process running Contents.swift.
        // This method is *required* by the PlaygroundLiveViewMessageHandler protocol.
        // Use this method to decode any messages sent as PlaygroundValue values and respond accordingly.
    }
    
    public override func viewDidLoad() {
        view.backgroundColor = .black
        view.addSubview(testLabel)
        view.addSubview(flexibleView)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
        view.addGestureRecognizer(pan)
        
        do {
            try audioRecorder = AudioRecorder()
        } catch {
            print(error)
        }
        displayLink?.invalidate()
        displayLink = CADisplayLink(target: self, selector: #selector(setupRecorderLevel))
        displayLink?.add(to: RunLoop.current, forMode: .common)
        audioRecorder?.record()
        play()
    }
    
    //MARK: Private
    
    private func play() {
        let height: CGFloat = 100
        var paths: [CGFloat] = []
        var offsetY: CGFloat = 225
        for i in 0..<4 {
            if i == 0 {
                paths.append(offsetY)
            } else {
                offsetY += height
                paths.append(offsetY)
            }
        }
        timer = Timer(timeInterval: 1, repeats: true, block: { [unowned self] (t) in
            let value = Int.randomIntNumber(lower: 0, upper: 4)
            let centerY = paths[value]
            let targetView = TargetView(frame: CGRect(x: 0, y: 0, width: height, height: height))
            targetView.center.y = centerY
            targetView.x = -height
            self.view.addSubview(targetView)
            self.addAnimation(targetView)
        })
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    private func stop() {
        timer?.invalidate()
        view.subviews.forEach {
            if $0.isKind(of: TargetView.self) {
                $0.removeFromSuperview()
            }
        }
    }
    
    private func addAnimation(_ view: UIView) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.fromValue = NSValue(cgPoint: view.layer.position)
        animation.toValue = NSValue(cgPoint: CGPoint(x: view.superview?.width ?? 0 + 50, y: view.layer.position.y))
        animation.duration = 10
        animation.autoreverses = false
        animation.beginTime = CACurrentMediaTime()
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        animation.delegate = self
        view.layer.add(animation, forKey: "path_animation")
    }
    
    //MARK: Action
    
    @objc
    private func pan(_ pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .began:
            lastCenterX = flexibleView.center.x
        case .changed:
            let offsetX = pan.translation(in: view).x
            flexibleView.center.x = lastCenterX + offsetX
        default:
            break
        }
    }
    
    @objc
    private func setupRecorderLevel() {
        guard let recorder = audioRecorder?.recorder else { return }
        recorder.updateMeters()
        let normalizedValue = pow(10, recorder.averagePower(forChannel: 0) / 100)
        let level = CGFloat(normalizedValue)
        testLabel.text = String(format: "%.10f", level)
        flexibleView.level = level
    }
    
    //MARK: Getter
    
    lazy var testLabel: UILabel = {
        let view = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 22))
        view.textColor = .white
        return view
    }()
    
    lazy var flexibleView: FlexibleAttackView = {
        let view = FlexibleAttackView(frame: CGRect(x: 0, y: self.view.height - 110, width: 20, height: 110))
        view.center.x = self.view.center.x
        return view
    }()
    
    
}

extension LiveViewController: CAAnimationDelegate {
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        view.subviews.forEach {
            if $0.isKind(of: TargetView.self) {
                guard let layer = $0.layer.presentation() else {
                    $0.removeFromSuperview()
                    return
                }
                if layer.position.x >= view.width - 50 {
                    $0.removeFromSuperview()
                }
            }
        }
    }
    
}
