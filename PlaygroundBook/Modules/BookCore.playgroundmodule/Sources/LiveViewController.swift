//
//  See LICENSE folder for this template’s licensing information.
//
//  Abstract:
//  A source file which is part of the auxiliary module named "BookCore".
//  Provides the implementation of the "always-on" live view.
//

import UIKit
import PlaygroundSupport
import AudioToolbox

public enum HitSoundType {
    case puff
    case bang
}

@objc(BookCore_LiveViewController)
public class LiveViewController: UIViewController, PlaygroundLiveViewMessageHandler, PlaygroundLiveViewSafeAreaContainer {
    
    private var audioRecorder: AudioRecorder?
    private var displayLink: CADisplayLink?
    private var lastCenterX: CGFloat = 0
    private var timer: Timer?
    
    public var targets: [String] = ["😈", "😈", "😈", "😈", "😈"]
    
    public var targetTop: CGFloat = 400
    
    public var shootTimeInterval: TimeInterval = 2
    
    public var hitSoundType: HitSoundType = .puff
    
    private var offsetIndex = 0
    
    private var audio1: SystemSoundID = 0
    private var audio2: SystemSoundID = 0
    
    private var isStop = true
    
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
        view.addSubview(flexibleView)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
        view.addGestureRecognizer(pan)
        
        setupAudio()
        
        do {
            try audioRecorder = AudioRecorder()
        } catch {
            print(error)
        }
        
        displayLink?.invalidate()
        displayLink = CADisplayLink(target: self, selector: #selector(setupRecorderLevel))
        displayLink?.add(to: RunLoop.current, forMode: .common)
        audioRecorder?.record()
        
        showStartView()
    }
    
    //MARK: Public
    
    public func play() {
        guard targets.count > 0 else {
            return
        }
        isStop = false
        shootTarget()
        timer = Timer(timeInterval: shootTimeInterval, repeats: true, block: { [unowned self] (t) in
            guard self.offsetIndex < self.targets.count else {
                return
            }
            self.shootTarget()
        })
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    //MARK: Private
    
    private func stop() {
        offsetIndex = 0
        timer?.invalidate()
    }
    
    private func setupAudio() {
        let path1 = Bundle.main.path(forResource: "audio1", ofType: "mp3")
        let url1 = NSURL(fileURLWithPath: path1 ?? "")
        AudioServicesCreateSystemSoundID(url1, &audio1)
        let path2 = Bundle.main.path(forResource: "audio2", ofType: "mp3")
        let url2 = NSURL(fileURLWithPath: path2 ?? "")
        AudioServicesCreateSystemSoundID(url2, &audio2)
    }
    
    private func shootTarget() {
        let size: CGFloat = 100
        let targetView = TargetView(frame: CGRect(x: 0, y: 0, width: size, height: size))
        targetView.label.text = self.targets[self.offsetIndex]
        targetView.y = self.targetTop
        targetView.x = -size
        view.addSubview(targetView)
        addAnimation(targetView)
        offsetIndex += 1
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
    
    private func showStartView() {
        let startView = StartView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        startView.completeClosure = { [unowned self] in
            self.play()
        }
        startView.center = view.center
        view.addSubview(startView)
    }
    
    private func showPassView() {
        let passView = PassView(frame: CGRect(x: 0, y: 0, width: 400, height: 200))
        passView.center = view.center
        view.addSubview(passView)
    }
    
    private func showFailedView() {
        let failedView = FailedView(frame: CGRect(x: 0, y: 0, width: 400, height: 200))
        failedView.center = view.center
        view.addSubview(failedView)
    }
    
    private func playHitAudio() {
        switch hitSoundType {
        case .puff:
            AudioServicesPlaySystemSound(audio1)
        case .bang:
            AudioServicesPlaySystemSound(audio2)
        }
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
        guard !isStop else { return }
        guard let recorder = audioRecorder?.recorder else { return }
        recorder.updateMeters()
        let normalizedValue = pow(10, recorder.averagePower(forChannel: 0) / 100)
        let level = CGFloat(normalizedValue)
        flexibleView.level = level
        
        var targetCount = 0
        view.subviews.forEach {
            if $0.isKind(of: TargetView.self) {
                guard let layer = $0.layer.presentation() else { return }
                let rect = CGRect(x: flexibleView.center.x - 30, y: flexibleView.y, width: 60, height: 60)
                if layer.frame.intersects(rect) {
                    playHitAudio()
                    $0.removeFromSuperview()
                } else {
                    targetCount += 1
                }
            }
        }
        if offsetIndex == targets.count && targetCount == 0 {
            stop()
            showPassView()
            audioRecorder?.stop({ (flah, url) in
                
            })
            UIView.animate(withDuration: 0.5, animations: {
                self.flexibleView.y = self.view.height - 110
            }) { (flag) in
                self.flexibleView.height = 110
            }
        }
    }
    
    //MARK: Getter
    
    lazy var flexibleView: FlexibleAttackView = {
        let view = FlexibleAttackView(frame: CGRect(x: 0, y: self.view.height - 110, width: 90, height: 110))
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
                    stop()
                    view.subviews.forEach {
                        if $0.isKind(of: TargetView.self) {
                            $0.removeFromSuperview()
                        }
                    }
                    showFailedView()
                }
            }
        }
    }
    
}
