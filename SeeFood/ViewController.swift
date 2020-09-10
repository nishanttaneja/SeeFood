//
//  ViewController.swift
//  SeeFood
//
//  Created by Nishant Taneja on 11/09/20.
//  Copyright © 2020 Nishant Taneja. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController {
    // Constant
    let imagePicker = UIImagePickerController()
    
    // Override ViewLifecycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
    }
    
    //MARK:- IBOutlet|IBAction
    @IBOutlet weak var imageView: UIImageView!
    @IBAction func cameraButtonPressed(_ sender: UIBarButtonItem) {
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    //MARK:- CoreML|Vision
    func detect(_ image: CIImage) {
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {fatalError("error loading MLModel")}
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation], let topResult = results.first else {fatalError("unexpected result type from VNCoreMLRequest")}
            if topResult.identifier.contains("hotdog") {
                DispatchQueue.main.async {
                    self.navigationItem.title = "Hotdog!"
                    self.navigationController?.navigationBar.barTintColor = .green
                }
            } else {
                DispatchQueue.main.async {
                    self.navigationItem.title = "Not Hotdog!"
                    self.navigationController?.navigationBar.barTintColor = .red
                }
            }
        }
        let handler = VNImageRequestHandler(ciImage: image)
        do {try handler.perform([request])}
        catch {print(error)}
    }
}

//MARK:- UIImagePickerController|UINavigationController Delegate
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            imageView.image = selectedImage
            imagePicker.dismiss(animated: true, completion: nil)
            guard let image = CIImage(image: selectedImage) else {fatalError("error converting UIImage to CIImage")}
            detect(image)
        }
    }
}
