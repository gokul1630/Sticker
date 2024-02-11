//
//  ProcessImage.swift
//  Sticker
//
//  Created by Gokulprasanth on 27/01/24.

import UIKit
import AVFoundation
import SwiftWebP

enum ImageFormat {
    case webp, png
}

class ProcessImage {
    private var downloadManager: DownloadManager
    
    init(){
        downloadManager = DownloadManager()
    }
    
    func addOverlay(url: String, size: CGFloat, type:ImageFormat, completion: @escaping (Data?) -> Void)  {
        downloadManager.download(url: url) { data, error in
            if let error = error {
                debugPrint("error :", error)
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }
            
            if let webPImage = UIImage(data: data) {
                
                
                let canvasSize = CGSize(width: size, height: size)
                
                let context = UIGraphicsImageRenderer(size: canvasSize)
                
                let canvasImage = context.image { context in
                    
                    UIColor.clear.setFill()
                    context.fill(CGRect(origin: .zero, size: canvasSize))
                    
                    
                    let squareRect = CGRect(origin: .zero, size: canvasSize)
                    
                    let aspect = AVMakeRect(aspectRatio: webPImage.size, insideRect: squareRect)
                    
                    webPImage.draw(in: aspect)
                }
                
                
                if type == .png {
                    if let imageData = canvasImage.pngData() {
                        completion(imageData)
                    }
                    return
                }
                
                if let webPData = WebPEncoder().encode(image: canvasImage) {
                    completion(webPData)
                    return
                }
                completion(nil)
            }
        }
    }
}

