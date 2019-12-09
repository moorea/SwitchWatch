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

    private var hasSelectedVideo: Bool {
        videoURL != nil
    }
    private var videoPickerButton: some View {
        VideoPickerButton { videoURL in
            self.videoURL = videoURL
            self.processor = VideoFrameOverlayProcessor(videoFileURL: videoURL)
        }
        .padding([.top], 10)
    }
    
    var body: some View {
        ScrollView (showsIndicators: false) {
            VStack(alignment: .leading, spacing: 5.0) {
                if !hasSelectedVideo {
                    videoPickerButton
                } else {
                    StackProgressView(processor: processor!, videoURL: self.$videoURL)
                }
                Spacer()
            }
        }
        .onDisappear {
            self.videoURL = nil
            self.processor?.analysisState = .cancelled
        }
        .padding()
        .navigationBarTitle("Frame Overlayer", displayMode: .inline)
    }
}

struct StackProgressView: View {
    @ObservedObject var processor: VideoFrameOverlayProcessor
    @Binding var videoURL: URL?
    
    let activityViewController = SwiftUIFileShareActivityViewController()
    
    var completeActions: some View {
        VStack {
            Button(action: {
                self.activityViewController.shareFiles(fileURLs: [self.processor.saveCombinedImageToFile(named: "MyImagezzz")])
            }) {
                ZStack {
                    HStack{
                        Spacer()
                        Image(systemName: "square.and.arrow.up").foregroundColor(.white)
                        Text("Share").foregroundColor(.white)
                        Spacer()
                    }
                    
                    self.activityViewController
                }
            }
            .boldRoundedBackground(with: .blue)
            .padding([.leading, .trailing], 16)
            
            Button(action: {
                self.processor.analysisState = .cancelled
                self.videoURL = nil
            }) {
                Text("Start Over")
            }.padding([.top, .bottom], 16)
        }
    }
    
    private var fileDetailsCard: some View {
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
            
            Text(self.processor.fileDetails ?? "")
                .font(.caption)
                .padding([.leading, .trailing], 16)
        }
        .background(Rectangle()
        .foregroundColor(Color.tileBackground)
        .cornerRadius(10.0))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5.0) {
            fileDetailsCard
            VStack (alignment: .leading) {
                if self.processor.combinedImage != nil {
                    
                    Image(self.processor.combinedImage!.cgImage!, scale: CGFloat(2.0), label: Text("Stacked Image"))
                        .resizable()
                        .aspectRatio(CGFloat(self.processor.combinedImage!.size.width) / CGFloat(self.processor.combinedImage!.size.height), contentMode: .fit)
                        .cornerRadius(10.0)
                        .padding([.leading, .trailing, .top], 16)

                    if !self.processor.analysisState.hasStoppedRunning {
                        ProgressBar(value: self.$processor.progress, maxValue: 1.0)
                            .frame(height: 10.0)
                            .padding([.leading, .trailing], 16)
                            .animation(.easeInOut)
                    }
                    
                    if !self.processor.analysisState.hasStoppedRunning {
                        Button(action: {
                            self.processor.analysisState = .cancelled
                        }) {
                            HStack {
                                Spacer()
                                Text("Cancel").foregroundColor(.white)
                                Spacer()
                            }
                        }
                        .boldRoundedBackground(with: .red)
                        .padding([.leading, .trailing, .bottom], 16)
                    }
                } else {
                    if self.processor.firstFrame != nil {
                        Image(self.processor.firstFrame!.cgImage!, scale: CGFloat(2.0), label: Text(""))
                            .resizable()
                            .aspectRatio(CGFloat(self.processor.firstFrame!.size.width) / CGFloat(self.processor.firstFrame!.size.height), contentMode: .fit)
                            .cornerRadius(10.0)
                            .padding([.leading, .trailing, .top], 16)
                    }
                        
                    Button(action: {
                        self.processor.analyzeVideo(requestedDurationToAnalyze: 300.0)
                    }) {
                        HStack {
                            Spacer()
                            Text("Analyze 5 min").foregroundColor(.white)
                            Spacer()
                        }
                    }
                    .boldRoundedBackground(with: .blue)
                    .padding([.leading, .trailing], 16)

                    
                    Button(action: {
                        self.processor.analyzeVideo()
                    }) {
                        HStack {
                            Spacer()
                            Text("Analyze Full")
                            Spacer()
                        }
                    }.padding()
                }
                
                if self.processor.analysisState.hasStoppedRunning {
                    self.completeActions
                }
            }
            .background(Rectangle()
            .foregroundColor(Color.tileBackground)
            .cornerRadius(10.0))
        }
    }
}
