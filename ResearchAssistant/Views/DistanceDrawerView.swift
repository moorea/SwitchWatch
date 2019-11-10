//
//  DistanceDrawerView.swift
//  ResearchAssistant
//
//  Created by Moore, Andrew on 9/14/19.
//  Copyright © 2019 Andrew Moore. All rights reserved.
//

import SwiftUI

enum DistanceDrawingState {
    case selectingVideo
    case calibrating
    case observing
}

struct DistanceDrawer {
    var state: DistanceDrawingState = .selectingVideo
    
    var calibrationDrawing: Drawing = Drawing()
    var drawingOne: Drawing = Drawing()
    var drawingTwo: Drawing = Drawing()
    
}

struct DistanceDrawerView: View {
    @State private var state: DistanceDrawingState = .selectingVideo
    
    @State private var calibrationDrawing: Drawing = Drawing()
    @State private var calibrationDistance: String = "3"
    
    @State private var drawingOne: Drawing = Drawing()
    @State private var drawingTwo: Drawing = Drawing()

    @State private var isAutoReplay: Bool = false
    @State private var isPlay: Bool = true
    @State private var isMute: Bool = true
    
    @State private var processor: VideoFrameOverlayProcessor?
    
    @State private var distanceRatio: CGFloat = 0.0
    
    var body: some View {
        VStack(alignment: .leading) {
            if state == .selectingVideo {
                HStack {
                    Text("Step 1: Select Video")
                        .font(.largeTitle)
                    Spacer()
                }
                
                VideoPickerButton { videoURL in
                    self.processor = VideoFrameOverlayProcessor(videoFileURL: videoURL)
                    self.state = .calibrating
                }
                Spacer()
            }
            else if state == .calibrating {
                VStack(alignment: .leading, spacing: 4.0) {
                    Text("Step 2: Calibrate")
                        .font(.largeTitle)
                    HStack {
                        Text("Draw a ")
                        TextField("#", text: $calibrationDistance)
                            .frame(width: 25, alignment: .center)
                            .keyboardType(.numberPad)
                        Text("inch line")
                        Spacer()
                        Button(action: {
                            guard let realWorldDistance = Float(self.calibrationDistance) else {
                                return
                            }
                            self.distanceRatio = CGFloat(realWorldDistance) / self.calibrationDrawing.totalDistance
                            self.state = .observing
                        }) {
                            Text("Done")
                        }
                    }
                    ZStack (alignment: .top) {
                        if processor?.url != nil {
                            VideoPlayerView(url: .constant(processor!.url), isPlay: .constant(true))
                                .autoReplay(.constant(false))
                                .mute(.constant(true))
                        }
                        
                        CalibrationPad(drawing: $calibrationDrawing)
                    }
                }
            }
            else if state == .observing {
                Text("Step 3: Observe")
                    .font(.largeTitle)
                Text("Distance 1: \(String(format: "%.1f inches", drawingOne.realWorldDistance(with: distanceRatio)))")
                    .font(.subheadline)
                Text("Distance 2: \(String(format: "%.1f inches", drawingTwo.realWorldDistance(with: distanceRatio)))")
                    .font(.subheadline)
                
                ZStack (alignment: .top) {
                    if processor?.url != nil {
                        VideoPlayerView(url: .constant(processor!.url), isPlay: $isPlay)
                            .autoReplay($isAutoReplay)
                            .mute($isMute)
                            .onPlayToEndTime { print("Play to the end time.") }
                            .onReplay { print("Replay after playing to the end.") }
                            .onStateChanged { _ in print("Playback status changes, such as from play to pause.") }
                    }
                    
                    DrawingPad(drawingOne: $drawingOne, drawingTwo: $drawingTwo)
                }
            }
        }
        .padding()
    }
}

struct CalibrationPad: View {
    @Binding var drawing: Drawing

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                self.add(drawing: self.drawing, toPath: &path)
            }
            .stroke(Color.red, lineWidth: 2.0)
            .background(Color(hue: 0.0, saturation: 0.0, brightness: 0.0, opacity: 0.1))
            .gesture(
                DragGesture(minimumDistance: 0.1)
                    .onChanged({ (value) in
                        let currentPoint = value.location
                        if currentPoint.y >= 0 && currentPoint.y < geometry.size.height {
                            self.drawing.points.append(currentPoint)
                        }
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
            .background(Color(hue: 0.0, saturation: 0.0, brightness: 0.0, opacity: 0.1))
            .gesture(
                DragGesture(minimumDistance: 0.1)
                    .onChanged({ (value) in
                        let currentPoint = value.location
                        if currentPoint.y >= 0 && currentPoint.y < geometry.size.height {
                            // Start line one if not already started
                            guard let mostRecentOne = self.drawingOne.points.last else {
                                self.drawingOne.points.append(currentPoint)
                                return
                            }
                            
                            let distanceToOne = mostRecentOne.distance(to: currentPoint)
                            
                            if distanceToOne < 50 {
                                self.drawingOne.points.append(currentPoint)
                                return
                            }
                            
                            
                            //Start line two if tapping farther than 50 px from line one for first time
                            guard let mostRecentTwo = self.drawingTwo.points.last else {
                                self.drawingTwo.points.append(currentPoint)
                                return
                            }
                            
                            let distanceToTwo = mostRecentTwo.distance(to: currentPoint)

                            if distanceToTwo < 50 {
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
