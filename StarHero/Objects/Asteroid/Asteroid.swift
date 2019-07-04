//
//  Asteroid.swift
//  StarHero
//
//  Created by Bryan Van Zile on 6/29/19.
//  Copyright © 2019 Bryan Van Zile. All rights reserved.
//

import Foundation
import SpriteKit

class Asteroid: MovingObject {
    // The asteroid sprite
    private let asteroidNode = SKSpriteNode(imageNamed: Config.AsteroidLocation)
    
    // Initialize the missile
    init(position: Vector? = nil, heading: Vector? = nil, speed: CGFloat = Config.AsteroidMaxSpeed) {
        // Call the moving object and base class initializer
        super.init(position: position, heading: heading, team: Config.Team.NoTeam)
        
        // Overwrite with config velocity for an asteroid
        mass = Config.AsteroidMass
        maxSpeed = speed
        takeoffSpeed = Config.AsteroidTakeoffSpeed
        maxForce = Config.AsteroidMaxForce
        deceleration = Config.AsteroidDeceleration
        
        //Set the team color
        asteroidNode.setScale(Config.AsteroidScale)
        asteroidNode.color = .gray
        asteroidNode.colorBlendFactor = 1
        asteroidNode.zPosition = Config.RenderPriority.GameDefault
        
        // Grab the size of the node
        radius = (asteroidNode.size.width + asteroidNode.size.height) / 4
        
        // Set the name for this instance and for the sprite node
        name = getUniqueName()
        asteroidNode.name = name
        
        attackable = true
        
        // Initialize the physics body used for collision detection
        asteroidNode.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        asteroidNode.physicsBody?.isDynamic = true
        asteroidNode.physicsBody?.affectedByGravity = false
        asteroidNode.physicsBody?.categoryBitMask = Config.BitMaskCategory.Asteroid
        asteroidNode.physicsBody?.contactTestBitMask = Config.BitMaskCategory.Asteroid + Config.BitMaskCategory.Missile + Config.BitMaskCategory.FighterShip + Config.BitMaskCategory.MotherShip
        asteroidNode.physicsBody?.collisionBitMask = 0x0
        
        // Setup the rotation action
        let rotation = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: Double.random(in: 2...10))
        asteroidNode.run(SKAction.repeatForever(rotation))
        
        // Set the node's position and heading
        updateNode()
        
        // Setup the missile's steering behavior, go in the direction it was facing when created
        steeringBehavior?.setToGo(direction: self.heading)
        
        //print("Initialized \(self.name!)")
    }
    
    // Update function, return true if update successful, return false if this object is ready to be terminated
    override func update(dTime: TimeInterval) -> Bool {
        // If superclass indicates deletion or the asteroid flew out of bounds, return false
        if(!isActive || self.isOutOfBounds(scale: 1.3)) {
            return false
        }
        
        // Update and draw the object
        updateVelocity(timeElapsed: dTime)
        updatePosition(timeElapsed: dTime)
        updateNode(ignoreHeading: true)
        
        return true
    }
    
    // Handle a collision with an object
    override func handleCollision(_ object: BaseObject?) {
        // Check if hit by a missile
        if let _ = object as? Missile {
            // Create an explosion where the asteroid was destroyed
            ObjectManager.sharedInstance.addObject(object: Explosion(position: self.position, size: self.radius * 2, duration: 0.2, force: heading * self.maxSpeed))
            destroy()
        }
            // Check if collided with a fighter ship
        else if let _ = object as? FighterShip {
            // Create an explosion where the asteroid was destroyed
            ObjectManager.sharedInstance.addObject(object: Explosion(position: self.position, size: self.radius * 2, duration: 0.2, force: heading * self.maxSpeed))
            destroy()
        }
            // Check if collided with a mothership
        else if let _ = object as? MotherShip {
            // Create an explosion where the mothership was hit
            ObjectManager.sharedInstance.addObject(object: Explosion(position: self.position, size: self.radius * 2, duration: 0.2, force: heading * self.maxSpeed))
            destroy()
        }
            // Check if collided with another asteroid
        else if let _ = object as? Asteroid {
            // Create an explosion where the asteroid was destroyed
            ObjectManager.sharedInstance.addObject(object: Explosion(position: self.position, size: self.radius * 2, duration: 0.2, force: heading * self.maxSpeed))
            destroy()
        }
    }
    
    override func destroy() {
        if isActive {
            // Drop a resource
            ObjectManager.sharedInstance.addObject(object: Resource(position: position, heading: heading, speed: maxSpeed / 5))
        }
        
        super.destroy()
    }
    
    override func getNode() -> SKNode {
        return asteroidNode
    }
}
