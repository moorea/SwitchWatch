//
//  VideoFramesOverlayGeneratorView.swift
//  ResearchAssistant
//
//  Created by Moore, Andrew on 9/13/19.
//  Copyright © 2019 Andrew Moore. All rights reserved.
//

import SwiftUI

struct VideoFramesOverlayGeneratorView: View {
    
    @State var processor: VideoFrameOverlayProcessor?
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
            VideoPickerButton { videoURL in
                self.processor = VideoFrameOverlayProcessor(videoFileURL: videoURL)
            }
            
            Text(processor?.fileDetails ?? "")
            Button(action: {
                self.processor?.analyzeVideo(completion: { generatedImageURL in
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

struct VideoFramesOverlayGeneratorView_Previews: PreviewProvider {
    static var previews: some View {
        VideoFramesOverlayGeneratorView()
    }
}
