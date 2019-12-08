//
//  RBGA32.swift
//  ResearchAssistant
//
//  Created by Andrew Moore on 12/8/19.
//  Copyright © 2019 Andrew Moore. All rights reserved.
//

import Foundation
import CoreGraphics

struct RGBA32: Equatable {
    
    static let transparent = RGBA32(red: 0, green: 0, blue: 0, alpha: 0)
    static let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue

    static func ==(lhs: RGBA32, rhs: RGBA32) -> Bool {
        return lhs.color == rhs.color
    }
    
    private var color: UInt32

    var redComponent: UInt8 {
        return UInt8((color >> 24) & 255)
    }

    var greenComponent: UInt8 {
        return UInt8((color >> 16) & 255)
    }

    var blueComponent: UInt8 {
        return UInt8((color >> 8) & 255)
    }

    var alphaComponent: UInt8 {
        return UInt8((color >> 0) & 255)
    }

    init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
        let red = UInt32(red)
        let green = UInt32(green)
        let blue = UInt32(blue)
        let alpha = UInt32(alpha)
        color = (red << 24) | (green << 16) | (blue << 8) | (alpha << 0)
    }
}
