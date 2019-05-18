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
    
    //
    private var velocity: Int = 0
    
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
    override func update() {
        super.update()
    }
}
