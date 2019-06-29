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
    private var extraNodes: [SKNode] = [SKNode]()
    
    // A queue to manage contact physics from the game scene
    private var newContactQueue = [SKPhysicsContact]()
    private var endedContactQueue = [SKPhysicsContact]()
    
    // The game scene camera
    var gameCamera: Camera = Camera()
    
    // Determines if the game field is frozen
    var scenePaused: Bool = false
    
    // An object that is currently being updated in some way
    var activeObject: BaseObject?
    
    // Initializer
    private init() {
    }
    
    // Setup the scene with objects
    func setup(scene: GameScene) {
        self.gameScene = scene
        gameScene!.camera = gameCamera.getNode()
        gameScene!.addChild(gameCamera.getNode())
        
        // Only add background image to devices since it lags the emulator currently
        #if !targetEnvironment(simulator)
            let background = SKSpriteNode(imageNamed: "Background")
            background.zPosition = Config.RenderPriority.GameBackground
            gameScene?.addChild(background)
        
        #endif
    }
    
    // Setup a game from scratch
    func newGame() {
        let redShip = MotherShip(position: Vector(x: 0, y: -Config.FieldHeight * 3 / 8), heading: Vector(degrees: 90.0), team: Config.Team.RedTeam, userControlled: true)
        let blueShip = MotherShip(position: Vector(x: 0, y: Config.FieldHeight * 3 / 8), heading: Vector(degrees: 270.0), team: Config.Team.BlueTeam)
        
        objects[redShip.name!] = redShip
        objects[blueShip.name!] = blueShip
        
        for (_, object) in objects {
            if let n = object.addToScene() {
                gameScene?.addChild(n)
            }
        }
        
    }
    
    // Completely tear down the existing game
    func teardown() {
        for (name, _) in objects {
            removeObject(name)
        }
        
        print("Game torn down: \(objects.count) objects remain")
    }
    
    // Update all of the active objects
    func update(currentTime: TimeInterval) {
        let timeDelta = lastTime == 0 ? 0.01 : currentTime - lastTime
        lastTime = currentTime
        
        if !scenePaused {
            // Handle all of the contacts picked up by the game scene
            self.processContacts()
            
            // Called before each frame is rendered
            for (key, object) in objects {
                if !object.update(dTime: timeDelta) {
                    // Remove and destroy the object if false is returned from the update function
                    removeObject(key)
                }
            }
            
            // Remove extra nodes that no longer exist, have to do our own cleanup
            extraNodes.removeAll(where: {$0.parent == nil})
        }
        
        // Update the game camera
        gameCamera.update(time: timeDelta)
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
    
    // Callback for any function to use to add a node to the game scene, the object is responsible for removing when necessary!
    @discardableResult
    func addNode(node: SKNode) -> Bool {
        extraNodes.append(node)
        gameScene?.addChild(node)
        return true
    }
    
    // Delete the passed through object
    func removeObject(_ name: String) {
        if let object = objects[name] {
            // Triggers the delete method
            object.destroy()
            
            // Remove from the list of active game objects
            objects.removeValue(forKey: name)
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
            var validTouchMade: Bool = false
            if !touchedNodes.isEmpty {
                for name in touchedNodes {
                    // Take action if the pause button was pressed
                    if(name == "pauseButton") {
//                        teardown()
//                        newGame()
                        if scenePaused {
                            unpause()
                        }
                        else {
                            pause()
                        }
                        
                        validTouchMade = true
                    }
                    else {
                        if !scenePaused {
                            if let returnValue = objects[name]?.inputTouchDown(touchPos: pos) {
                                if returnValue {
                                    validTouchMade = true
                                }
                            }
                        }
                    }
                }
            }
            
            // Move the camera around if no other valid inputs were made
            if !validTouchMade {
                gameCamera.startMoving(pos)
            }
            break
            
        // Touch was stopped at pos
        case Config.TouchUp:
//            if !touchedNodes.isEmpty {
//                for name in touchedNodes {
//                    if !scenePaused {
//                        if let _ = objects[name]?.inputTouchUp(touchPos: pos) {
//                        }
//                    }
//                }
//            }
            
            // Update the active object if one exists
            if let object = activeObject {
                let _ = object.inputTouchUp(touchPos: pos)
            }
            
            gameCamera.stopMoving()
            break
            
        // Touch is moving, currently at pos
        case Config.TouchMoved:
            // Update the active object if one exists
            if let object = activeObject {
                let _ = object.inputTouchMoved(touchPos: pos)
            }
            
            gameCamera.movingInput(pos)
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
            //print("\(firstNodeName) sees \(secondNodeName)")
            
            // Check if an object was seen or if objects collided
            if firstNodeName.contains(".Sight") || secondNodeName.contains(".Sight") {
                var nameWhoSaw: String, otherName: String
                
                // Capture the name of the object that has sight of something
                if firstNodeName.contains(".Sight") {
                    nameWhoSaw = firstNodeName.components(separatedBy: ".")[0]
                    otherName = secondNodeName.components(separatedBy: ".")[0]
                }
                else {
                    nameWhoSaw = secondNodeName.components(separatedBy: ".")[0]
                    otherName = firstNodeName.components(separatedBy: ".")[0]
                }
                
                
                // Ignore that the object was seen since it was created by them
                if nameWhoSaw == otherName.components(separatedBy: ".")[0] {
                    return
                }
                
                //print("\(nameWhoSaw) sees \(secondNodeName)")
                objects[nameWhoSaw]?.seeObject(objects[otherName])
            }
            else if firstNodeName.contains(".Peripheral") || secondNodeName.contains(".Peripheral") {
                var nameWhoSaw: String, otherName: String
                
                // Capture the name of the object that has sight of something
                if firstNodeName.contains(".Peripheral") {
                    nameWhoSaw = firstNodeName.components(separatedBy: ".")[0]
                    otherName = secondNodeName.components(separatedBy: ".")[0]
                }
                else {
                    nameWhoSaw = secondNodeName.components(separatedBy: ".")[0]
                    otherName = firstNodeName.components(separatedBy: ".")[0]
                }
                
                
                // Ignore that the object was seen since it was created by them
                if nameWhoSaw == otherName.components(separatedBy: ".")[0] {
                    return
                }
                
                //print("\(nameWhoSaw) is close to \(otherName)")
                objects[nameWhoSaw]?.objectInPeripheralRange(objects[otherName])
            }
            else {
                // Handle the collision between two physical objects
                objects[firstNodeName.components(separatedBy: ".")[0]]?.handleCollision(objects[secondNodeName.components(separatedBy: ".")[0]])
                objects[secondNodeName.components(separatedBy: ".")[0]]?.handleCollision(objects[firstNodeName.components(separatedBy: ".")[0]])
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
            if firstNodeName.contains(".Sight") || secondNodeName.contains(".Sight") {
                var nameWhoSaw: String, otherName: String
                
                // Capture the name of the object that has sight of something
                if firstNodeName.contains(".Sight") {
                    nameWhoSaw = firstNodeName.components(separatedBy: ".")[0]
                    otherName = secondNodeName.components(separatedBy: ".")[0]
                }
                else {
                    nameWhoSaw = secondNodeName.components(separatedBy: ".")[0]
                    otherName = firstNodeName.components(separatedBy: ".")[0]
                }
                
                
                // Ignore that the object was seen since it was created by them
                if nameWhoSaw == otherName.components(separatedBy: ".")[0] {
                    return
                }

                //print("\(nameWhoSaw) has lost sight of \(secondNodeName)")
                objects[nameWhoSaw]?.loseSightOnObject(objects[otherName])
            }
            else if firstNodeName.contains(".Peripheral") || secondNodeName.contains(".Peripheral") {
                var nameWhoSaw: String, otherName: String
                
                // Capture the name of the object that has sight of something
                if firstNodeName.contains(".Peripheral") {
                    nameWhoSaw = firstNodeName.components(separatedBy: ".")[0]
                    otherName = secondNodeName.components(separatedBy: ".")[0]
                }
                else {
                    nameWhoSaw = secondNodeName.components(separatedBy: ".")[0]
                    otherName = firstNodeName.components(separatedBy: ".")[0]
                }
                
                
                // Ignore that the object was seen since it was created by them
                if nameWhoSaw == otherName.components(separatedBy: ".")[0] {
                    return
                }
                
                //print("\(nameWhoSaw) moved away from \(otherName)")
                objects[nameWhoSaw]?.objectOutOfPeripheralRange(objects[otherName])
            }
            else {
                // Handle the collision ending between two physical objects
                objects[firstNodeName.components(separatedBy: ".")[0]]?.handleStopColliding(objects[secondNodeName.components(separatedBy: ".")[0]])
                objects[secondNodeName.components(separatedBy: ".")[0]]?.handleStopColliding(objects[firstNodeName.components(separatedBy: ".")[0]])
                //print("\(firstNodeName) has ended collision with \(secondNodeName)")
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
    
    // Pause the scene
    func pause() {
        scenePaused = true
        for (_, object) in objects {
            object.getNode().isPaused = true
        }
        for node in extraNodes {
            node.isPaused = true
        }
    }
    
    // Unpause the scene
    func unpause() {
        scenePaused = false
        for (_, object) in objects {
            object.getNode().isPaused = false
        }
        for node in extraNodes {
            node.isPaused = false
        }
    }
}
