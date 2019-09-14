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
    
    let frameSampleSize = 20
    var analyzeCompletion: ((URL?)->Void)? = nil
    var frames: [CGImage] = [] {
        didSet {
            if frames.count == frameSampleSize {
                putFramesTogether(frames: frames)
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
    }
    
    func analyzeVideo(completion: ((URL?)->Void)?) {
        analyzeCompletion = completion
        
        let videoDuration = asset.duration
        var sampleTimes: [NSValue] = []
        let totalTimeLength = Int(videoDuration.seconds * Double(videoDuration.timescale))
        let step = totalTimeLength / frameSampleSize
        
        for i in 0 ..< frameSampleSize {
            let cmTime = CMTimeMake(value: Int64(i * step), timescale: Int32(videoDuration.timescale))
            sampleTimes.append(NSValue(time: cmTime))
        }
        
        print(sampleTimes)
        
        let generator = AVAssetImageGenerator(asset: asset)
        generator.requestedTimeToleranceAfter = .zero
        generator.requestedTimeToleranceBefore = .zero
        generator.generateCGImagesAsynchronously(forTimes: sampleTimes) { (time, image, time2, result, error) in
            
            guard error == nil, let image = image else {
                return
            }
            
            self.frames.append(image)
        }
    }
    
    func putFramesTogether(frames: [CGImage]) {
        
        let topImage = UIImage(cgImage: frames[0])
        let bottomImage = UIImage(cgImage: frames[5])

        let size = CGSize(width: topImage.size.width, height: topImage.size.height)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        topImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height), blendMode: .overlay, alpha: 0.2)
        bottomImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height), blendMode: .overlay, alpha: 0.2)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        let newFile = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("MyImage.png")
        
        do {
            try newImage.pngData()?.write(to: newFile!, options: [.atomic])
            self.analyzeCompletion?(newFile)
        } catch {
            print("Failed to create image file")
            print("\(error)")
            self.analyzeCompletion?(nil)
        }
    }
}
