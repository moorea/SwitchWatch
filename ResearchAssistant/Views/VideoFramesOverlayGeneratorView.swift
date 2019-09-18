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
        VStack {
            VideoPickerButton { videoURL in
                self.videoURL = videoURL
            }
            
            if self.videoURL != nil {
                StackProgressView().environmentObject(VideoFrameOverlayProcessor(videoFileURL: self.videoURL!))
            }
        }
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
        VStack {
            Text(processor.fileDetails)
            
            if processor.combinedImage != nil {
                Image(processor.combinedImage!.cgImage!, scale: CGFloat(2.0), label: Text("Stacked Image"))
            }

            Button(action: {
                self.processor.analyzeVideo(completion: { generatedImageURL in
                    self.generatedImageURL = generatedImageURL
                })
            }) {
                HStack {
                    Text("Analyze")
                }
            }

            if generatedImageURL != nil {
                completeActions
            }
            
        }
    }
}
