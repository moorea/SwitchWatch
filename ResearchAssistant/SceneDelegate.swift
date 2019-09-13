//
//  SceneDelegate.swift
//  ResearchAssistant
//
//  Created by Andrew Moore on 8/9/19.
//  Copyright © 2019 Andrew Moore. All rights reserved.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = scene as? UIWindowScene else {
            return
        }
            
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = UIHostingController(rootView: HomeView())
        window?.makeKeyAndVisible()
    }
}
