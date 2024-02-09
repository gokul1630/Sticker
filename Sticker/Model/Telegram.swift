//
//  Telegram.swift
//  Sticker
//
//  Created by Gokulprasanth on 28/01/24.
//

import Foundation

struct Thumb: Codable{
    let fileId: String
}

struct Stickers: Codable {
    let emoji:String
    let fileId: String
    let thumb: Thumb
}

struct MetaDataResult: Codable {
    let isAnimated: Bool
    let title: String
    let name: String
    let stickers: [Stickers]
}

struct StickerMetadata: Codable {
    let ok: Bool
    let result: MetaDataResult
}

struct StickerDataResult: Codable{
    let filePath: String
}

struct StickerData: Codable {
    let ok: Bool
    let result: StickerDataResult
}
