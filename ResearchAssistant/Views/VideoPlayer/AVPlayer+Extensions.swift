//
//  AVPlayer+Extensions.swift
//  ResearchAssistant
//
//  Created by Andrew Moore on 9/17/19.
//  Copyright © 2019 Andrew Moore. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

public extension AVPlayer {
    
    var bufferProgress: Double {
        currentItem?.bufferProgress ?? -1
    }
    
    var currentBufferDuration: Double {
        currentItem?.currentBufferDuration ?? -1
    }
    
    var currentDuration: Double {
        currentItem?.currentDuration ?? -1
    }
    
    var currentImage: UIImage? {
        guard
            let playerItem = currentItem,
            let cgImage = try? AVAssetImageGenerator(asset: playerItem.asset).copyCGImage(at: currentTime(), actualTime: nil)
            else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
    
    var playProgress: Double {
        currentItem?.playProgress ?? -1
    }
    
    var totalDuration: Double {
        currentItem?.totalDuration ?? -1
    }
    
    convenience init(asset: AVURLAsset) {
        self.init(playerItem: AVPlayerItem(asset: asset))
    }
    
}
