//
//  Sharing.swift
//  ResearchAssistant
//
//  Created by Andrew Moore on 8/9/19.
//  Copyright © 2019 Andrew Moore. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

struct SwiftUIFileShareActivityViewController : UIViewControllerRepresentable {

    var activityViewController = FileShareActivityViewController()

    func makeUIViewController(context: Context) -> FileShareActivityViewController {
        activityViewController
    }
    func updateUIViewController(_ uiViewController: FileShareActivityViewController, context: Context) { }
    
    func shareFiles(fileURLs: [URL?]?) {
        activityViewController.fileURLs = fileURLs
        activityViewController.shareFile()
    }
}

class FileShareActivityViewController : UIViewController {

    var fileURLs: [URL?]?

    @objc func shareFile() {
        guard let urls = fileURLs else {
            return
        }
        let vc = UIActivityViewController(activityItems: urls as [Any], applicationActivities: [])
        vc.excludedActivityTypes =  [
            UIActivity.ActivityType.postToWeibo,
            UIActivity.ActivityType.assignToContact,
            UIActivity.ActivityType.addToReadingList,
            UIActivity.ActivityType.postToVimeo,
            UIActivity.ActivityType.postToTencentWeibo
        ]
        present(vc,
                animated: true,
                completion: nil)
        vc.popoverPresentationController?.sourceView = self.view
    }
}
