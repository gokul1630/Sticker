//
//  StickerPacks.swift
//  Sticker
//
//  Created by Gokulprasanth on 11/02/24.
//

import SwiftUI

struct StickerPacks: View {
    @State private var stickerUrls: [[String]] = []
    
    @State private var stickerPackName:String = "https://t.me/addstickers/web_technology_logos"
    
    @FocusState private var keyboardFocus: Bool
    
    @State private var packName: String = ""
    
    @State private var showSheet = false
    
    @State private var currentIndex:Int = 0
    
    var stickerpackName:String {
        if (stickerPackName.starts(with: /http.*/.ignoresCase())){
            let name = stickerPackName.split(separator: "/")
            return String(name[name.count-1])
        }
        return stickerPackName
    }
    
    
    var body: some View{
        
        TextField("Enter telegram set name or sticker pack link", text: $stickerPackName)
            .padding()
            .focused($keyboardFocus)
            .foregroundStyle(.primary)
            .border(.blue)
        
        
        
        Button("Fetch Stickers"){
            keyboardFocus = false
            
            
            
            FetchStickerUrls(stickerName: stickerpackName){ (stickerUrls, metaData, error) in
                
                if let error = error{
                    debugPrint("Error: ",error)
                    return
                }
                
                if stickerUrls.count > stickerMaxPackSize {
                    let noOfPacks = Int(ceil(Double(stickerUrls.count) / Double(stickerMaxPackSize)))
                    
                    for packs in 0..<noOfPacks {
                        
                        
                        let startIndex = packs * stickerMaxPackSize
                        let endIndex = min((packs + 1) * stickerMaxPackSize, stickerUrls.count)
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
        .disabled(stickerUrls.count>0)
        .frame(width: 150,height: 40).background(.blue)
        .foregroundStyle(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .contentShape(RoundedRectangle(cornerRadius: 20))
        
        ScrollView{
            ForEach(stickerUrls.indices,id: \.self){ index in
                
                VStack(alignment:.leading,spacing: 10){
                    Text("Pack \(index+1)")
                    LazyVGrid(columns: columns,alignment: .trailing){
                        ForEach(stickerUrls[index][0..<grids], id:\.self){ stickerUrl in
                            AsyncImage(url: URL(string: stickerUrl)!){ img in
                                switch img {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .frame(width:70, height:70)
                                        .aspectRatio(contentMode: .fit)
                                default:
                                    Rectangle()
                                        .foregroundStyle(.gray)
                                        .clipShape(.rect(cornerRadius: 10))
                                        .frame(width:70, height:70)
                                }
                            }
                        }
                    }.onTapGesture {
                        currentIndex = index
                        showSheet = true
                    }
                }
                .sheet(isPresented: $showSheet){
                    StickerPackList(stickerUrls: stickerUrls[currentIndex], packName: "\(packName) (\(currentIndex+1) / \(stickerUrls.count))", showSheet: $showSheet)
                }
            }.navigationTitle("Add Stickers")
        }.padding(10)
    }
}

func FetchStickerUrls(stickerName: String, completion: @escaping ([String], StickerMetadata?, Error?) -> Void){
    var stickerIdUrls: [String] = []
    var stickerUrls: [String] = []
    var metaData: StickerMetadata? = nil
    let downloadManager = DownloadManager()
    
    let dispatchGroup = DispatchGroup()
    let apiQueue = DispatchQueue.global(qos: .background)
    
    let stickerPackUrl = "https://api.telegram.org/bot\(token)/getStickerSet?name=\(stickerName)"
    
    
    apiQueue.async {
        dispatchGroup.enter()
        downloadManager.download(StickerMetadata.self, url: stickerPackUrl){ (data, error) in
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
            
            for stickerIdUrl in stickerIdUrls {
                dispatchGroup.enter()
                downloadManager.download(StickerData.self, url: stickerIdUrl){ (stickerData, error) in
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
}

