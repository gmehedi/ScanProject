//
//  Extensions.swift
//  ImageAnalyzer-ML
//
//  Created by Priya Talreja on 26/07/19.
//  Copyright © 2019 Priya Talreja. All rights reserved.
//

import UIKit

extension UIImage {
    var cgImageOrientation : CGImagePropertyOrientation
    {
        switch imageOrientation {
            case .up: return .up
            case .upMirrored: return .upMirrored
            case .down: return .down
            case .downMirrored: return .downMirrored
            case .leftMirrored: return .leftMirrored
            case .right: return .right
            case .rightMirrored: return .rightMirrored
            case .left: return .left
            default: return.up
            
        }
    }
}

struct Quadrilateral {
    var topLeft : CGPoint = CGPoint.zero
    var topRight : CGPoint = CGPoint.zero
    var bottomLeft : CGPoint = CGPoint.zero
    var bottomRight : CGPoint = CGPoint.zero

    var path : UIBezierPath {
        get {
            let tempPath = UIBezierPath()
            tempPath.move(to: topLeft)
            tempPath.addLine(to: topRight)
            tempPath.addLine(to: bottomRight)
            tempPath.addLine(to: bottomLeft)
            tempPath.addLine(to: topLeft)
            return tempPath
        }
    }

    init(topLeft topLeft_I: CGPoint, topRight topRight_I: CGPoint, bottomLeft bottomLeft_I: CGPoint, bottomRight bottomRight_I: CGPoint) {
        topLeft = topLeft_I
        topRight = topRight_I
        bottomLeft = bottomLeft_I
        bottomRight = bottomRight_I
    }

    var frame : CGRect {
        get {
            let highestPoint = max(topLeft.y, topRight.y, bottomLeft.y, bottomRight.y)
            let lowestPoint = min(topLeft.y, topRight.y, bottomLeft.y, bottomRight.y)
            let farthestPoint = max(topLeft.x, topRight.x, bottomLeft.x, bottomRight.x)
            let closestPoint = min(topLeft.x, topRight.x, bottomLeft.x, bottomRight.x)

            // you might want to set origin to (0,0)
            let origin = CGPoint(x: closestPoint, y: lowestPoint)
            let size = CGSize(width: farthestPoint, height: highestPoint)

            return CGRect(origin: origin, size: size)
        }
    }

    var size : CGSize {
        get {
            return frame.size
        }
    }

    var origin : CGPoint {
        get {
            return frame.origin
        }
    }
}
