//
//  DownloadManager.swift
//  Sticker
//
//  Created by Gokulprasanth on 26/01/24.
//
import Foundation

class DownloadManager{
    
    static func extractExtension(response: URLResponse?) -> String {
        guard let response = response else {
            return ""
        }
           if (response.mimeType == "image/png") {
               return "png"
           }
           if (response.mimeType == "image/jpeg") {
               return "jpeg"
           }
           if (response.mimeType == "image/webp") {
               return "webp"
           }
           return "webp"
       }

    static func downloadFile(fileUrl url: String, completion: @escaping (URL?) -> Void) {
       let fileUrl = URL(string: url)!
       var destinationURL: URL? = nil
       
       let task = URLSession.shared.downloadTask(with: fileUrl) { (location, response, error) in
           guard error == nil else {
               debugPrint(error!)
               completion(nil)
               return
           }
           
           guard let location = location else {
              debugPrint(error!)
               completion(nil)
               return
           }
           
           do {
               let randomFileName = UUID().uuidString
               let tempDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
               
               guard let response = response else {
                   debugPrint(error!)
                   completion(nil)
                   return
               }
               
               destinationURL = tempDirectory.appendingPathExtension("\(randomFileName).\(DownloadManager.extractExtension(response: response))")
               
               
               try FileManager.default.moveItem(at: location, to: destinationURL!)
               completion(destinationURL)

           } catch {
               debugPrint(error)
               completion(nil)
           }
       }
       task.resume()
   }
}
