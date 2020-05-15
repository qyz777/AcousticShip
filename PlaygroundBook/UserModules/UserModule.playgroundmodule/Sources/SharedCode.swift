//
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//
//  Shared codes
//  The code written in this file is available on all pages of this Playground.
//

import UIKit

public func setupRandomMeteorolite(_ screenWidth: CGFloat, _ meteoroliteSize: CGFloat) -> CGFloat {
    //The inner margin of the meteorite as it appears on the screen
    let padding: CGFloat = 50
    //Calculate the number of tracks the meteorite appears in
    let totalMeteorolitePath = Int((screenWidth - padding * 2) / meteoroliteSize)
    //Calculate the relative coordinates of the track center x
    let pathPointX = (screenWidth - padding * 2) / CGFloat(totalMeteorolitePath) / 2
    //Randomly assign a value between 1 and the number of tracks
    let path = randomIntNumber(lower: 1, upper: totalMeteorolitePath + 1)
    //Returns the coordinates of the x center where the meteorite appeared
    return padding + pathPointX * 2 * CGFloat(path - 1) + pathPointX
}

public func randomIntNumber(lower: Int = 0, upper: Int = Int(UInt32.max)) -> Int {
    return lower + Int(arc4random_uniform(UInt32(upper - lower)))
}
