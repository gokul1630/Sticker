//
//  DownloadManager.swift
//  Sticker
//
//  Created by Gokulprasanth on 26/01/24.
//
import Foundation

class DownloadManager {

  func download<T: Codable>(_ model: T.Type, url: String, completion: @escaping (T?, _ error: Error?) -> Void) -> Void {
        guard let url = URL(string: url) else {
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
    
    func download(url:String, completion: @escaping (Data?, _ error: Error?) -> Void) -> Void {
        guard let url = URL(string: url) else {
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
            
            if let data = data {
                completion(data, nil)
                return
            }
            completion(nil, nil)
        }
        
        task.resume()
    }
}
