//
//  ProcessImage.swift
//  Sticker
//
//  Created by Gokulprasanth on 27/01/24.

import UIKit
import SDWebImage
import SDWebImageWebPCoder

func addOverlayToWebPAndSave(url: URL?, overlayColor: UIColor, size: Int, completion: @escaping (URL) -> Void)  {
    SDImageCodersManager.shared.addCoder(SDImageWebPCoder.shared)
    
    SDWebImageManager.shared.loadImage(with: url, options: [], progress: nil){(image, _, error, _, _, _) in
        guard let image = image else {
            if let error = error{
                debugPrint("error :", error)
            }
            return
        }
       
        debugPrint(image.size.width, image.size.height)
        
            guard let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
                return
            }
        
            
            let uniqueFileName = ProcessInfo.processInfo.globallyUniqueString
            let resultImageURL = cacheDirectory.appendingPathComponent("\(uniqueFileName).png")
        
           
        if let imageData = image.pngData() {
                do {
                    try imageData.write(to: resultImageURL)
                    completion(resultImageURL)
                } catch {
                    print("Error saving image data: \(error)")
                    return
                }
            } else {
                return
            }
    }


}
