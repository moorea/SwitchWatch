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
    @State private var drawingOne: Drawing = Drawing()
    @State private var drawingTwo: Drawing = Drawing()

    var body: some View {
        VStack(alignment: .center) {
            Text("Distance 1: \(String(format: "%.1f", drawingOne.totalDistance))")
                .font(.largeTitle)
            Text("Distance 2: \(String(format: "%.1f", drawingTwo.totalDistance))")
                .font(.largeTitle)
            DrawingPad(drawingOne: $drawingOne, drawingTwo: $drawingTwo)
        }
    }
}

struct DrawingPad: View {
    @Binding var drawingOne: Drawing
    @Binding var drawingTwo: Drawing

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                self.add(drawing: self.drawingOne, toPath: &path)
                self.add(drawing: self.drawingTwo, toPath: &path)
            }
            .stroke(Color.black, lineWidth: 2.0)
            .background(Color(white: 0.95))
            .gesture(
                DragGesture(minimumDistance: 0.1)
                    .onChanged({ (value) in
                        let currentPoint = value.location
                        if currentPoint.y >= 0 && currentPoint.y < geometry.size.height {
                            guard let mostRecentOne = self.drawingOne.points.last else {
                                self.drawingOne.points.append(currentPoint)
                                return
                            }
                            let distanceToOne = mostRecentOne.distance(to: currentPoint)
                            
                            guard distanceToOne > 200 else {
                                self.drawingOne.points.append(currentPoint)
                                return
                            }
                            
                            guard let mostRecentTwo = self.drawingTwo.points.last else {
                                self.drawingTwo.points.append(currentPoint)
                                return
                            }
                            
                            let distanceToTwo = mostRecentTwo.distance(to: currentPoint)

                            guard distanceToTwo > 200 else {
                                self.drawingTwo.points.append(currentPoint)
                                return
                            }
                            
                            if distanceToOne < distanceToTwo {
                                self.drawingOne.points.append(currentPoint)
                            } else {
                                self.drawingTwo.points.append(currentPoint)
                            }
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
