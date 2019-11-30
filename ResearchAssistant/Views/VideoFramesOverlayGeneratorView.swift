//
//  VideoFramesOverlayGeneratorView.swift
//  ResearchAssistant
//
//  Created by Moore, Andrew on 9/13/19.
//  Copyright © 2019 Andrew Moore. All rights reserved.
//

import SwiftUI
import Combine

struct VideoFramesOverlayGeneratorView: View {
    
    @State var videoURL: URL?

    var body: some View {
        VStack(alignment: .leading, spacing: 5.0) {
            
            if self.videoURL == nil {
                VideoPickerButton { videoURL in
                    self.videoURL = videoURL
                }
                .padding([.top], 10)
            } else {
                StackProgressView().environmentObject(VideoFrameOverlayProcessor(videoFileURL: self.videoURL!))
            }
            Spacer()
        }
        .padding()
        .navigationBarTitle("Frame Overlayer", displayMode: .inline)
    }
}

struct StackProgressView: View {
    @EnvironmentObject var processor: VideoFrameOverlayProcessor
    @State var generatedImageURL: URL?
    let activityViewController = SwiftUIFileShareActivityViewController()

    var completeActions: some View {
        VStack {
            Button(action: {
                self.activityViewController.shareFiles(fileURLs: [self.generatedImageURL])
            }) {
                ZStack {
                    Text("Share")
                    self.activityViewController
                }
            }.frame(width: 60, height: 60)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5.0) {
            HStack {
                Text("File Details")
                    .font(.title)
                Spacer()
            }
            .padding([.bottom], 10)
            
            Text(self.processor.fileDetails)
            
            if self.processor.combinedImage != nil {
                Text(self.processor.progress)
                Image(self.processor.combinedImage!.cgImage!, scale: CGFloat(2.0), label: Text("Stacked Image"))
                    .resizable()
                    .aspectRatio(CGFloat(self.processor.combinedImage!.size.width) / CGFloat(self.processor.combinedImage!.size.height), contentMode: .fit)
            } else {
                Button(action: {
                    self.processor.analyzeVideo(requestedDurationToAnalyze: 300.0) { generatedImageURL in
                        self.generatedImageURL = generatedImageURL
                    }
                }) {
                    HStack {
                        Spacer()
                        Text("Analyze 5 min").foregroundColor(.white)
                        Spacer()
                    }
                }
                .boldRoundedBackground(with: .blue)
                .padding()
                
                Button(action: {
                    self.processor.analyzeVideo(completion: { generatedImageURL in
                        self.generatedImageURL = generatedImageURL
                    })
                }) {
                    HStack {
                        Spacer()
                        Text("Analyze Full")
                        Spacer()
                    }
                }.padding()
            }
            
            if self.generatedImageURL != nil {
                self.completeActions
            }
        }
    }
}
