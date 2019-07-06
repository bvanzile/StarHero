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
    private var asteroidSpawnTimer: Double = 0.0
    
    // A queue to manage contact physics from the game scene
    private var newContactQueue = [SKPhysicsContact]()
    private var endedContactQueue = [SKPhysicsContact]()
    
    // The game scene camera
    var camera: Camera = Camera()
    
    // Background
    var background: Background?
    
    // Determines if the game field is frozen
    var scenePaused: Bool = false
    
    // An object that is currently being updated in some way through touch controls
    var activeObject: BaseObject?
    
    // For storing touch length
    var touchStarted: Date?
    
    // Initializer
    private init() {
    }
    
    // Setup the scene with objects
    func setup(scene: GameScene) {
        self.gameScene = scene
        gameScene!.camera = camera.getNode()
        gameScene!.addChild(camera.getNode())
        
        // Only add background image to devices since it lags the emulator currently
        #if !targetEnvironment(simulator)
            // Setup the background images
            background = Background(scene: gameScene!, fieldWidth: Config.MaxFieldWidth * 1.1, fieldHeight: Config.MaxFieldHeight * 1.3)
            camera.background = background
            camera.optimizeBackground()
//            let background = SKSpriteNode(imageNamed: "Background")
//            background.zPosition = Config.RenderPriority.GameBackground
//            gameScene?.addChild(background)
        #endif
        
        
    }
    
    // Setup a game from scratch
    func newGame() {
        let minW = Config.MaxFieldWidth * 0.5
        let minH = Config.MaxFieldHeight * 0.5
        
        // Player controlled ship
        addObject(object: MotherShip(position: Vector(x: 0, y: 0), heading: Vector(degrees: 90.0), team: Config.Team.RedTeam, userControlled: true))
        
        // Computer teams
        addObject(object: MotherShip(position: Vector(x: CGFloat.random(in: -(minW * 0.9)...(minW * 0.9)), y: CGFloat.random(in: -(minH * 0.9)...(minH * 0.9))), team: Config.Team.BlueTeam))
        addObject(object: MotherShip(position: Vector(x: CGFloat.random(in: -(minW * 0.9)...(minW * 0.9)), y: CGFloat.random(in: -(minH * 0.9)...(minH * 0.9))), team: Config.Team.OrangeTeam))
        addObject(object: MotherShip(position: Vector(x: CGFloat.random(in: -(minW * 0.9)...(minW * 0.9)), y: CGFloat.random(in: -(minH * 0.9)...(minH * 0.9))), team: Config.Team.GreenTeam))
        //addObject(object: MotherShip(position: Vector(x: CGFloat.random(in: -(minW * 0.9)...(minW * 0.9)), y: CGFloat.random(in: -(minH * 0.9)...(minH * 0.9))), team: Config.Team.RedTeam))
        
        for _ in 0...50 {
            addObject(object: Asteroid(position: Vector(x: CGFloat.random(in: -minW...minW), y: CGFloat.random(in: -minH...minH)), heading: Vector(degrees: CGFloat.random(in: 0...360)), speed: CGFloat.random(in: 30...120)))
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
            
            // Spawn random asteroids
            asteroidSpawnTimer += timeDelta
            if asteroidSpawnTimer > 1.0 {
                asteroidSpawnTimer -= 1.0
                
                addObject(object: Asteroid(position: Vector(x: CGFloat.random(in: -(Config.MaxFieldWidth * 0.5)...(Config.MaxFieldWidth * 0.5)), y: CGFloat.random(in: -(Config.MaxFieldHeight * 0.5)...(Config.MaxFieldHeight * 0.5))), heading: Vector(degrees: CGFloat.random(in: 0...360)), speed: CGFloat.random(in: 30...120)))
            }
            
            // Remove extra nodes that no longer exist, have to do our own cleanup
            extraNodes.removeAll(where: {$0.parent == nil})
        }
        
        // Update the game camera
        camera.update(time: timeDelta)
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
    
    // Start the scaling for the camera
    func startCameraScale() {
        camera.startScale()
    }
    
    // Handles zoom from the pinch gesture
    func scaleCamera(scale: CGFloat) {
        camera.setScale(scale)
    }
    
    // Called when the screen is touched
    func screenTouched(pos: CGPoint, touchType: Int, touchedNodes: [String] = [String]()) {
        for name in touchedNodes {
            print(name)
        }
        
        // Iterate through objects with touch input (TODO: change team hierarchy when more is implemented)
        switch touchType {
            
        // Screen was touched down at pos
        case Config.TouchDown:
            // Start the touch started timer
            touchStarted = Date()
            
            // Get the closest valid object to touch if it exists
            if let closest = getClosestTouchObject(pos: pos, nodes: touchedNodes) {
                // Take action if the pause button was pressed
                if closest == "pauseButton" && activeObject == nil {
//                    if scenePaused {
//                        unpause()
//                    }
//                    else {
//                        pause()
//                    }
                    teardown()
                    newGame()
                }
                else if closest.contains(".Touch") {
                    if !scenePaused {
                        let _ = objects[closest.components(separatedBy: ".")[0]]?.inputTouchDown(touchPos: pos)
                    }
                }
            }
            // Move the camera around if no other valid inputs were made
            else {
                camera.startMoving(pos)
            }
            break
            
        // Touch was stopped at pos
        case Config.TouchUp:
            // Update the active object if one exists
            if let elapsedTimeSinceTouch = touchStarted?.timeIntervalSinceNow {
                // Check for if something was tapped down on initially
                if let object = activeObject {
                    // Check if it was tapped
                    if elapsedTimeSinceTouch > -0.2 {
                        if let closest = getClosestTouchObject(pos: pos, nodes: touchedNodes) {
                            if closest.contains(".Button.") {
                                let _ = object.buttonTouched(name: closest.components(separatedBy: ".")[2])
                            }
                        }
                        
                        let _ = object.inputTapped(touchPos: pos)
                    }
                    else {
                        let _ = object.inputTouchUp(touchPos: pos)
                    }
                }
                // Check if there was a tap on the screen
                else if elapsedTimeSinceTouch > -0.2 {
//                    let asteroid = Asteroid(position: Vector(pos), heading: Vector(degrees: CGFloat.random(in: 0...360)), speed: CGFloat.random(in: 10...80))
//                    addObject(object: asteroid)
                }
            }
            
            camera.stopMoving()
            touchStarted = nil
            break
            
        // Touch is moving, currently at pos
        case Config.TouchMoved:
            // Update the active object if one exists
            if let object = activeObject {
                let _ = object.inputTouchMoved(touchPos: pos)
            }
            
            camera.movingInput(pos)
            break
            
        default:
            // Do nothing
            print("No input type, shouldn't be called")
            break
        }
    }
    
    // Get the closest user controlled object to the touch position, prioritizing motherships
    func getClosestTouchObject(pos: CGPoint, nodes: [String]) -> String? {
        // Check if a node was touched and give it the action
        var closestObject: String?
        
        if !nodes.isEmpty {
            for name in nodes {
                // Take action if the pause button was pressed
                if name == "pauseButton" {
                    return name
                }
                else if name.contains(".Button.") {
                    // Prioritize a button press since it's in front
                    return name
                }
                else {
                    // Iterate through the touch nodes to determine the closest one  myNode.components(separatedBy: ".")[0]
                    if name.contains(".Touch") {
                        let nodeName = name.components(separatedBy: ".")[0]
                        
                        if let object = objects[nodeName] {
                            if object.userControlled {
                                // Prioritize a user controlled mothership
                                if nodeName.contains("MotherShip") {
                                    return name
                                }
                                
                                if closestObject == nil {
                                    closestObject = name
                                }
                                else {
                                    if object.position.distanceBetween(vector: Vector(pos)) < objects[closestObject!.components(separatedBy: ".")[0]]!.position.distanceBetween(vector: Vector(pos)) {
                                        closestObject = name
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return closestObject
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
