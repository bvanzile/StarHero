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
    // Singleton setup
    static let sharedInstance = ObjectManager()
    
    // Time when the update function was last called
    private var lastTime: TimeInterval = 0
    
    // The game scene that owns this object manager
    private var gameScene: GameScene?
    
    // All game objects
    private var objects: [String: BaseObject] = [String: BaseObject]()
    
    // A queue to manage contact physics from the game scene
    private var newContactQueue = [SKPhysicsContact]()
    private var endedContactQueue = [SKPhysicsContact]()
    
    // Initializer
    private init() {
        // Setting up 2 ships for testing
        //let ship1 = FighterShip(position: Vector(x: -Config.FieldWidth / 2.2, y: Config.FieldHeight / 2.3), heading: Vector(degrees: 315.0), team: Config.Team.RedTeam)
        //let ship2 = FighterShip(position: Vector(x: Config.FieldWidth / 2.2, y: Config.FieldHeight / 2.3), heading: Vector(degrees: 225.0), team: Config.Team.BlueTeam)
        //let ship3 = FighterShip(position: Vector(x: -Config.FieldWidth / 2.2, y: -Config.FieldHeight / 2.3), heading: Vector(degrees: 45.0), team: Config.Team.OrangeTeam)
        //let ship4 = FighterShip(position: Vector(x: Config.FieldWidth / 2.2, y: -Config.FieldHeight / 2.3), heading: Vector(degrees: 135.0), team: Config.Team.GreenTeam)
        
        //objects[ship1.name!] = ship1
        //objects[ship2.name!] = ship2
        //objects[ship3.name!] = ship3
        //objects[ship4.name!] = ship4
        
        let redShip = FighterShip(position: Vector(x: 0, y: -Config.FieldHeight * 3 / 8), heading: Vector(degrees: CGFloat.random(in: 45...135)), team: Config.Team.RedTeam)
        let blueShip = FighterShip(position: Vector(x: 0, y: Config.FieldHeight * 3 / 8), heading: Vector(degrees: CGFloat.random(in: 225...315)), team: Config.Team.BlueTeam)
        
        objects[redShip.name!] = redShip
        objects[blueShip.name!] = blueShip
    }
    
    // Setup the scene with objects
    func setup(scene: GameScene) {
        self.gameScene = scene
        
        for (_, object) in objects {
            if let n = object.addToScene() {
                gameScene?.addChild(n)
            }
        }
    }
    
    // Update all of the active objects
    func update(currentTime: TimeInterval) {
        // Handle all of the contacts picked up by the game scene
        self.processContacts()
        
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
    
    // Callback for any function to use to add an object and node to the game scene
    @discardableResult
    func addObject(object: BaseObject) -> Bool {
        if let n = object.addToScene() {
            objects[object.name!] = object
            gameScene?.addChild(n)
        }
        
        return true
    }
    
    // Delete the passed through object
    func removeObject(inName: String) {
        if let object = objects[inName] {
            // Triggers the delete method
            object.destroy()
            
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
                    // Take action if the pause button was pressed
                    if(name == "pauseButton") {
                        //let ship = FighterShip(position: Vector(x: CGFloat.random(in: -Config.FieldWidth/2...Config.FieldWidth/2), y: CGFloat.random(in: -Config.FieldHeight/2...Config.FieldHeight/2)), heading: Vector(degrees: CGFloat.random(in: 0...360)), team: Config.Team.RandomTeam)
                        let redShip = FighterShip(position: Vector(x: 0, y: -Config.FieldHeight * 3 / 8), heading: Vector(degrees: CGFloat.random(in: 45...135)), team: Config.Team.RedTeam)
                        let blueShip = FighterShip(position: Vector(x: 0, y: Config.FieldHeight * 3 / 8), heading: Vector(degrees: CGFloat.random(in: 225...315)), team: Config.Team.BlueTeam)
                        
                        addObject(object: redShip)
                        addObject(object: blueShip)
                    }
                    else {
                        objects[name]?.inputTouchDown(touchPos: pos)
                    }
                }
            }
            else {
                let userMissile = Missile(owner: "User", position: Vector(x: 0, y: 0), heading: Vector(point: pos))
                addObject(object: userMissile)
            }
//            else {
//                // Update all of the game nodes with the input, temporary so they all try to fire a missile
//                for (_, object) in objects {
//                    object.inputTouchDown(touchPos: pos)
//                }
//            }
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
    
    // Process all of the contacts in the queue and perform the necessary interactions
    func handleNewContacts(contact: SKPhysicsContact) {
        // Check if this contact has already been handled or if both nodes still exist
        if contact.bodyA.node?.parent == nil || contact.bodyB.node?.parent == nil {
            return
        }
        
        // Check relationship - child/parents shouldn't be interacting in any kind of way
        if contact.bodyA.node?.parent == contact.bodyB.node || contact.bodyA.node == contact.bodyB.node?.parent {
            return
        }
        
        // Unwrap both node names and make sure they exist
        if let firstNodeName = contact.bodyA.node?.name, let secondNodeName = contact.bodyB.node?.name {
            // Check if an object was seen or if objects collided
            if firstNodeName.contains(".Sight") {
                // Capture the name of the object that has sight of something
                let nameWhoSaw = firstNodeName.components(separatedBy: ".")[0]
                
                // Ignore that the object was seen since it was created by them
                if nameWhoSaw == secondNodeName.components(separatedBy: ".")[0] {
                    return
                }
                
                //print("\(nameWhoSaw) sees \(secondNodeName)")
                objects[nameWhoSaw]?.seeObject(objects[secondNodeName])
            }
            else if secondNodeName.contains(".Sight") {
                // Capture the name of the object that has sight of something
                let nameWhoSaw = secondNodeName.components(separatedBy: ".")[0]
                
                // Ignore that the object was seen since it was created by them
                if nameWhoSaw == firstNodeName.components(separatedBy: ".")[0] {
                    return
                }
                
                //print("\(nameWhoSaw) sees \(firstNodeName)")
                objects[nameWhoSaw]?.seeObject(objects[firstNodeName])
            }
            else {
                // Don't let things collide if they belong to the same object
                if firstNodeName.components(separatedBy: ".")[0] == secondNodeName.components(separatedBy: ".")[0] {
                    return
                }
                
                // Handle the collision between two physical objects
                objects[firstNodeName]?.handleCollision(objects[secondNodeName])
                objects[secondNodeName]?.handleCollision(objects[firstNodeName])
                //print("\(firstNodeName) has collided with \(secondNodeName)")
            }
        }
    }
    
    // Process all of the contacts in the queue and perform the necessary interactions
    func handleEndedContacts(contact: SKPhysicsContact) {
        // Check if this contact has already been handled or if both nodes still exist
        if contact.bodyA.node?.parent == nil || contact.bodyB.node?.parent == nil {
            return
        }

        // Check relationship - child/parents shouldn't be interacting in any kind of way
        if contact.bodyA.node?.parent == contact.bodyB.node || contact.bodyA.node == contact.bodyB.node?.parent {
            return
        }

        // Unwrap both node names and make sure they exist
        if let firstNodeName = contact.bodyA.node?.name, let secondNodeName = contact.bodyB.node?.name {
            // Check if an object was seen or if objects collided
            if firstNodeName.contains(".Sight") {
                // Capture the name of the object that has sight of something
                let nameWhoSaw = firstNodeName.components(separatedBy: ".")[0]

                // Ignore that the object was seen since it was created by them
                if nameWhoSaw == secondNodeName.components(separatedBy: ".")[0] {
                    return
                }

                //print("\(nameWhoSaw) has lost sight of \(secondNodeName)")
                objects[nameWhoSaw]?.loseSightOnObject(objects[secondNodeName])
            }
            else if secondNodeName.contains(".Sight") {
                // Capture the name of the object that has sight of something
                let nameWhoSaw = secondNodeName.components(separatedBy: ".")[0]

                // Ignore that the object was seen since it was created by them
                if nameWhoSaw == firstNodeName.components(separatedBy: ".")[0] {
                    return
                }

                //print("\(nameWhoSaw) has lost sight of \(firstNodeName)")
                objects[nameWhoSaw]?.loseSightOnObject(objects[firstNodeName])
            }
        }
    }
    
    // Iterate through the contacts in the queue and handle them
    func processContacts() {
        // Handle the new contacts
        for contact in newContactQueue {
            handleNewContacts(contact: contact)
            
            if let index = newContactQueue.firstIndex(of: contact) {
                newContactQueue.remove(at: index)
            }
        }
        
        // Handle the contacts that have ended
        for contact in endedContactQueue {
            handleEndedContacts(contact: contact)
            
            if let index = endedContactQueue.firstIndex(of: contact) {
                endedContactQueue.remove(at: index)
            }
        }
    }
    
    // Get a collision from the game scene to process in the update function
    func addNewContactToQueue(contact: SKPhysicsContact) {
        newContactQueue.append(contact)
    }
    
    // Get the ended collisions from the game scene to process in the update function
    func addEndedContactToQueue(contact: SKPhysicsContact) {
        endedContactQueue.append(contact)
    }
}
