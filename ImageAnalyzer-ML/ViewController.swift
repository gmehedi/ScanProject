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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        let cropView = SECropView()
        self.imageView.image = uiImage
        //MARK: Document Scan By CIRectangleDetector
        let image = self.performRectangleDetection(image: CIImage.init(image: uiImage)!)
        self.croppedImageView.image = UIImage.init(ciImage: image!)
        
    
        let viewCordinatesSystem = analyzeImage(image: uiImage)
        //
        p1 = viewCordinatesSystem.topLeft
        p2 = viewCordinatesSystem.topRight
        p3 = viewCordinatesSystem.bottomLeft
        p4 = viewCordinatesSystem.bottomRight
       // print("F  ", frame)
        
        let point1 = CGPoint(x: p1!.x, y: p1!.y)
        let point2 = CGPoint(x: p2!.x, y: p2!.y)
        let point3 = CGPoint(x: p3!.x, y: p3!.y)
        let point4 = CGPoint(x: p4!.x, y: p4!.y)
        
        for sub in self.imageView.subviews{
            sub.removeFromSuperview()
        }

        cropView.configureWithCorners(corners: [point2, point1, point3, point4], on: self.imageView)
        
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


