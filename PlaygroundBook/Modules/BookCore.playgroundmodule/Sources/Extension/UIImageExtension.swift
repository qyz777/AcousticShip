//
//  UIImageExtension.swift
//  BookCore
//
//  Created by Q YiZhong on 2020/5/8.
//

import UIKit

extension UIImage {
    
    static func resizeImage(image: UIImage, newSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContext(newSize)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

}
