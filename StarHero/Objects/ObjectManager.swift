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
    // Time when the update function was last called
    private var lastTime: TimeInterval = 0
    
    // Object management singleton
    static let sharedInstance = ObjectManager()
    
    // All game objects
    private var objects: [String: BaseObject] = [String: BaseObject]()
    
    // Initializer
    private init() {
        // Setting up 2 ships for testing
        let ship1 = FighterShip(position: CGPoint(x: -200, y: 200), facingDegrees: 135.0, team: Config.Team.RedTeam)
        let ship2 = FighterShip(position: CGPoint(x: 200, y: 200), facingDegrees: 315.0, team: Config.Team.BlueTeam)
        let ship3 = FighterShip(position: CGPoint(x: -200, y: -200), facingDegrees: 135.0, team: Config.Team.OrangeTeam)
        let ship4 = FighterShip(position: CGPoint(x: 200, y: -200), facingDegrees: 315.0, team: Config.Team.GreenTeam)
        
        objects[ship1.name!] = ship1
        objects[ship2.name!] = ship2
        objects[ship3.name!] = ship3
        objects[ship4.name!] = ship4
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
    func update(currentTime: TimeInterval) {
        let timeDelta = lastTime == 0 ? 0.01 : currentTime - lastTime
        lastTime = currentTime
        
        // Called before each frame is rendered
        for (key, object) in objects {
            if !object.update(dTime: timeDelta) {
                // Destory the ship
                self.removeObject(inName: key)
            }
        }
    }
    
    // Delete the passed through object
    func removeObject(inName: String) {
        if let object = objects[inName] {
            // Triggers the delete method
            object.isActive = false
            
            // Remove from the list of active game objects
            objects.removeValue(forKey: inName)
        }
    }
    
    // Let a specific object know it has been touched
    func objectTouched(objectName: String) {
        if let _ = objects[objectName] {
            // Probably used at some point
        }
    }
    
    // Called when the screen is touched
    func screenTouched(pos: CGPoint, touchType: Int, touchedNodes: [String] = [String]()) {
        // Iterate through objects with touch input (TODO: change team hierarchy when more is implemented)
        switch touchType {
            
        // Screen was touched down at pos
        case Config.TouchDown:
            // Check if a node was touched and give it the action
            if !touchedNodes.isEmpty {
                // Currently, delete any objects that were touched
                for name in touchedNodes {
                    objects[name]?.isActive = false
                }
            }
            else {
                // Update all of the game nodes with the input
                for (_, object) in objects {
                    object.inputTouchDown(touchPos: pos)
                }
            }
            break
            
        // Touch was stopped at pos
        case Config.TouchUp:
            break
            
        // Touch is moving, currently at pos
        case Config.TouchMoved:
            break
            
        default:
            // Do nothing
            print("No input type, shouldn't be called")
            break
        }
    }
}
