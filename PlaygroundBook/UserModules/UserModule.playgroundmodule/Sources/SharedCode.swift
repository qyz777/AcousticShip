//
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//
//  Shared codes
//  The code written in this file is available on all pages of this Playground.
//

import BookAPI

public func configureGame() {
    //Set the time interval for each meteorolite
    setupAppearStoneInterval(0.5)
    //Set the time interval for each missile launch
    setupShootGuidedMissileInterval(0.3)
    //Set the appearance of the warplane, science or modern
    setupWarplaneStyle(WarplaneStyle.science)
    //Set warplane health, it has to be greater than 0 and less than 10
    setupHealthValue(5)
    //Set the difficulty of the game
    setupGameLevel(GameLevel.normal)
    //Set the number of meteorites in the game. Changing the difficulty of the game will also change the number of meteorites
    //setupStoneCount(100)
}
