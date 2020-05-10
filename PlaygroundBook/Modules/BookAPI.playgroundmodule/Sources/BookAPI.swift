//
//  See LICENSE folder for this template’s licensing information.
//
//  Abstract:
//  Contains classes/structs/enums/functions which are part of a module that is
//  automatically imported into user-editable code.
//

import BookCore
import UIKit
import PlaygroundSupport

// Implement any classes/structs/enums/functions in the BookAPI module which you
// want to be automatically imported and visible for users on playground pages
// and in user modules.
//
// This is controlled via the book-level `UserAutoImportedAuxiliaryModules`
// Manifest.plist key.

public enum WarplaneStyle: String {
    case science = "warplane_1"
    case modern = "warplane_2"
}

public enum MeteoroliteStyle: String {
    case yellow = "rock_1"
    case grey = "rock_2"
}

let vc = LiveViewController()

public class Game {
    
    public var setupMeteorolite: ((_ screenWidth: CGFloat, _ meteoroliteSize: CGFloat) -> CGFloat)? {
        willSet {
            vc.shootMeteoroliteClosure = newValue
        }
    }
    
    public var setupMeteoroliteStyle: ((_ index: Int) -> MeteoroliteStyle)? {
        willSet {
            guard let closure = newValue else { return }
            vc.appearMeteoroliteStyleClosure = { (index) in
                return closure(index).rawValue
            }
        }
    }
    
}

public let game = Game()

public enum GameLevel {
    case easy
    case normal
    case hard
}

public func playGame() {
    PlaygroundPage.current.liveView = vc
    vc.play()
}

public func setupAppearStoneInterval(_ interval: TimeInterval) {
    vc.shootMeteoroliteInterval = max(interval, 0)
}

public func setupShootGuidedMissileInterval(_ interval: TimeInterval) {
    vc.shootGuidedMissileInterval = max(interval, 0.1)
}

public func setupStoneCount(_ count: Int) {
    vc.meteoroliteCount = count
}

public func setupGameLevel(_ level: GameLevel) {
    switch level {
    case .easy:
        vc.meteoroliteCount = 100
        vc.flyingSpeed = .low
        vc.guidedMissileSpeed = .low
    case .normal:
        vc.meteoroliteCount = 300
        vc.flyingSpeed = .medium
        vc.guidedMissileSpeed = .medium
    case .hard:
        vc.meteoroliteCount = 500
        vc.flyingSpeed = .high
        vc.guidedMissileSpeed = .high
    }
}

public func setupWarplaneStyle(_ style: WarplaneStyle) {
    vc.warplaneStyle = style.rawValue
}

public func setupHealthValue(_ value: Int) {
    vc.healthValue = min(max(value, 1), 10)
}
