//
//  Resource.swift
//  StarHero
//
//  Created by Bryan Van Zile on 7/3/19.
//  Copyright © 2019 Bryan Van Zile. All rights reserved.
//

import Foundation
import SpriteKit

class Resource: MovingObject {
    // The resource sprite
    private let resourceNode = SKSpriteNode(imageNamed: Config.ResourceLocation)
    
    // Initialize the missile
    init(position: Vector? = nil, heading: Vector? = nil, speed: CGFloat = Config.ResourceMaxSpeed) {
        // Call the moving object and base class initializer
        super.init(position: position, heading: heading, team: Config.Team.NoTeam)
        
        // Overwrite with config velocity for an asteroid
        mass = Config.ResourceMass
        maxSpeed = speed
        takeoffSpeed = Config.ResourceTakeoffSpeed
        maxForce = Config.ResourceMaxForce
        deceleration = Config.ResourceDeceleration
        
        //Set the team color
        resourceNode.setScale(Config.ResourceScale)
        resourceNode.color = .white
        resourceNode.colorBlendFactor = 1
        resourceNode.zPosition = Config.RenderPriority.GameBottom
        
        // Grab the size of the node
        radius = (resourceNode.size.width + resourceNode.size.height) / 4
        
        // Set the name for this instance and for the sprite node
        name = getUniqueName()
        resourceNode.name = name
        
        attackable = true
        
        // Initialize the physics body used for collision detection
        resourceNode.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        resourceNode.physicsBody?.isDynamic = true
        resourceNode.physicsBody?.affectedByGravity = false
        resourceNode.physicsBody?.categoryBitMask = Config.BitMaskCategory.Resource
        resourceNode.physicsBody?.contactTestBitMask = 0x0
        resourceNode.physicsBody?.collisionBitMask = 0x0
        
        // Setup the rotation action
        let rotation = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 8)
        resourceNode.run(SKAction.repeatForever(rotation))
        
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
        // Check if collected by a mothership
        if let _ = object as? MotherShip {
            // Consumed by the mothership so we get destroyed
            destroy()
        }
    }
    
    override func getNode() -> SKNode {
        return resourceNode
    }
}
