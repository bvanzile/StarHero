//
//  MovingObject.swift
//  StarHero
//
//  Created by Bryan Van Zile on 5/17/19.
//  Copyright © 2019 Bryan Van Zile. All rights reserved.
//

import Foundation
import SpriteKit

class MovingObject: BaseObject {
    
    // Things an object needs to move around
    internal var velocity: CGFloat = 0.0
    
    // Initializer
    override init() {
        super.init()
    }
    
    // Add this object to the scene, must be called by subclass
    override func addToScene() -> SKNode? {
        print("MovingObject addToScene - shouldn't see this")
        return nil
    }
    
    // Update function
    override func update() -> Bool {
        return super.update()
    }
    
    // Get a unique name for the object, this version should be overwritten
    override func getUniqueName() -> String {
        return ""
    }
}
