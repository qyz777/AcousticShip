//
//  See LICENSE folder for this template’s licensing information.
//
//  Abstract:
//  A source file which is part of the auxiliary module named "BookCore".
//  Provides the implementation of the "always-on" live view.
//

import UIKit
import PlaygroundSupport

public enum TargetFlyingSpeed: Double {
    case low = 8
    case medium = 5
    case high = 3
}

public enum GuidedMissileSpeed: Double {
    case low = 1.5
    case medium = 1
    case high = 0.5
}

let X_PADDING: CGFloat = 50
let Y_PADDING: CGFloat = 150
let WARPLANE_SIZE: CGFloat = 90

@objc(BookCore_LiveViewController)
public class LiveViewController: UIViewController, PlaygroundLiveViewMessageHandler, PlaygroundLiveViewSafeAreaContainer {
    
    private var audioRecorder: AudioRecorder?
    private var displayLink: CADisplayLink?
    private var lastCenter: CGPoint = .zero
    private var timer: Timer?
    
    /// 陨石数量
    public var meteoroliteCount = 100
    
    public var shootMeteoroliteInterval: TimeInterval = 0.5
    
    public var shootGuidedMissileInterval: TimeInterval = 0.5
    
    /// target飞行速度
    public var flyingSpeed: TargetFlyingSpeed = .medium
    
    /// 飞机样式
    public var warplaneStyle: String = "warplane_1" {
        willSet {
            warplaneView.warplaneStyle = newValue
        }
    }
    
    public var meteoroliteStyle: String = "rock_1"
    
    /// 导弹速度
    public var guidedMissileSpeed: GuidedMissileSpeed = .medium
    
    /// 生命值
    public var healthValue = 5 {
        willSet {
            healthView.health = newValue
        }
    }
    
    public var shootMeteoroliteClosure: ((_ screenWidth: CGFloat, _ meteoroliteSize: CGFloat) -> CGFloat)?
    
    public var appearMeteoroliteStyleClosure: ((_ index: Int) -> String)?
    
    /// 记录出现对手的个数
    private var offsetIndex = 0
    
    private var isPlay = false
    
    private var targetSet: Set<TargetView> = []
    private var guidedMissileSet: Set<GuidedMissileView> = []
    
    private var callTime: TimeInterval = 0
    
    private var startView: StartView?
    
    public override func viewDidLoad() {
        view.backgroundColor = .black
        view.addSubview(backgroundView)
        backgroundView.addSubview(healthView)
        backgroundView.addSubview(waverView)
        backgroundView.addSubview(warplaneView)
        
        healthView.health = healthValue
        
        do {
            try audioRecorder = AudioRecorder()
            waverView.recorder = audioRecorder?.recorder
        } catch {
            print(error)
        }
        
        displayLink?.invalidate()
        displayLink = CADisplayLink(target: self, selector: #selector(handleTimerCall))
        displayLink?.isPaused = true
        displayLink?.add(to: RunLoop.current, forMode: .common)
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundView.frame = view.bounds
        waverView.x = view.width - 15 - waverView.width
        startView?.center = CGPoint(x: view.width / 2.0, y: view.height / 2.0)
        healthView.width = view.width - waverView.width - 50
        if !isPlay {
            warplaneView.center.x = view.width / 2
            warplaneView.center.y = view.height - WARPLANE_SIZE
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        stop()
        showStartView()
    }
    
    //MARK: Public
    
    public func play() {
        guard meteoroliteCount > 0 else {
            return
        }
        audioRecorder?.record()
        displayLink?.isPaused = false
        shootMeteorolite(at: shootMeteoroliteCenterX())
        timer = Timer(timeInterval: shootMeteoroliteInterval, repeats: true, block: { [unowned self] (t) in
            guard self.offsetIndex < self.meteoroliteCount else {
                return
            }
            
            self.shootMeteorolite(at: self.shootMeteoroliteCenterX())
        })
        RunLoop.current.add(timer!, forMode: .common)
        isPlay = true
    }
    
    //MARK: Private
    
    private func stop() {
        offsetIndex = 0
        timer?.invalidate()
        displayLink?.isPaused = true
        audioRecorder?.stop({ (flah, url) in
            
        })
        isPlay = false
    }
    
    private func shootMeteorolite(at centerX: CGFloat) {
        let targetView = TargetView(frame: CGRect(x: 0, y: -TARGET_SIZE, width: TARGET_SIZE, height: TARGET_SIZE))
        if appearMeteoroliteStyleClosure != nil {
            targetView.imageView.image = UIImage(named: appearMeteoroliteStyleClosure!(offsetIndex))
        } else {
            targetView.imageView.image = UIImage(named: meteoroliteStyle)
        }
        targetView.center.x = centerX
        view.addSubview(targetView)
        addTargetAnimation(targetView)
        offsetIndex += 1
        targetSet.insert(targetView)
    }
    
    private func shootGuidedMissile() {
        let guidedMissileView = GuidedMissileView(frame: CGRect(x: 0, y: 0, width: GUIDED_MISSILE_WIDTH, height: GUIDED_MISSILE_HEIGHT))
        guidedMissileView.center = CGPoint(x: warplaneView.center.x, y: warplaneView.y - GUIDED_MISSILE_HEIGHT / 2 - 5)
        view.addSubview(guidedMissileView)
        let point = CGPoint(x: warplaneView.center.x, y: -GUIDED_MISSILE_HEIGHT / 2)
        addGuidedMissileAnimation(guidedMissileView, to: point)
        guidedMissileSet.insert(guidedMissileView)
    }
    
    private func shootMultipleGuidedMissile() {
        let offset = CGFloat.pi / 6
        let start = -CGFloat.pi / 6
        for i in 0..<3 {
            let guidedMissileView = GuidedMissileView(frame: CGRect(x: 0, y: 0, width: GUIDED_MISSILE_WIDTH, height: GUIDED_MISSILE_HEIGHT))
            guidedMissileView.center = CGPoint(x: warplaneView.center.x, y: warplaneView.y - GUIDED_MISSILE_HEIGHT / 2 - 5)
            view.addSubview(guidedMissileView)
            let angle = start + offset * CGFloat(i)
            guidedMissileView.transform = .init(rotationAngle: angle)
            let width = CGFloat(tanf(Float(angle))) * (warplaneView.y - 5)
            let point = CGPoint(x: guidedMissileView.center.x + width, y: -GUIDED_MISSILE_HEIGHT / 2)
            addGuidedMissileAnimation(guidedMissileView, to: point)
            guidedMissileSet.insert(guidedMissileView)
        }
    }
    
    private func addTargetAnimation(_ view: UIView) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.fromValue = NSValue(cgPoint: view.layer.position)
        animation.toValue = NSValue(cgPoint: CGPoint(x: view.layer.position.x, y: self.view.height + view.height / 2))
        animation.duration = flyingSpeed.rawValue
        animation.autoreverses = false
        animation.beginTime = CACurrentMediaTime()
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        animation.delegate = self
        animation.setValue(view, forKey: "view")
        view.layer.add(animation, forKey: "target_animation")
    }
    
    private func addGuidedMissileAnimation(_ view: UIView, to point: CGPoint) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.fromValue = NSValue(cgPoint: view.layer.position)
        animation.toValue = NSValue(cgPoint: point)
        animation.duration = guidedMissileSpeed.rawValue
        animation.autoreverses = false
        animation.beginTime = CACurrentMediaTime()
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        animation.delegate = self
        animation.setValue(view, forKey: "view")
        view.layer.add(animation, forKey: "guided_missile_animation")
    }
    
    private func showStartView() {
        startView = StartView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        startView!.completeClosure = { [unowned self] in
            self.play()
        }
        startView!.center = view.center
        view.addSubview(startView!)
    }
    
    private func showPassView() {
        let passView = PassView(frame: CGRect(x: 0, y: 0, width: 400, height: 200))
        passView.center = view.center
        view.addSubview(passView)
    }
    
    private func showFailedView() {
        let failedView = FailedView(frame: CGRect(x: 0, y: 0, width: view.width, height: 200))
        failedView.center = view.center
        view.addSubview(failedView)
        removeAllMeteorolite()
    }
    
    private func shootGuidedMissileIfNeed() {
        guard let recorder = audioRecorder?.recorder else { return }
        callTime += displayLink?.duration ?? 0
        recorder.updateMeters()
        let normalizedValue = pow(10, recorder.averagePower(forChannel: 0) / 100)
        if callTime >= shootGuidedMissileInterval {
            if normalizedValue >= 0.8 {
                shootMultipleGuidedMissile()
                callTime = 0
            } else if normalizedValue >= 0.5 {
                shootGuidedMissile()
                callTime = 0
            }
        }
    }
    
    private func checkCollide() {
        var removeTarget: TargetView?
        var removeGuidedMissileArray: [GuidedMissileView] = []
        var removeTargetArray: [TargetView] = []
        //检测飞机是否碰撞靶子
        for target in targetSet {
            guard let layer = target.layer.presentation() else { continue }
            if layer.frame.intersects(warplaneView.frame) {
                healthValue -= 1
                removeTarget = target
                break
            }
        }
        if removeTarget != nil {
            targetSet.remove(removeTarget!)
            removeTarget?.removeFromSuperview()
            removeTarget?.layer.removeAllAnimations()
        }
        //检测靶子是否碰撞导弹
        guidedMissileSet.forEach {
            guard let gmLayer = $0.layer.presentation() else { return }
            let gm = $0
            targetSet.forEach {
                guard let targetLayer = $0.layer.presentation() else { return }
                if gmLayer.frame.intersects(targetLayer.frame) {
                    removeTargetArray.append($0)
                    removeGuidedMissileArray.append(gm)
                }
            }
        }
        removeTargetArray.forEach {
            targetSet.remove($0)
            $0.removeFromSuperview()
            $0.layer.removeAllAnimations()
            
            guard let layer = $0.layer.presentation() else { return }
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 100)
            label.text = "💥"
            label.sizeToFit()
            label.center = layer.position
            label.transform = .init(scaleX: 0.1, y: 0.1)
            backgroundView.addSubview(label)
            UIView.animate(withDuration: 0.25, animations: {
                label.transform = .identity
            }) { (_) in
                label.removeFromSuperview()
            }
        }
        removeGuidedMissileArray.forEach {
            guidedMissileSet.remove($0)
            $0.removeFromSuperview()
            $0.layer.removeAllAnimations()
        }
    }
    
    private func checkGame() {
        var hasTargetView = false
        for view in view.subviews {
            if view.isKind(of: TargetView.self) {
                hasTargetView = true
                break
            }
        }
        if offsetIndex >= meteoroliteCount && !hasTargetView {
            stop()
            showPassView()
        } else if healthValue <= 0 {
            stop()
            showFailedView()
        }
    }
    
    private func shootMeteoroliteCenterX() -> CGFloat {
        if shootMeteoroliteClosure != nil {
            return shootMeteoroliteClosure!(view.width, TARGET_SIZE)
        }
        let path = Int.randomIntNumber(lower: 1, upper: self.totalTargetPath + 1)
        return X_PADDING + pathPointX * 2 * CGFloat(path - 1) + pathPointX
    }
    
    private func removeAllMeteorolite() {
        view.subviews.forEach {
            if $0.isKind(of: TargetView.self) {
                $0.removeFromSuperview()
            }
        }
    }
    
    //MARK: Action
    
    @objc
    private func pan(_ pan: UIPanGestureRecognizer) {
        guard isPlay else {
            return
        }
        switch pan.state {
        case .began:
            lastCenter = warplaneView.center
            break
        case .changed:
            let offset = pan.translation(in: view)
            let movedX = lastCenter.x + offset.x
            var movedY = lastCenter.y + offset.y
            if movedY <= Y_PADDING {
                movedY = Y_PADDING
            }
            warplaneView.center = CGPoint(x: movedX, y: movedY)
            break
        default:
            break
        }
    }
    
    @objc
    private func handleTimerCall() {
        //1.检查是否有碰撞
        checkCollide()
        //2.检查是否可以发射导弹
        shootGuidedMissileIfNeed()
        //3.检查是否游戏结束
        checkGame()
    }
    
    //MARK: Getter
    
    private lazy var warplaneView: WarplaneView = {
        let view = WarplaneView()
        view.frame = CGRect(x: 0, y: 0, width: WARPLANE_SIZE, height: WARPLANE_SIZE)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
        view.addGestureRecognizer(pan)
        return view
    }()
    
    private lazy var backgroundView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "background"))
        view.contentMode = .scaleAspectFill
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private lazy var healthView: HealthValueView = {
        let view = HealthValueView(frame: CGRect(x: 15, y: 20, width: 300, height:40))
        return view
    }()
    
    private lazy var waverView: AudioWaverView = {
        let view = AudioWaverView(frame: CGRect(x: 0, y: 20, width: 200, height: 40))
        view.waveColor = UIColor.hex(0xFA3E54)
        view.numberOfWaves = 5
        return view
    }()
    
    private lazy var totalTargetPath: Int = {
        return Int((view.width - X_PADDING * 2) / TARGET_SIZE)
    }()
    
    private lazy var pathPointX: CGFloat = {
        return (view.width - X_PADDING * 2) / CGFloat(totalTargetPath) / 2
    }()
    
}

//MARK: CAAnimationDelegate
extension LiveViewController: CAAnimationDelegate {
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        let view = anim.value(forKey: "view")
        if let view = view as? TargetView {
            view.layer.removeAllAnimations()
            view.removeFromSuperview()
            targetSet.remove(view)
        } else if let view = view as? GuidedMissileView {
            view.layer.removeAllAnimations()
            view.removeFromSuperview()
            guidedMissileSet.remove(view)
        }
    }
    
}
