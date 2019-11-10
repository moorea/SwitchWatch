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
    
    var currentDuration: Double {
        currentItem?.currentDuration ?? -1
    }
    
    var playProgress: Double {
        currentItem?.playProgress ?? -1
    }
    
    var totalDuration: Double {
        currentItem?.totalDuration ?? -1
    }
}
