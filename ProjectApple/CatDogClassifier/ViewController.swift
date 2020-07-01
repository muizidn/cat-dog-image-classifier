//
//  ViewController.swift
//  CatDogClassifier
//
//  Created by Muis on 01/07/20.
//  Copyright © 2020 Muis. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var takePicture: UIButton! {
        didSet {
            takePicture.addTarget(self,
                                  action: #selector(btnTakePicture(_:)),
                                  for: .touchUpInside)
        }
    }
    @IBOutlet weak var performDetection: UIButton! {
        didSet {
            performDetection.addTarget(self,
                                       action: #selector(performDetection(_:)),
                                       for: .touchUpInside)
        }
    }
    @IBOutlet weak var infoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @objc private func performDetection(_ sender: UIButton) {
        if let image = imageView.image {
            AnimalDetector
                .startAnimalDetection(image: image) { [weak self](result) in
                    self?.infoLabel.text = "Analysing.."
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let classifications):
                            self?.infoLabel.text = classifications.first
                        case .failure(let error):
                            self?.infoLabel.text = error.localizedDescription
                        }
                    }
            }
        } else {
            infoLabel.text = "No image provided"
        }
    }
    
    @objc private func btnTakePicture(_ sender: UIButton) {
        let vc = UIImagePickerController()
        vc.delegate = self
        
        let alert = UIAlertController(title: "Select Source", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [unowned self] (_) in
            vc.sourceType = .camera
            self.present(vc, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { [unowned self] (_) in
            vc.sourceType = .photoLibrary
            self.present(vc, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Saved Photos Album", style: .default, handler: { [unowned self] (_) in
            vc.sourceType = .savedPhotosAlbum
            self.present(vc, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        switch picker.sourceType {
        case .photoLibrary:
            imageView.image = (info[.imageURL] as? URL)
                .flatMap({ UIImage(contentsOfFile: $0.path) })
        case .camera:
            imageView.image = info[.originalImage] as? UIImage
        case .savedPhotosAlbum:
            imageView.image = (info[.imageURL] as? URL)
                .flatMap({ UIImage(contentsOfFile: $0.path) })
        @unknown default:
            imageView.image = nil
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

