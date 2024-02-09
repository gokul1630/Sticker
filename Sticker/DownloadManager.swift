//
//  DownloadManager.swift
//  Sticker
//
//  Created by Gokulprasanth on 26/01/24.
//
import Foundation

class DownloadManager {
    
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

  static func download<T: Codable>(_ model: T.Type, url: String, completion: @escaping (T?, _ error: Error?) -> Void) -> Void {
        let url = URL(string: url)
        guard let url = url else {
            debugPrint("Error while unwrapping url")
            return
        }
        
        let urlSession = URLSession.shared
        let task = urlSession.dataTask(with: url){ (data, response, error) -> Void in
            
            if error != nil {
                debugPrint("Error decoing data: ", error!)
                completion(nil, error)
                return
            }
            
            do{
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let data: T = try decoder.decode(T.self, from: data)
                    completion(data, nil)
                    return
                }
                completion(nil, nil)
            } catch {
                debugPrint("Error on api: ", error)
            }
        }
        
        task.resume()
    }
}
