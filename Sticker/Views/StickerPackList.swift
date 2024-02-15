//
//  StickerPackList.swift
//  Sticker
//
//  Created by Gokulprasanth on 11/02/24.
//

import SwiftUI

struct StickerPackList: View {
    let columns = Array(repeating: GridItem(), count: 4)
    
    var stickerUrls: [String] = []
    @State private var stickerDatas: [Data] = []
    var index: Int = 0
    var packName: String = ""
    @Binding var showSheet: Bool
    
    var body: some View{
        Text(packName)
            .fontWeight(.semibold)
            .font(.title)
            .padding()
        ScrollView {
            LazyVGrid(columns: columns, alignment: .center){
                ForEach(stickerDatas, id: \.self){ stickerData in
                    Image(uiImage: UIImage(data: stickerData)!)
                        .resizable()
                        .frame(width:70, height:70)
                        .aspectRatio(contentMode: .fit)
                }
            }
        }.padding()
            .onAppear(){
                let processImage = ProcessImage()
                for stickerUrl in stickerUrls {
                    
                    processImage.addOverlay(url: stickerUrl, size: 50, type: .png){ data in
                        if let data = data{
                            stickerDatas.append(data)
                        }
                    }
                }
            }
        
        
        HStack{
            Button("Close"){
                showSheet = false
            }
            .frame(maxWidth: .infinity)
            .frame(height:50)
            .background(.red)
            .foregroundStyle(.white)
            .clipShape(.rect(cornerRadius: 20))
            
            Button("Add to WhatsApp"){
                Task(priority:.high){
                    sendToWhatsApp(stickers: stickerUrls, packName: packName )
                }
                
            }
            .frame(maxWidth: .infinity)
            .frame(height:50)
            .background(.blue)
            .foregroundStyle(.white)
            .clipShape(.rect(cornerRadius: 20))
        }.padding()
    }
}



func sendToWhatsApp(stickers: [String], packName: String) {
    let processImage = ProcessImage()
    
    let stickerSize: CGFloat = (512 / UIScreen.main.scale)
    
    let trayIconSize: CGFloat = (96 / UIScreen.main.scale)
    
    let dispatchGroup = DispatchGroup()
    
    let apiQueue = DispatchQueue.global(qos: .background)
    
    var stickerDatas: [Data] = []
    
    // 102.4kb
    let maxStickerSize = 102400
    
    
    
    apiQueue.async {
        
        for stickerUrl in stickers {
            dispatchGroup.enter()
            processImage.addOverlay(url: stickerUrl, size: stickerSize, type: .webp) { stickerData in
                
                defer { dispatchGroup.leave() }
                
                if let stickerData = stickerData {
                    if Int64(stickerData.count) < maxStickerSize {
                        stickerDatas.append(stickerData)
                    }
                }
            }
        }
        
        dispatchGroup.notify(queue: .global()) {
            processImage.addOverlay(url: stickers[0], size: trayIconSize, type: .png) { thumbData in
                if let thumbData = thumbData {
                    do {
                        let stickerPack = try StickerPack(
                            identifier: "com.test.sticker",
                            name: packName,
                            publisher: "gokul",
                            trayImagePNGData: thumbData,
                            animatedStickerPack: false,
                            publisherWebsite: "",
                            privacyPolicyWebsite: "",
                            licenseAgreementWebsite: "")
                        
                        stickerPack.sendToWhatsApp(data: stickerDatas, completionHandler: {
                            debugPrint("\($0) sent to whatsapp")
                        })
                    } catch {
                        debugPrint("Error: ", error)
                    }
                }
            }
        }
    }
}
