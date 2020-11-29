//
//  Change.swift
//  ARDemoiOS
//
//  Created by Carlos Martin de Arribas on 28/11/2020.
//  Copyright © 2020 Mishra, Neeraj Kumar (US - Bengaluru). All rights reserved.
//

import Foundation

class Change:Codable {
    let propertyChanges: Int
    let valueChanged: String
    let username: String
    
    var bcid: BCMethod?
    
    enum CodingKeys: String, CodingKey {
        case propertyChanges = "type"
        case valueChanged = "value"
        
        case username
    }
    
    init(propertyChanges: Int, valueChanged: String, username: String) {
        self.propertyChanges = propertyChanges
        self.valueChanged = valueChanged
        self.username = username
    }
    
    init(withRawString content: String) {
        // "(1, \'#FF00000\', \'carlos\')"
        
        let newContent = content.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: "\\", with: "").replacingOccurrences(of: "'", with: "").components(separatedBy: ",")
        // Esto quedará [1, #FF00000, carlos]
        
        self.propertyChanges = Int (newContent[0]) ?? 0
        self.valueChanged = newContent[1]
        self.username = newContent[2]
    }
}
