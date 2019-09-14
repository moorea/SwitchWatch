//
//  DistanceDrawerView.swift
//  ResearchAssistant
//
//  Created by Moore, Andrew on 9/14/19.
//  Copyright © 2019 Andrew Moore. All rights reserved.
//

import SwiftUI

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
}

struct DistanceDrawerView: View {
    @State private var currentDrawing: Drawing = Drawing()
    @State private var drawings: [Drawing] = [Drawing]()
    
    var body: some View {
        VStack(alignment: .center) {
            Text("Distance: \(String(format: "%.1f", currentDrawing.totalDistance))")
                .font(.largeTitle)
            DrawingPad(currentDrawing: $currentDrawing, drawings: $drawings)
        }
    }
}

struct DrawingPad: View {
    @Binding var currentDrawing: Drawing
    @Binding var drawings: [Drawing]
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                for drawing in self.drawings {
                    self.add(drawing: drawing, toPath: &path)
                }
                self.add(drawing: self.currentDrawing, toPath: &path)
            }
            .stroke(Color.black, lineWidth: 2.0)
            .background(Color(white: 0.95))
            .gesture(
                DragGesture(minimumDistance: 0.1)
                    .onChanged({ (value) in
                        let currentPoint = value.location
                        if currentPoint.y >= 0 && currentPoint.y < geometry.size.height {
                            self.currentDrawing.points.append(currentPoint)
                        }
                    })
                    .onEnded({ (value) in
                        //self.drawings.append(self.currentDrawing)
                        //self.currentDrawing = Drawing()
                    })
            )
        }
        .frame(maxHeight: .infinity)
    }
    
    private func add(drawing: Drawing, toPath path: inout Path) {
        let points = drawing.points
        if points.count > 1 {
            for i in 0..<points.count-1 {
                let current = points[i]
                let next = points[i+1]
                path.move(to: current)
                path.addLine(to: next)
            }
        }
    }
}
