//
//  AnimalDetector.swift
//  CatDogClassifier
//
//  Created by Muis on 01/07/20.
//  Copyright © 2020 Muis. All rights reserved.
//

import UIKit
import Vision

final class AnimalDetector {
    private init() {}
    
    static func startAnimalDetection(image: UIImage, completion: @escaping (_ classification: Result<[String], Error>) -> Void) {
        let imageOrientation: CGImagePropertyOrientation = {
            switch image.imageOrientation {
            case .up:
                return .up
            case .down:
                return .down
            case .left:
                return .left
            case .right:
                return .right
            case .upMirrored:
                return .upMirrored
            case .downMirrored:
                return .downMirrored
            case .leftMirrored:
                return .leftMirrored
            case .rightMirrored:
                return .rightMirrored
            @unknown default:
                fatalError()
            }
        }()
        
        let animalDetectionReqHandler = VNImageRequestHandler(
            cgImage: image.cgImage!,
            orientation: imageOrientation,
            options: [:]
        )
        
        do {
            let model = try VNCoreMLModel(for: CatDogClassifier().model)
            
            let request = VNCoreMLRequest(model: model) { (req, err) in
                if let error = err {
                    completion(Result.failure(error))
                    return
                }
                if let req = req.results {
                    let classifications = req.compactMap({ $0 as? VNClassificationObservation })
                        .filter({ $0.confidence > 0.9 })
                        .map({ $0.identifier })
                    
                    if !classifications.isEmpty {
                        completion(Result.success(classifications))
                    } else {
                        completion(Result.failure(ADError.msg("no classification")))
                    }
                    return
                }
            }
            
            try animalDetectionReqHandler.perform([request])
        } catch {
            completion(Result.failure(error))
        }
    }
    
    enum ADError: LocalizedError {
        case msg(String)
        var errorDescription: String? {
            switch self {
            case .msg(let msg):
                return msg
            }
        }
    }
}
