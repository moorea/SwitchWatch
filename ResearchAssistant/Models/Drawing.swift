//
//  Drawing.swift
//  ResearchAssistant
//
//  Created by Andrew Moore on 11/10/19.
//  Copyright © 2019 Andrew Moore. All rights reserved.
//

import Foundation
import UIKit

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return sqrt(pow(x - point.x, 2) + pow(y - point.y, 2))
    }
}

struct Drawing {
    var points: [CGPoint] = [CGPoint]()
    var totalDistance: CGFloat {
        var totalDistance = CGFloat(0)
        guard points.count > 1 else {
            return 0
        }
        for (index, point) in points.enumerated() {
            guard index < points.count - 1 else {
                break
            }
            totalDistance += point.distance(to: points[index + 1])
        }
        return totalDistance
    }
    
    func realWorldDistance(with conversionRatio: CGFloat) -> CGFloat {
        return totalDistance * conversionRatio
    }
}
