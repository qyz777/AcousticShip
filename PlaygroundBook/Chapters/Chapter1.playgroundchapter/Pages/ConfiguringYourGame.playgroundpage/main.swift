//#-hidden-code
//
//  See LICENSE folder for this template’s licensing information.
//
//  Abstract:
//  The Swift file containing the source code edited by the user of this playground book.
//
//#-end-hidden-code
/*:
 Goal: Modify game settings
 
 Now you can change the Settings to make the game more challenging!
 
 */

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

playGame()
