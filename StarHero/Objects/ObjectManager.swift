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
    private var objects: [String: BaseObject] = [String: BaseObject]()
    
    // Initializer
    private init() {
        // Setting up 2 ships for testing
        let ship1 = FighterShip(position: CGPoint(x: -200, y: 0), heading: 3.0, team: Config.Team.RedTeam)
        let ship2 = FighterShip(position: CGPoint(x: 200, y: 0), heading: 5.0, team: Config.Team.BlueTeam)
        
        objects[ship1.getName()] = ship1
        objects[ship2.getName()] = ship2
    }
    
    // Setup the scene with objects
    func setup() -> [SKNode] {
        var nodes: [SKNode] = [SKNode]()
        
        for (_, object) in objects {
            if let n = object.addToScene() {
                nodes.append(n)
            }
        }
        
        return nodes
    }
    
    // Update all of the active objects
    func update() {
        // Called before each frame is rendered
        for (key, object) in objects {
            if !object.update() {
                // Destory the ship
                self.removeObject(inName: key)
            }
        }
        
        // Debug
        if(objects.isEmpty) {
            print("No game objects")
        }
    }
    
    // Delete the passed through object
    func removeObject(inName: String) {
        if let object = objects[inName] {
            object.destroy()
            objects.removeValue(forKey: inName)
        }
    }
}
