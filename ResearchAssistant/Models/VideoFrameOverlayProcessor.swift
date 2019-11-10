//
//  VideoFrameOverlayProcessor.swift
//  ResearchAssistant
//
//  Created by Moore, Andrew on 9/13/19.
//  Copyright © 2019 Andrew Moore. All rights reserved.
//

import Foundation
import AVFoundation
import Combine
import UIKit

class VideoFrameOverlayProcessor: ObservableObject, Identifiable {
    
    let frameSampleSize = 1500
    var combinedImage: UIImage? {
        didSet {
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
    }
    
    let objectWillChange = ObservableObjectPublisher()
    var id = UUID()
    
    let url: URL
    let asset: AVURLAsset
    let videoTrack: AVAssetTrack?
    
    var fileSizeInBytes: Int {
        do {
            let resources = try url.resourceValues(forKeys:[.fileSizeKey])
            let fileSize = resources.fileSize!
            return fileSize
        } catch {
            print("Error: \(error)")
            return 0
        }
    }
    
    var fileDetails: String {
        "Name: \(url.absoluteURL.lastPathComponent)\n" +
        "Size: \(String(format: "%.1f", (Double(fileSizeInBytes) / 1000000.0))) MB\n" +
        "Frame Rate: \(Int((videoTrack?.nominalFrameRate ?? 0.0).rounded())) fps\n" +
        "Duration: \(String(format: "%.1f", asset.duration.seconds)) sec\n" +
        "Total frames: \(Int(asset.duration.seconds * Double(videoTrack?.nominalFrameRate ?? 0.0))) \n"
    }
    
    init(videoFileURL: URL) {
        url = videoFileURL
        asset = AVURLAsset(url: url)
        videoTrack = asset.tracks(withMediaType: .video).first
        objectWillChange.send()
    }
    
    func analyzeVideo(duration: Double? = nil, completion: ((URL?)->Void)?) {
        
        let videoDurationSeconds = duration ?? asset.duration.seconds
        var sampleTimes: [NSValue] = []
        let totalTimeLength = Int(videoDurationSeconds * Double(asset.duration.timescale))
        let step = totalTimeLength / frameSampleSize
        
        for i in 0 ..< frameSampleSize {
            let cmTime = CMTimeMake(value: Int64(i * step), timescale: Int32(asset.duration.timescale))
            sampleTimes.append(NSValue(time: cmTime))
        }
        
        print(sampleTimes)
        
        let generator = AVAssetImageGenerator(asset: asset)
        generator.requestedTimeToleranceAfter = .zero
        generator.requestedTimeToleranceBefore = .zero
        generator.generateCGImagesAsynchronously(forTimes: sampleTimes) { (requestedTime, image, time2, result, error) in
            
            guard error == nil, let image = image else {
                return
            }

            if let firstRequestedTime = sampleTimes.first, firstRequestedTime == NSValue(time: requestedTime) {
                self.combinedImage = UIImage(cgImage: image)
            }
            
            print("got a frame @ \(NSValue(time: requestedTime))")
            
            self.combinedImage = self.combine(imageOne: self.combinedImage, with: self.processByPixel(in: UIImage(cgImage: image))!)
            
            if let lastRequestedTime = sampleTimes.last, lastRequestedTime == NSValue(time: requestedTime) {
                print("that's all folks")
                let newFile = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("MyImage.png")
                
                do {
                    try self.combinedImage?.pngData()?.write(to: newFile!, options: [.atomic])
                    completion?(newFile)
                } catch {
                    print("Failed to create image file")
                    print("\(error)")
                    completion?(nil)
                }
            }
        }
    }
    
    func combine(imageOne: UIImage?, with imageTwo: UIImage) -> UIImage {
        
        let size = CGSize(width: imageTwo.size.width, height: imageTwo.size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        imageOne?.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height), blendMode: .normal, alpha: 1)
        imageTwo.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height), blendMode: .normal, alpha: 1)

        let newCombinedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newCombinedImage
    }
    
    func processByPixel(in image: UIImage) -> UIImage? {

        guard let inputCGImage = image.cgImage else { print("unable to get cgImage"); return nil }
        let colorSpace       = CGColorSpaceCreateDeviceRGB()
        let width            = inputCGImage.width
        let height           = inputCGImage.height
        let bytesPerPixel    = 4
        let bitsPerComponent = 8
        let bytesPerRow      = bytesPerPixel * width
        let bitmapInfo       = RGBA32.bitmapInfo

        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
            print("Cannot create context!"); return nil
        }
        context.draw(inputCGImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        guard let buffer = context.data else { print("Cannot get context data!"); return nil }

        let pixelBuffer = buffer.bindMemory(to: RGBA32.self, capacity: width * height)

        for row in 0 ..< Int(height) {
            for column in 0 ..< Int(width) {
                let offset = row * width + column

               /*
                 * Here I'm looking for color : RGBA32(red: 231, green: 239, blue: 247, alpha: 255)
                 * and I will convert pixels color that in range of above color to transparent
                 * so comparetion can done like this (pixelColorRedComp >= ourColorRedComp - 1 && pixelColorRedComp <= ourColorRedComp + 1 && green && blue)
                 */

                if pixelBuffer[offset].redComponent >  50 ||
                    pixelBuffer[offset].greenComponent >  50 ||
                    pixelBuffer[offset].blueComponent > 50  {
                    pixelBuffer[offset] = .transparent
                }
            }
        }

        let outputCGImage = context.makeImage()!
        let outputImage = UIImage(cgImage: outputCGImage, scale: image.scale, orientation: image.imageOrientation)

        return outputImage
    }
    
    struct RGBA32: Equatable {
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
            let red   = UInt32(red)
            let green = UInt32(green)
            let blue  = UInt32(blue)
            let alpha = UInt32(alpha)
            color = (red << 24) | (green << 16) | (blue << 8) | (alpha << 0)
        }

        static let red     = RGBA32(red: 255, green: 0,   blue: 0,   alpha: 255)
        static let green   = RGBA32(red: 0,   green: 255, blue: 0,   alpha: 255)
        static let blue    = RGBA32(red: 0,   green: 0,   blue: 255, alpha: 255)
        static let white   = RGBA32(red: 255, green: 255, blue: 255, alpha: 255)
        static let black   = RGBA32(red: 0,   green: 0,   blue: 0,   alpha: 255)
        static let magenta = RGBA32(red: 255, green: 0,   blue: 255, alpha: 255)
        static let yellow  = RGBA32(red: 255, green: 255, blue: 0,   alpha: 255)
        static let cyan    = RGBA32(red: 0,   green: 255, blue: 255, alpha: 255)
        static let transparent = RGBA32(red: 0,   green: 0, blue: 0, alpha: 0)

        static let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue

        static func ==(lhs: RGBA32, rhs: RGBA32) -> Bool {
            return lhs.color == rhs.color
        }
    }
}

