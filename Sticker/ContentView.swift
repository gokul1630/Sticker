//
//  ContentView.swift
//  Sticker
//
//  Created by Gokulprasanth on 18/01/24.
//

import SwiftUI
import UIKit

struct ContentView: View {
    var body: some View {
        VStack{
            Button("Send"){
                sendToWhatsApp()
                
            }.onAppear(){
                sendToWhatsApp()
            }
        }
    }
}

func sendToWhatsApp(){
    let thumb = "https://icons.iconarchive.com/icons/dakirby309/simply-styled/96/YouTube-icon.png"
    let stickers = [
        "https://icons.iconarchive.com/icons/dakirby309/simply-styled/96/YouTube-icon.png",
        "https://icons.iconarchive.com/icons/dakirby309/simply-styled/96/YouTube-icon.png",
        "https://icons.iconarchive.com/icons/dakirby309/simply-styled/96/YouTube-icon.png",
       
    ]
    let emojis = ["😅","🎂","🤨"]
    var stickerPack: StickerPack?
    
    DownloadManager.downloadFile(fileUrl: thumb){ thumbSticker in
        do {
        stickerPack = try StickerPack(
            identifier: "com.gokul.sticker",
            name: "test",
            publisher: "gokul",
            trayImageFileName:  thumbSticker!.relativePath, animatedStickerPack: false, publisherWebsite: "", privacyPolicyWebsite:"", licenseAgreementWebsite: "")
            debugPrint("thumb exists : \(FileManager.default.fileExists(atPath: thumbSticker!.relativePath))")
        } catch {
            debugPrint("error :", error)
        }
    }
    DispatchQueue.main.asyncAfter(deadline: .now()+2, execute: {
        for i in stickers{
            if let imageUrl = URL(string: i){
                addOverlayToWebPAndSave(url: imageUrl, overlayColor: .cyan, size: 512){ stickerdata in
                    do{
                        debugPrint("sticker exists : \(FileManager.default.fileExists(atPath: stickerdata.relativePath))")
                        
//                        try stickerPack?.add(contentsOfFile:  stickerdata.relativePath, emojis: emojis.shuffled() )
                        guard let i = UIImage(contentsOfFile: "sticker1")?.pngData() else {
                            return
                        }
                        try stickerPack?.addSticker(imageData: i, type: .png, emojis: emojis.shuffled())
                    } catch{
                        debugPrint("Error :", error)
                    }
                }
            }
        }
    })
    
    DispatchQueue.main.asyncAfter(deadline: .now()+5, execute: {
        stickerPack?.sendToWhatsApp(completionHandler: {
            debugPrint("\($0) sent to wa")
        })
    })
}
