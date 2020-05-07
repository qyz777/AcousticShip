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

let vc = LiveViewController()

public func playGame() {
    vc.play()
    PlaygroundPage.current.liveView = vc
}

public func setupTargets(_ targets: [String]) {
    
}

public func setupTargetTop(_ top: CGFloat) {
    
}

public func setupShootTimeInterval(_ time: TimeInterval) {
    vc.shootTimeInterval = time
}

public func setupHitSoundType(_ type: HitSoundType) {
    vc.hitSoundType = type
}
