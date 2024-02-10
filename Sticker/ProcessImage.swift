//
//  ProcessImage.swift
//  Sticker
//
//  Created by Gokulprasanth on 27/01/24.

import UIKit
import SDWebImage
import AVFoundation
import SDWebImageWebPCoder

class ProcessImage {
    init(){
        SDImageCodersManager.shared.addCoder(SDImageWebPCoder.shared)
    }
    
    func addOverlay(url: URL?, overlayColor: UIColor, size: CGFloat, type: SDImageFormat, completion: @escaping (Data?) -> Void)  {
        
        SDWebImageManager.shared.loadImage(with: url, options: [], progress: nil){(image, _, error, _, _, _) in
            guard let image = image else {
                debugPrint("Something went wrong on image")
                return
            }
            
            if let error = error{
                debugPrint("error :", error)
            }
            let canvasSize = CGSize(width: size, height: size)
            
            let context = UIGraphicsImageRenderer(size: canvasSize)
            
            let canvasImage = context.image { context in
                
                UIColor.clear.setFill()
                context.fill(CGRect(origin: .zero, size: canvasSize))
                
                
                let squareRect = CGRect(origin: .zero, size: canvasSize)
                
                let aspect = AVMakeRect(aspectRatio: image.size, insideRect: squareRect)
                
                image.draw(in: aspect)
            }
            
            if let imageData = image.sd_imageData(as: type) {
                completion(imageData)
                return
            }
            completion(nil)
        }
    }
}

