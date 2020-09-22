//
//  ViewController.swift
//  ImageAnalyzer-ML
//
//  Created by Priya Talreja on 26/07/19.
//  Copyright © 2019 Priya Talreja. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var croppedImageView: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    
    var p1: CGPoint?
    var p2: CGPoint?
    var p3: CGPoint?
    var p4: CGPoint?
    
    var qP1: CGPoint?
    var qP2: CGPoint?
    var qP3: CGPoint?
    var qP4: CGPoint?
    var resultImage: CIImage!
    var ciImage: CIImage!
    let cropView = SECropView()
    var frame = [Quadrilateral]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func tappedOnCroppedButton(_ sender: UIButton) {
        for (bNum, bPos) in cropView.bLDict {
            print("B  ", bNum,"   ", bPos)
            self.updateButtonPosition(buttonNumber: bNum, position: bPos)
        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
//            self.resultImage = self.flattenImage(image: self.ciImage!, topLeft: self.p1!, topRight: self.p2!,bottomLeft: self.p3!, bottomRight: self.p4!)
//            self.croppedImageView.image = UIImage.init(ciImage: self.resultImage)
//        })
        self.cropImage()
    }
    
    @IBAction func photoButtonClicked(_ sender: UIButton) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            presentPhotoPicker(sourceType: .photoLibrary)
            return
        }
        let photoSourcePicker = UIAlertController()
        let takePhoto = UIAlertAction(title: "Take Photo", style: .default) { [unowned self] _ in
            self.presentPhotoPicker(sourceType: .camera)
        }
        let choosePhoto = UIAlertAction(title: "Choose Photo", style: .default) { [unowned self] _ in
            self.presentPhotoPicker(sourceType: .photoLibrary)
        }
        photoSourcePicker.addAction(takePhoto)
        photoSourcePicker.addAction(choosePhoto)
        photoSourcePicker.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(photoSourcePicker, animated: true)
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)

        guard let uiImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            fatalError("Error!")
        }
        
        self.imageView.image = uiImage
        let viewCordinatesSystem = analyzeImage(image: uiImage)
        //
        p1 = viewCordinatesSystem.topLeft
        p2 = viewCordinatesSystem.topRight
        print("Top POint    :    ", p1!,"    ", p2!)
        print("POint Bottom    :    ", p3!,"    ", p4!)
        p4 = viewCordinatesSystem.bottomLeft
        p3 = viewCordinatesSystem.bottomRight
        
        for sub in self.imageView.subviews{
            sub.removeFromSuperview()
        }
        ciImage = CIImage.init(image: uiImage)
        
     //   let frame = analyzeImage(image: uiImage)
        cropView.configureWithCorners(corners: [viewCordinatesSystem.topRight, viewCordinatesSystem.topLeft, viewCordinatesSystem.bottomLeft, viewCordinatesSystem.bottomRight], on: self.imageView)
        
        
        //print("Pos  ", p1, "  ", p2, "   ", p3, "  ", p4)
        //MARK: Add Cropper
        //self.addCropper()
        //MARK: Detect Rectangle By Vision
        //createVisionRequest(image: uiImage)
    }
    
    private func presentPhotoPicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        present(picker, animated: true)
    }
}
//MARK: CropperView Delegate
extension ViewController{
    func updateButtonPosition(buttonNumber:  Int, position: CGPoint){
        //print("What  ", buttonNumber,"     ", position)
        switch buttonNumber {
        case 1:
            p1 = position // okk
        case 2:
            p2 = position
        case 3:
            p3 = position // ok
        default:
            p4 = position
        }
    }
}

extension ViewController{
    func cropImage(){
        let uiImage = UIImage.init(ciImage: ciImage)
        let testPath = UIBezierPath()
        testPath.move(to: CGPoint(x: p1!.x, y: p1!.y)) // 3
        testPath.addLine(to: CGPoint(x: p2!.x, y: p2!.y)) // 1
        testPath.addLine(to: CGPoint(x: p3!.x, y: p3!.y)) // 2
        testPath.addLine(to: CGPoint(x: p4!.x, y: p4!.y)) // 4
        testPath.close()
       

        self.croppedImageView.image = uiImage.imageByApplyingMaskingBezierPath(testPath, self.imageView.frame)
    }
    
}
