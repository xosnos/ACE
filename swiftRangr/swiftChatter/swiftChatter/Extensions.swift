//
//  Extensions.swift
//  swiftChatter
//
//  Created by Ben Wozniak on 2/1/22.
//

import UIKit

extension UIImage {
    func resizeImage(targetSize: CGSize) -> UIImage? {
        // Figure out orientation, and use it to form the rectangle
        let ratio = (targetSize.width > targetSize.height) ?
            targetSize.height / size.height :
            targetSize.width / size.width
        
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the calculated rectangle
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
