//#-hidden-code
//
//  See LICENSE folder for this template’s licensing information.
//
//  Abstract:
//  The Swift file containing the source code edited by the user of this playground book.
//
//#-end-hidden-code
/*:
 Goal: Set meteorites
 
 Your task is to set the location of the meteorite entering from the outside of the screen and its style.
 
 The `setupMeteorolite` function returns the central x coordinate of the meteorite's appearance by passing in the screen width and the meteorite's size.
 
 The `setupMeteoroliteStyle` function returns the style of the meteorite by passing in the index of the meteorite to appear.
 
 Please try to design it so that different meteorites appear in different places!
 
 */

import UIKit

func setupMeteorolite(_ screenWidth: CGFloat, _ meteoroliteSize: CGFloat) -> CGFloat {
    //Try to return a different x-coordinate
    return screenWidth / 2.0
}

func setupMeteoroliteStyle(at index: Int) -> MeteoroliteStyle {
    //Try changing the return styles to see how they differ
    let value = randomIntNumber(lower: 0, upper: 2)
    if value == 0 {
        return .yellow
    } else {
        return .grey
    }
}

game.setupMeteorolite = setupMeteorolite
game.setupMeteoroliteStyle = setupMeteoroliteStyle

playGame()
