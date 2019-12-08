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

enum AnalysisState: CustomStringConvertible {
    case notStarted
    case inProgress
    case cancelled
    case complete
    
    var hasStoppedRunning: Bool {
        switch self {
        case .notStarted, .inProgress:
            return false
        case .cancelled, .complete:
            return true
        }
    }
    
    var description: String {
        switch self {
        case .notStarted:
            return "Not Started"
        case .inProgress:
            return "In-progress"
        case .cancelled:
            return "Cancelled"
        case .complete:
            return "Complete"
        }
    }
}

class VideoFrameOverlayProcessor: ObservableObject, Identifiable {
    
    private let defaultFrameSampleSize = 1500
    private let asset: AVURLAsset
    private let videoTrack: AVAssetTrack?
    
    @Published var combinedImage: UIImage?
    @Published var progress: Double
    
    var id = UUID()
    var generator: AVAssetImageGenerator?
    
    // TODO: Make this private?
    let url: URL
    var fileDetails: String? = "Unknown"
    var fileSizeInBytes: Int? = nil
    
    var analysisState: AnalysisState = .notStarted {
        didSet {
            switch analysisState {
            case .cancelled:
                generator?.cancelAllCGImageGeneration()
            default:
                print("analysisState changed to \(analysisState.description)")
            }
        }
    }
    
    init(videoFileURL: URL) {
        progress = 0.0
        url = videoFileURL
        asset = AVURLAsset(url: url)
        videoTrack = asset.tracks(withMediaType: .video).first
        extractFileMetadata()
    }
    
    private func extractFileMetadata() {
        do {
            let resources = try url.resourceValues(forKeys:[.fileSizeKey])
            fileSizeInBytes = resources.fileSize

            guard let fileSizeInBytes = fileSizeInBytes else {
                return
            }
            fileDetails = "Name: \(url.absoluteURL.lastPathComponent)\n" +
                "Size: \(String(format: "%.1f", (Double(fileSizeInBytes) / 1000000.0))) MB\n" +
                "Frame Rate: \(Int((videoTrack?.nominalFrameRate ?? 0.0).rounded())) fps\n" +
                "Duration: \(String(format: "%.1f", asset.duration.seconds)) sec\n" +
                "Total frames: \(Int(asset.duration.seconds * Double(videoTrack?.nominalFrameRate ?? 0.0))) \n"
        } catch {
            fileDetails = "Error Loading File"
        }
    }
    
    func analyzeVideo() {
        analyzeVideo(requestedDurationToAnalyze: asset.duration.seconds)
    }
    
    func analyzeVideo(requestedDurationToAnalyze: Double) {
        analysisState = .inProgress
        
        let totalFrames = Int(asset.duration.seconds * Double(videoTrack?.nominalFrameRate ?? 0.0))
        let sampleSize = defaultFrameSampleSize > totalFrames ? totalFrames : defaultFrameSampleSize
        
        let secondsToAnalyze = requestedDurationToAnalyze > asset.duration.seconds ? asset.duration.seconds : requestedDurationToAnalyze
        
        var sampleTimes: [NSValue] = []
        let totalTimeLength = Int(secondsToAnalyze * Double(asset.duration.timescale))
        let step = totalTimeLength / sampleSize
        
        for i in 0 ..< sampleSize {
            let cmTime = CMTimeMake(value: Int64(i * step), timescale: Int32(asset.duration.timescale))
            sampleTimes.append(NSValue(time: cmTime))
        }
        
        generator = AVAssetImageGenerator(asset: asset)
        generator?.requestedTimeToleranceAfter = .zero
        generator?.requestedTimeToleranceBefore = .zero
        if let naturalSize = videoTrack?.naturalSize {
            generator?.maximumSize = CGSize(width: naturalSize.width / 1.5, height: naturalSize.height / 1.5)
        }
        
        generator?.generateCGImagesAsynchronously(forTimes: sampleTimes) { [weak self] (requestedTime, image, actualTime, result, error) in
            
            print("Received image from actualTime: \(actualTime). Result: \(result.rawValue)")
            
            guard result == AVAssetImageGenerator.Result.succeeded else {
                print("Analysis has been cancelled or errored. Skipping frame analysis.")
                return
            }
            
            guard error == nil, let image = image else {
                print("Received an error or missing image. Skipping frame analysis.")
                return
            }
            
            guard let strongSelf = self else {
                print("Referenece to self has been lost. Skipping frame analysis.")
                return
            }
            
            guard strongSelf.analysisState != .cancelled else {
                print("Analysis has been cancelled. Skipping frame analysis.")
                return
            }

            var currentCombinedImage = strongSelf.combinedImage
            if let firstRequestedTime = sampleTimes.first, firstRequestedTime == NSValue(time: requestedTime) {
                currentCombinedImage = UIImage(cgImage: image)
                
                DispatchQueue.main.async {
                    strongSelf.combinedImage = currentCombinedImage
                }
            }
            
            let newCombinedImage = strongSelf.combine(imageOne: currentCombinedImage, with: strongSelf.processByPixel(in: UIImage(cgImage: image))!)
            
            if let lastRequestedTime = sampleTimes.last, lastRequestedTime == NSValue(time: requestedTime) {
                strongSelf.analysisState = .complete
            }
            
            DispatchQueue.main.async {
                guard let lastTime = sampleTimes.last as? CMTime else {
                    return
                }
                // Note: this method of measuring progress assumes we always start at the beginning of the video
                strongSelf.progress = requestedTime.seconds / lastTime.seconds
                strongSelf.combinedImage = newCombinedImage
            }
        }
    }
    
    func saveCombinedImageToFile(named: String) -> URL? {
        guard let newFile = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(named).png") else {
            return nil
        }
        
        do {
            try combinedImage?.pngData()?.write(to: newFile, options: [.atomic])
            return newFile
        } catch {
            print("Failed to write combinedImage to file")
            return nil
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

        guard let inputCGImage = image.cgImage else {
            return nil
        }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let width = inputCGImage.width
        let height = inputCGImage.height
        let bytesPerPixel = 4
        let bitsPerComponent = 8
        let bytesPerRow = bytesPerPixel * width
        let bitmapInfo = RGBA32.bitmapInfo

        guard let context =
            CGContext(
                data: nil,
                width: width,
                height: height,
                bitsPerComponent: bitsPerComponent,
                bytesPerRow: bytesPerRow,
                space: colorSpace,
                bitmapInfo: bitmapInfo) else {
            return nil
        }
        context.draw(inputCGImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        guard let buffer = context.data else { return nil }

        let pixelBuffer = buffer.bindMemory(to: RGBA32.self, capacity: width * height)

        for row in 0 ..< Int(height) {
            for column in 0 ..< Int(width) {
                let offset = row * width + column
                
                if pixelBuffer[offset].redComponent >  50 ||
                    pixelBuffer[offset].greenComponent >  50 ||
                    pixelBuffer[offset].blueComponent > 50 {
                    pixelBuffer[offset] = .transparent
                }
            }
        }

        let outputCGImage = context.makeImage()!
        let outputImage = UIImage(cgImage: outputCGImage, scale: image.scale, orientation: image.imageOrientation)

        return outputImage
    }
}
