//
//  ObjectManager.swift
//  StarHero
//
//  Created by Bryan Van Zile on 5/17/19.
//  Copyright © 2019 Bryan Van Zile. All rights reserved.
//

import Foundation
import SpriteKit

class ObjectManager {
    
    // Object management singleton
    static let sharedInstance = ObjectManager()
    
    // All game objects
    private var objects: [BaseObject] = [BaseObject]()
    
    // Initializer
    private init() {
        // Setting up 2 ships for testing
        objects.append(FighterShip(position: CGPoint(x: -200, y: 0)))
        objects.append(FighterShip(position: CGPoint(x: 200, y: 0)))
    }
    
    // Setup the scene with objects
    func setup() -> [SKNode] {
        var nodes: [SKNode] = [SKNode]()
        
        for object in objects {
            if let n = object.addToScene() {
                nodes.append(n)
            }
        }
        
        return nodes
    }
    
    // Update all of the active objects
    func update() {
        for object in objects {
            object.update()
        }
    }
}
