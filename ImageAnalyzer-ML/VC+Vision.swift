//
//  VC+Vision.swift
//  ImageAnalyzer-ML
//
//  Created by Priya Talreja on 26/07/19.
//  Copyright © 2019 Priya Talreja. All rights reserved.
//

import UIKit
import Vision

enum DetectionTypes {
    case Rectangle
    case Face
    case Barcode
    case Text
}
extension ViewController
{
    func createVisionRequest(image: UIImage)
    {
        guard let cgImage = image.cgImage else {
            return
        }
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, orientation: image.cgImageOrientation, options: [:])
        //Request Array
        //From now I am just passing text detection request.. You can pass vnDetectionRequest,vnFaceDetectionRequest,vnBarCodeDetectionRequest
        let vnRequests = [vnRectangleDetectionRequest]
        DispatchQueue.global(qos: .background).async {
            do{
                try requestHandler.perform(vnRequests)
            }catch let error as NSError {
                print("Error in performing Image request: \(error)")
            }
        }

    }

    var vnDetectionRequest : VNDetectRectanglesRequest{
        let request = VNDetectRectanglesRequest { (request,error) in
            if let error = error as NSError? {
                print("Error in detecting - \(error)")
                return
            }
            else {
                guard let observations = request.results as? [VNDetectedObjectObservation]
                    else {
                        return
                }
                print("Observations are \(observations)")
                self.visualizeObservations(observations: observations,type: .Rectangle)
            }
        }
        request.maximumObservations = 0
        return request
    }

    var vnFaceDetectionRequest : VNDetectFaceRectanglesRequest{
        let request = VNDetectFaceRectanglesRequest { (request,error) in
            if let error = error as NSError? {
                print("Error in detecting - \(error)")
                return
            }
            else {
                guard let observations = request.results as? [VNDetectedObjectObservation]
                    else {
                        return
                }
                print("Observations are \(observations)")
                self.visualizeObservations(observations: observations,type: .Face)
            }
        }
        return request
    }

    var vnBarCodeDetectionRequest : VNDetectBarcodesRequest{
        let request = VNDetectBarcodesRequest { (request,error) in
            if let error = error as NSError? {
                print("Error in detecting - \(error)")
                return
            }
            else {
                guard let observations = request.results as? [VNDetectedObjectObservation]
                    else {
                        return
                }
                print("Observations are \(observations)")
                self.visualizeObservations(observations: observations,type: .Barcode)
            }
        }

        return request
    }

    var vnRectangleDetectionRequest : VNDetectRectanglesRequest{
        let request = VNDetectRectanglesRequest { (request,error) in
            if let error = error as NSError? {
                print("Error in detecting - \(error)")
                return
            }
            else {
                guard let observations = request.results as? [VNDetectedObjectObservation]
                    else {
                        return
                }
                print("R Observations are \(observations)")
                self.visualizeObservations(observations: observations,type: .Rectangle)
            }
        }
        request.quadratureTolerance = 45

        return request
    }

    func visualizeObservations(observations : [VNDetectedObjectObservation],type: DetectionTypes){
        print("VVV")
        DispatchQueue.main.async {
            guard let image = self.imageView.image
                else{
                    print("Failure in retriving image")
                    return
            }
            let imageSize = image.size
            var imageTransform = CGAffineTransform.identity.scaledBy(x: 1, y: -1).translatedBy(x: 0, y: -imageSize.height)
            imageTransform = imageTransform.scaledBy(x: imageSize.width, y: imageSize.height)
            UIGraphicsBeginImageContextWithOptions(imageSize, true, 0)
            let graphicsContext = UIGraphicsGetCurrentContext()
            image.draw(in: CGRect(origin: .zero, size: imageSize))

            graphicsContext?.saveGState()
            graphicsContext?.setLineJoin(.round)
            graphicsContext?.setLineWidth(0.0)

            switch type
            {
            case .Face:
                graphicsContext?.setFillColor(red: 1, green: 0, blue: 0, alpha: 0.3)
                graphicsContext?.setStrokeColor(UIColor.red.cgColor)
            case .Barcode,.Text:
                graphicsContext?.setFillColor(red: 0, green: 1, blue: 0, alpha: 0.3)
                graphicsContext?.setStrokeColor(UIColor.green.cgColor)
            case .Rectangle:
                graphicsContext?.setFillColor(red: 0, green: 0, blue: 1, alpha: 0.4)
                graphicsContext?.setStrokeColor(UIColor.blue.cgColor)

            }


            observations.forEach { (observation) in
                let observationBounds = observation.boundingBox.applying(imageTransform)
                let tt = observation.self
                print("Frame  ", tt)
                graphicsContext?.addRect(observationBounds)

                print("Observing Box  ", observationBounds)
                self.cropToBounds(image: image, width: Double(observationBounds.size.width), height: Double(observationBounds.size.height), x: observationBounds.origin.x, y: observationBounds.origin.y)
            }
            graphicsContext?.drawPath(using: CGPathDrawingMode.fillStroke)
            graphicsContext?.restoreGState()

            let drawnImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.imageView.image = drawnImage

        }
    }
}


extension ViewController{
    func cropToBounds(image: UIImage, width: Double, height: Double, x: CGFloat, y: CGFloat) -> UIImage {

        let cgimage = image.cgImage!
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        var cgwidth: CGFloat = CGFloat(width)
        var cgheight: CGFloat = CGFloat(height)
        let rect: CGRect = CGRect(x: x, y: y, width: cgwidth, height: cgheight)

        // Create bitmap image from context using the rect
        let imageRef: CGImage = cgimage.cropping(to: rect)!

        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        self.croppedImageView.image = image
        return image
    }

}



extension ViewController{
    func frameForRectangle(_ rectangle: VNRectangleObservation, withTransformProperties properties: (size: CGSize, xOffset: CGFloat, yOffset: CGFloat)) -> CGRect {
        // Use aspect fit to determine scaling and X & Y offsets
        let transform = CGAffineTransform.identity
            .translatedBy(x: properties.xOffset, y: properties.yOffset)
            .scaledBy(x: properties.size.width, y: properties.size.height)

        // Convert normalized coordinates to display coordinates
        let convertedTopLeft = rectangle.topLeft.applying(transform)
        let convertedTopRight = rectangle.topRight.applying(transform)
        let convertedBottomLeft = rectangle.bottomLeft.applying(transform)
        let convertedBottomRight = rectangle.bottomRight.applying(transform)

        // Calculate bounds of bounding box
        let minX = min(convertedTopLeft.x, convertedTopRight.x, convertedBottomLeft.x, convertedBottomRight.x)
        let maxX = max(convertedTopLeft.x, convertedTopRight.x, convertedBottomLeft.x, convertedBottomRight.x)
        let minY = min(convertedTopLeft.y, convertedTopRight.y, convertedBottomLeft.y, convertedBottomRight.y)
        let maxY = max(convertedTopLeft.y, convertedTopRight.y, convertedBottomLeft.y, convertedBottomRight.y)
        let frame = CGRect(x: minX , y: minY, width: maxX - minX, height: maxY - minY)
        return frame
    }
}

//Next task is here
extension ViewController{

    func performRectangleDetection(image: CIImage) -> CIImage? {
        var resultImage: CIImage?
        resultImage = image
        let detector = CIDetector(ofType: CIDetectorTypeRectangle, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh, CIDetectorAspectRatio: 1.6, CIDetectorMaxFeatureCount: 10] )!

        // Get the detections
        var halfPerimiterValue = 0.0 as Float;
        let features = detector.features(in: image)
        print("feature \(features.count)")
        for feature in features as! [CIRectangleFeature] {
            p1 = feature.topLeft
            p2 = feature.topRight
            let width = hypotf(Float(p1!.x - p2!.x), Float(p1!.y - p2!.y));
            p3 = feature.bottomLeft
            p4 = feature.bottomRight
            let height = hypotf(Float(p3!.x - p4!.x), Float(p3!.y - p4!.y));
            let currentHalfPerimiterValue = height+width;
            if (halfPerimiterValue < currentHalfPerimiterValue){
                halfPerimiterValue = currentHalfPerimiterValue
            }
        }
        resultImage = flattenImage(image: image, topLeft: p1!, topRight: p2!, bottomLeft: p3!, bottomRight: p4!)
        // print("perimmeter   \(halfPerimiterValue)")
        print("TopLeft  ",p1, "   : TopRight  ",p2)
        print("BottomLeft  ", p3,"  :  BottomRight   ", p4)

        return resultImage
    }
    
    func flattenImage(image: CIImage, topLeft: CGPoint, topRight: CGPoint,bottomLeft: CGPoint, bottomRight: CGPoint) -> CIImage {
        
        return image.applyingFilter("CIPerspectiveCorrection", parameters: [
            
            "inputTopLeft": CIVector(cgPoint: topLeft),
            "inputTopRight": CIVector(cgPoint: topRight),
            "inputBottomLeft": CIVector(cgPoint: bottomLeft),
            "inputBottomRight": CIVector(cgPoint: bottomRight)
            
            
        ])
    }
}


extension ViewController{
    func analyzeImage(image: UIImage) -> Quadrilateral
    {
        guard let ciImage = CIImage.init(image: image)
            else { return Quadrilateral(topLeft: CGPoint.zero, topRight: CGPoint.zero, bottomLeft: CGPoint.zero, bottomRight: CGPoint.zero) }
        let flip = true // set to false to prevent flipping the coordinates

        let context = CIContext(options: nil)

        let detector = CIDetector(ofType: CIDetectorTypeRectangle, context: context, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])

        let features = detector!.features(in: ciImage)

        UIGraphicsBeginImageContext(ciImage.extent.size)
        let currentContext = UIGraphicsGetCurrentContext()

        var frames: [Quadrilateral] = []
        for feature in features as! [CIRectangleFeature]
        {
            
            var topLeft = currentContext!.convertToUserSpace(feature.topLeft)
            var topRight = currentContext!.convertToUserSpace(feature.topRight)
            var bottomRight = currentContext!.convertToUserSpace(feature.bottomRight)
            var bottomLeft = currentContext!.convertToUserSpace(feature.bottomLeft)

            if flip {
                
                p1 = feature.topLeft
                p2 = feature.topRight
                p3 = feature.bottomLeft
                p4 = feature.bottomRight
                
                topLeft = CGPoint(x: topLeft.x, y: image.size.height - topLeft.y)
                topRight = CGPoint(x: topRight.x, y: image.size.height - topRight.y)
                bottomLeft = CGPoint(x: bottomLeft.x, y: image.size.height - bottomLeft.y)
                bottomRight = CGPoint(x: bottomRight.x, y: image.size.height - bottomRight.y)
            }

            let frame = Quadrilateral(topLeft: topLeft, topRight: topRight, bottomLeft: bottomLeft, bottomRight: bottomRight)

            frames.append(frame)
        }
        
        UIGraphicsEndImageContext()
        return frames[0]
    }
}
