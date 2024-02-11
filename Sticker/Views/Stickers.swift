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
let stickerMaxPackSize: Int = 30
let columns = Array(repeating: GridItem(), count: grids)
struct ContentView: View {
    
    var body: some View {
        NavigationStack{
            
            ZStack(alignment: .bottomTrailing){
                List{
                    ForEach(1..<21){
                        Text("dummy list \($0)")
                    }
                }
                
                NavigationLink{
                    StickerPacks()
                } label:{
                    Image(systemName: "plus")
                        .padding()
                        .frame(width: 50, height: 50)
                        .foregroundStyle(.white)
                        .background(.blue)
                        .clipShape(Circle())
                    
                }.padding()
            }.navigationTitle("Stickers")
        }
    }
}
