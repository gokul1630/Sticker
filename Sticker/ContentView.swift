//
//  ContentView.swift
//  Sticker
//
//  Created by Gokulprasanth on 18/01/24.
//

import SwiftUI
import UIKit

let token = ""
let grids:Int = 5

struct ContentView: View {
    let stickerMaxPackSize: Int = 30
    
    let columns = Array(repeating: GridItem(), count: grids)
    @State private var stickerUrls: [[String]] = []
    
    @State private var stickerPackName:String = "https://t.me/addstickers/web_technology_logos"
    @FocusState private var keyboardFocus: Bool
    @State private var packName: String = ""
    
    var stickerpackName:String {
        if (stickerPackName.starts(with: /http.*/.ignoresCase())){
            let name = stickerPackName.split(separator: "/")
            return String(name[name.count-1])
        }
        return stickerPackName
    }
    
    var body: some View {
        
        TextField("Enter telegram set name or sticker pack link", text: $stickerPackName)
            .padding()
            .focused($keyboardFocus)
            .foregroundStyle(.white)
        
        
        Button("Fetch Stickers"){
            keyboardFocus = false
            debugPrint(stickerpackName)
            FetchStickerUrls(stickerName: stickerpackName){ (stickerUrls, metaData, error) in
                
                if let error = error{
                    debugPrint("Error: ",error)
                    return
                }
                
                if stickerUrls.count > stickerMaxPackSize {
                    let noOfPacks = Int(ceil(Double(stickerUrls.count) / Double(stickerMaxPackSize)))
                    
                    for i in 0..<noOfPacks {
                        
                        
                        let startIndex = i * stickerMaxPackSize
                        let endIndex = min((i + 1) * stickerMaxPackSize, stickerUrls.count)
                        let pack = Array(stickerUrls[startIndex..<endIndex])
                        
                        self.stickerUrls.append(pack)
                        
                    }
                } else {
                    
                    self.stickerUrls.append(stickerUrls)
                }
                
                if let metaData = metaData{
                    self.packName = metaData.result.title
                }
            }
        }
        
        .frame(width: 150,height: 40).background(.blue)
        .foregroundStyle(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .contentShape(RoundedRectangle(cornerRadius: 20))
        
        NavigationStack{
            
            
            ScrollView{
                
                
                ForEach(stickerUrls.indices,id: \.self){ index in
                    
                    
                    NavigationLink{
                        ScrollView {
                            LazyVGrid(columns: columns,alignment: .center){
                                ForEach(stickerUrls[index], id: \.self){ i in
                                    
                                    AsyncImage(url: URL(string: i)!){ img in
                                        switch img {
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .frame(width:70, height:70)
                                                .scaledToFit()
                                        default:
                                            Rectangle()
                                                .foregroundStyle(.gray)
                                                .clipShape(.rect(cornerRadius: 10))
                                                .frame(width:70, height:70)
                                            
                                        }
                                        
                                    }
                                }
                            }
                        }
                        Button("Add to whatsapp"){
                            sendToWhatsApp(stickers: stickerUrls[index], packName: "\(packName) (\(index+1) / \(stickerUrls.count))" )
                            
                        }.frame(width: 300,height: 50).background(.blue)
                            .foregroundStyle(.white)
                            .clipShape(.rect(cornerRadius: 20))
                    }label: {
                        
                        VStack(alignment:.leading,spacing: 10){
                            Text("Pack \(index+1)")
                            LazyVGrid(columns: columns,alignment: .trailing){
                                ForEach(stickerUrls[index][0..<grids],id:\.self){ i in
                                    
                                    
                                    AsyncImage(url: URL(string: i)!){ img in
                                        switch img {
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .frame(width:70, height:70)
                                                .scaledToFit()
                                        default:
                                            Rectangle()
                                                .foregroundStyle(.gray)
                                                .clipShape(.rect(cornerRadius: 10))
                                                .frame(width:70, height:70)
                                        }
                                        
                                    }
                                }
                            }
                        }
                    }
                }
                
            }.padding(10)
        }
    }
}

func FetchStickerUrls(stickerName: String, completion: @escaping ([String], StickerMetadata?, Error?) -> Void){
    var stickerIdUrls: [String] = []
    var stickerUrls: [String] = []
    var metaData: StickerMetadata? = nil
    
    let dispatchGroup = DispatchGroup()
    let apiQueue = DispatchQueue.global(qos: .background)
    
    let stickerPackUrl = "https://api.telegram.org/bot\(token)/getStickerSet?name=\(stickerName)"
    
    dispatchGroup.enter()
    apiQueue.async {
        DownloadManager.download(StickerMetadata.self, url: stickerPackUrl){ (data, error) in
            defer {dispatchGroup.leave()}
            if let error = error {
                debugPrint("Error: ", error)
                completion([],nil,error)
                return
            }
            guard let data = data else {
                debugPrint("Error while unwrapping data: ", error!)
                completion([],nil,error)
                return
            }
            metaData = data
            data.result.stickers.forEach { stickerMetaData in
                let stickerFileUrl = "https://api.telegram.org/bot\(token)/getFile?file_id=\(stickerMetaData.fileId)"
                stickerIdUrls.append(stickerFileUrl)
            }
            
            FetchStickerFileMeta()
        }
    }
    
    
    
    func FetchStickerFileMeta(){
        for stickerIdUrl in stickerIdUrls {
            dispatchGroup.enter()
            DownloadManager.download(StickerData.self, url: stickerIdUrl){ (stickerData, error) in
                if let error = error {
                    debugPrint("Error: ", error)
                    completion([],nil,error)
                    return
                }
                
                if let stickerData = stickerData {
                    let stickerUrl = "https://api.telegram.org/file/bot\(token)/\(stickerData.result.filePath)"
                    
                    stickerUrls.append(stickerUrl)
                }
                dispatchGroup.leave()
            }
        }
        
        
        dispatchGroup.notify(queue: .main, execute: {
            completion(stickerUrls,metaData, nil)
        })
    }
}

actor StickerActor{
    var thumbData: Data? = nil
    var stickerDatas: [Data] = []
    
    func setThumbData(data: Data){
        thumbData = data
    }
    
    func setStickerData(data: Data){
        stickerDatas.append(data)
    }
}


func sendToWhatsApp(stickers: [String], packName: String) {
    let processImage = ProcessImage()

    let stickerSize: CGFloat = 170.6

    let trayIconSize: CGFloat = 32
    
    let dispatchGroup = DispatchGroup()
    
    let apiQueue = DispatchQueue.global()
    
    var stickerDatas: [Data] = []
    
    var thumbData: Data? = nil
    
    let maxStickerSize = 102400
    
    
    
    apiQueue.async {
        
        for stickerUrl in stickers {
            dispatchGroup.enter()
            
            
            
            if let imageUrl = URL(string: stickerUrl) {
                processImage.addOverlay(url: imageUrl, overlayColor: .cyan, size: stickerSize, type: .webP) { stickerData in
                    
                    defer { dispatchGroup.leave() }
                    
                    if let stickerData = stickerData {
                        if Int64(stickerData.count) < maxStickerSize {
                            stickerDatas.append(stickerData)
                        }
                    }
                }
            }
            
        }
        
        
        dispatchGroup.enter()
        
        if let imageUrl = URL(string: stickers[0]) {
            processImage.addOverlay(url: imageUrl, overlayColor: .cyan, size: trayIconSize, type: .PNG) { stickerData in
                
                defer { dispatchGroup.leave() }
                
                if let stickerData = stickerData {
                    thumbData = stickerData
                }
            }
        }
        
        
        dispatchGroup.notify(queue: .main) {
            do {
                let stickerPack = try StickerPack(
                    identifier: "com.test.sticker",
                    name: packName,
                    publisher: "gokul",
                    trayImagePNGData: thumbData!,
                    animatedStickerPack: false,
                    publisherWebsite: "",
                    privacyPolicyWebsite: "",
                    licenseAgreementWebsite: "")
                
                stickerPack.sendToWhatsApp(data: stickerDatas, completionHandler: {
                    debugPrint("\($0) sent to wa")
                })
            } catch {
                printError(error)
            }
        }
    }
}


func printError(_ error: Error){
    debugPrint("error :", error)
}
