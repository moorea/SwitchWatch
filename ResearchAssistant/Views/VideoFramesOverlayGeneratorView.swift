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
    @State var processor: VideoFrameOverlayProcessor? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 5.0) {
                
                if self.videoURL == nil {
                    VideoPickerButton { videoURL in
                        self.videoURL = videoURL
                        self.processor = VideoFrameOverlayProcessor(videoFileURL: videoURL)
                    }
                    .padding([.top], 10)
                } else {
                    StackProgressView(processor: processor!)
                }
                Spacer()
            }
        }
        .onDisappear {
            self.videoURL = nil
            self.processor?.cancelVideoAnalysis()
        }
        
        .padding()
        .navigationBarTitle("Frame Overlayer", displayMode: .inline)
    }
}

struct StackProgressView: View {
    @ObservedObject var processor: VideoFrameOverlayProcessor
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
            VStack (alignment: .leading) {
                HStack (spacing: 0) {
                    Image(systemName: "folder")
                        .resizable()
                        .frame(width: 20.0 , height: 15.0)
                        .foregroundColor(.gray)
                        .padding([.trailing], 8)
                    Text("File Details")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Spacer()
                }
                .padding([.leading, .top], 16)
                .padding([.bottom], 8)
                
                Text(self.processor.fileDetails)
                    .font(.caption)
                    .padding([.leading, .trailing], 16)
            }
            .background(Rectangle()
                .foregroundColor(Color.tileBackground)
                .cornerRadius(10.0))
            
            
            if self.processor.combinedImage != nil {
                Text(self.processor.progress)
                
                if !self.processor.cancellingPendingGeneratedImages {
                    Button(action: {
                        self.processor.cancelVideoAnalysis()
                    }) {
                        Text("Cancel")
                    }
                }
                
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
