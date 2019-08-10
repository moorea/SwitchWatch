//
//  Sharing.swift
//  SwitchWatch
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
    
    func shareFile(fileURL: URL?) {
        activityViewController.fileURL = fileURL
        activityViewController.shareFile()
    }
}

class FileShareActivityViewController : UIViewController {

    var fileURL: URL?

    @objc func shareFile() {
        guard let url = fileURL else {
            return
        }
        let vc = UIActivityViewController(activityItems: [url], applicationActivities: [])
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
