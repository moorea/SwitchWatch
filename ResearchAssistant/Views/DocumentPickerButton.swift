//
//  DocumentPickerButton.swift
//  ResearchAssistant
//
//  Created by Moore, Andrew on 9/13/19.
//  Copyright © 2019 Andrew Moore. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

struct VideoPickerButton: View {
    @State private var isPresented = false
    var didPickVideo: ((URL) -> Void)?
    
    var body: some View {
        Button(action: {
            self.isPresented = true
        }) {
            HStack {
                Image(systemName: "folder").scaledToFit()
                Text("Select a video")
            }
        }.sheet(isPresented: $isPresented) { () -> VideoPickerViewController in
            VideoPickerViewController { selectedFileURL in
                guard let url = selectedFileURL else {
                    return
                }
                self.didPickVideo?(url)
                self.isPresented = false
            }
        }
    }
}

/// Wrapper around the `UIDocumentPickerViewController` for selecting a video file
struct VideoPickerViewController {
    private let supportedTypes = ["public.mpeg-4", "com.apple.quicktime-movie"]

    // Callback to be executed when users close the document picker.
    private let onDismiss: ((URL?) -> Void)?

    init(onDismiss: ((URL?) -> Void)?) {
        self.onDismiss = onDismiss
    }
}

// MARK: - UIViewControllerRepresentable

extension VideoPickerViewController: UIViewControllerRepresentable {

    typealias UIViewControllerType = UIDocumentPickerViewController

    func makeUIViewController(context: Context) -> VideoPickerViewController.UIViewControllerType {
        let documentPickerController = UIDocumentPickerViewController(documentTypes: supportedTypes, in: .import)
        documentPickerController.delegate = context.coordinator
        return documentPickerController
    }

    func updateUIViewController(_ uiViewController: VideoPickerViewController.UIViewControllerType, context: Context) {}

    // MARK: Coordinator

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: VideoPickerViewController

        init(_ documentPickerController: VideoPickerViewController) {
            parent = documentPickerController
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let firstUrl = urls.first else {
                return
            }
            parent.onDismiss?(firstUrl)
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.onDismiss?(nil)
        }
    }
}
