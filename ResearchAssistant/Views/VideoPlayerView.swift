//
//  VideoPlayerView.swift
//  VideoPlayer
//
//  Created by Gesen on 2019/7/7.
//  Copyright © 2019 Gesen. All rights reserved.
//

import SwiftUI

@available(iOS 13, *)
public struct VideoPlayerView: UIViewRepresentable {
    
    public enum State {
        
        /// None
        case none
        
        /// From the first load to get the first frame of the video
        case loading
        
        /// Playing now
        case playing
        
        /// Pause, will be called repeatedly when the buffer progress changes
        case paused(reason: PausedReason, playProgress: Double, bufferProgress: Double)
        
        /// An error occurred and cannot continue playing
        case error(NSError)
    }
    
    public enum PausedReason {
        
        /// Pause because the player is not visible, playStateDidChanged is not called when the buffer progress changes
        case disappear
        
        /// Pause triggered by user interaction, default behavior
        case userInteraction
        
        /// Waiting for resource completion buffering
        case waitingKeepUp
    }
    
    @Binding private(set) var url: URL
    @Binding private var isPlay: Bool
    @Binding private var isAutoReplay: Bool
    @Binding private var isMute: Bool
    
    private var playToEndTime: (() -> Void)?
    private var replay: (() -> Void)?
    private var stateDidChanged: ((State) -> Void)?
    
    public init(url: Binding<URL>, isPlay: Binding<Bool>) {
        _url = url
        _isPlay = isPlay
        _isAutoReplay = .constant(true)
        _isMute = .constant(false)
    }
    
    /// Whether the video will be automatically replayed until the end of the video playback.
    public func autoReplay(_ isAutoReplay: Binding<Bool>) -> Self {
        var view = self
        view._isAutoReplay = isAutoReplay
        return view
    }
    
    /// Whether the video is muted, only for this instance.
    public func mute(_ isMute: Binding<Bool>) -> Self {
        var view = self
        view._isMute = isMute
        return view
    }
    
    public func onPlayToEndTime(_ handler: @escaping () -> Void) -> Self {
        var view = self
        view.playToEndTime = handler
        return view
    }
    
    /// Replay after playing to the end.
    public func onReplay(_ handler: @escaping () -> Void) -> Self {
        var view = self
        view.replay = handler
        return view
    }
    
    /// Playback status changes, such as from play to pause.
    public func onStateChanged(_ handler: @escaping (State) -> Void) -> Self {
        var view = self
        view.stateDidChanged = handler
        return view
    }
    
    public func makeUIView(context: Context) -> UIVideoPlayerView {
        let uiView = UIVideoPlayerView()
        uiView.playToEndTime = { context.coordinator.playToEndTime() }
        uiView.replay = { context.coordinator.replay() }
        uiView.stateDidChanged = { context.coordinator.stateDidChanged($0) }
        return uiView
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public func updateUIView(_ uiView: UIVideoPlayerView, context: Context) {
        isPlay ? uiView.play(for: url) : uiView.pause(reason: .userInteraction)
        uiView.isMuted = isMute
        uiView.isAutoReplay = isAutoReplay
    }
    
    public class Coordinator: NSObject {
        var playerView: VideoPlayerView
        
        init(_ videoPlayerView: VideoPlayerView) {
            self.playerView = videoPlayerView
        }
        
        func playToEndTime() {
            if playerView.isAutoReplay == false { playerView.isPlay = false }
            DispatchQueue.main.async { [weak self] in self?.playerView.playToEndTime?() }
        }
        
        func replay() {
            DispatchQueue.main.async { [weak self] in self?.playerView.replay?() }
        }
        
        func stateDidChanged(_ state: State) {
            DispatchQueue.main.async { [weak self] in self?.playerView.stateDidChanged?(state) }
        }
    }
}
