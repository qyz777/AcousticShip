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

public enum WarplaneStyle: String {
    case science = "warplane_1"
    case modern = "warplane_2"
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
    public var stoneCount = 1
    
    public var shootTargetInterval: TimeInterval = 0.5
    
    public var shootGuidedMissileInterval: TimeInterval = 0.3
    
    /// 命名音效
    public var hitSoundType: HitSoundType = .puff
    
    /// target飞行速度
    public var flyingSpeed: TargetFlyingSpeed = .medium
    
    /// 飞机样式
    public var warplaneStyle: WarplaneStyle = .science
    
    /// 导弹速度
    public var guidedMissileSpeed: GuidedMissileSpeed = .medium
    
    /// 生命值
    public var healthValue = 5 {
        willSet {
            healthView.health = newValue
        }
    }
    
    /// 记录出现对手的个数
    private var offsetIndex = 0
    
    private var audio1: SystemSoundID = 0
    private var audio2: SystemSoundID = 0
    
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
        
        setupAudio()
        
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
        
        showStartView()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundView.frame = view.bounds
        waverView.x = view.width - 15 - waverView.width
        startView?.center = CGPoint(x: view.width / 2.0, y: view.height / 2.0)
        if !isPlay {
            warplaneView.center.x = view.width / 2
            warplaneView.center.y = view.height - WARPLANE_SIZE
        }
    }
    
    //MARK: Public
    
    public func play() {
        guard stoneCount > 0 else {
            return
        }
        audioRecorder?.record()
        displayLink?.isPaused = false
        shootTarget(at: Int.randomIntNumber(lower: 0, upper: self.totalTargetPath))
        timer = Timer(timeInterval: shootTargetInterval, repeats: true, block: { [unowned self] (t) in
            guard self.offsetIndex < self.stoneCount else {
                return
            }
            
            self.shootTarget(at: Int.randomIntNumber(lower: 1, upper: self.totalTargetPath + 1))
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
    
    private func setupAudio() {
        let path1 = Bundle.main.path(forResource: "audio1", ofType: "mp3")
        let url1 = NSURL(fileURLWithPath: path1 ?? "")
        AudioServicesCreateSystemSoundID(url1, &audio1)
        let path2 = Bundle.main.path(forResource: "audio2", ofType: "mp3")
        let url2 = NSURL(fileURLWithPath: path2 ?? "")
        AudioServicesCreateSystemSoundID(url2, &audio2)
    }
    
    private func shootTarget(at path: Int) {
        let targetView = TargetView(frame: CGRect(x: 0, y: -TARGET_SIZE, width: TARGET_SIZE, height: TARGET_SIZE))
        let v = Int.randomIntNumber(lower: 0, upper: 2)
        if v == 0 {
            targetView.imageView.image = UIImage(named: "rock_1")
        } else {
            targetView.imageView.image = UIImage(named: "rock_2")
        }
        targetView.center.x = X_PADDING + pathPointX * 2 * CGFloat(path - 1) + pathPointX
        view.addSubview(targetView)
        addTargetAnimation(targetView)
        offsetIndex += 1
        targetSet.insert(targetView)
    }
    
    private func shootGuidedMissile() {
        let guidedMissileView = GuidedMissileView(frame: CGRect(x: 0, y: 0, width: GUIDED_MISSILE_WIDTH, height: GUIDED_MISSILE_HEIGHT))
        guidedMissileView.center = CGPoint(x: warplaneView.center.x, y: warplaneView.y - GUIDED_MISSILE_HEIGHT / 2 - 5)
        view.addSubview(guidedMissileView)
        addGuidedMissileAnimation(guidedMissileView)
        guidedMissileSet.insert(guidedMissileView)
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
    
    private func addGuidedMissileAnimation(_ view: UIView) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.fromValue = NSValue(cgPoint: view.layer.position)
        animation.toValue = NSValue(cgPoint: CGPoint(x: view.layer.position.x, y: -GUIDED_MISSILE_HEIGHT / 2))
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
    
    private func shootGuidedMissileIfNeed() {
        guard let recorder = audioRecorder?.recorder else { return }
        callTime += displayLink?.duration ?? 0
        recorder.updateMeters()
        let normalizedValue = pow(10, recorder.averagePower(forChannel: 0) / 100)
        if normalizedValue >= 0.6 && callTime >= shootGuidedMissileInterval {
            callTime = 0
            shootGuidedMissile()
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
        if offsetIndex >= stoneCount && !hasTargetView {
            stop()
            showPassView()
        } else if healthValue <= 0 {
            stop()
            showFailedView()
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
    
    private lazy var warplaneView: UIImageView = {
        let view = UIImageView(image: UIImage(named: WarplaneStyle.science.rawValue))
        view.frame = CGRect(x: 0, y: 0, width: WARPLANE_SIZE, height: WARPLANE_SIZE)
        view.isUserInteractionEnabled = true
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
