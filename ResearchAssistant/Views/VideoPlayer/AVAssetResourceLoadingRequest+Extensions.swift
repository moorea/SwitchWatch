//
//  AVAssetResourceLoadingRequest+Extensions.swift
//  ResearchAssistant
//
//  Created by Andrew Moore on 9/17/19.
//  Copyright © 2019 Andrew Moore. All rights reserved.
//

import Foundation
import AVFoundation

extension AVAssetResourceLoadingRequest {
    
    var url: URL? {
        let prefix = AVPlayerItem.loaderPrefix
        
        guard
            let urlString = request.url?.absoluteString,
            urlString.hasPrefix(prefix)
            else { return nil }
        
        return urlString.replacingOccurrences(of: prefix, with: "").url
    }
    
}
