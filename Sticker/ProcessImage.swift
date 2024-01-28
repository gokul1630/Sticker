//
//  ProcessImage.swift
//  Sticker
//
//  Created by Gokulprasanth on 27/01/24.

import UIKit
import SDWebImage
import AVFoundation
import SDWebImageWebPCoder

func extractExtension(_ response: SDImageFormat) -> String {
    switch response.rawValue {
    case 1:
        return ".png"
    case 4:
        return ".webp"
    default:
        return ".jpeg"
    }

   }

func addOverlay(url: URL?, overlayColor: UIColor, size: CGFloat, type: SDImageFormat, completion: @escaping (Data?) -> Void)  {
    SDImageCodersManager.shared.addCoder(SDImageWebPCoder.shared)
    
    SDWebImageManager.shared.loadImage(with: url, options: [], progress: nil){(image, _, error, _, _, _) in
        guard let image = image else {
            if let error = error{
                debugPrint("error :", error)
            }
            return
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
        
        
        if let imageData = canvasImage.sd_imageData(as: type) {
            completion(imageData)
            return
            }
        completion(nil)
    }


}
