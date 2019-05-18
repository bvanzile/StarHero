//
//  BaseObject.swift
//  StarHero
//
//  Created by Bryan Van Zile on 5/17/19.
//  Copyright © 2019 Bryan Van Zile. All rights reserved.
//

import Foundation
import SpriteKit

class BaseObject {

    // State of the object
    var isActive: Bool = false
    
    // Default initializer
    init() {
        
    }
    
    // Add this object to the scene, must be called by subclass
    func addToScene() -> SKNode? {
        print("BaseObject addToScene - shouldn't see this")
        return nil
    }
    
    // Update
    func update() {
        
    }
}
