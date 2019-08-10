//
//  ObservationSession.swift
//  SwitchWatch
//
//  Created by Andrew Moore on 8/10/19.
//  Copyright © 2019 Andrew Moore. All rights reserved.
//

import Combine
import Foundation

class ObservationSession: ObservableObject {
    let objectWillChange = ObservableObjectPublisher()
    var groupName: String
    var items: [ObservedItem] = []
    var isRunning: Bool = false
    
    init(groupName: String) {
        self.groupName = groupName
    }
    
    func addItem(name: String) {
        items.append(ObservedItem(name: name))
        objectWillChange.send()
    }
    
    func start() {
        items.forEach { $0.start() }
        isRunning = true
        objectWillChange.send()
    }
    
    func stop() {
        items.forEach { $0.stop() }
        isRunning = false
        objectWillChange.send()
    }
    
    var exportedFilePath: URL?
    
    func export() {
        let fileName = "\(groupName)_times.csv"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        
        var csvText = ""
        items.forEach { item in
            csvText += item.constructCSV()
        }
        
        do {
            try csvText.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
            exportedFilePath = path
        } catch {
            
            print("Failed to create file")
            print("\(error)")
        }
    }
}
