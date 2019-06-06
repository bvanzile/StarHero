//
//  Missile.swift
//  StarHero
//
//  Created by Bryan Van Zile on 5/23/19.
//  Copyright © 2019 Bryan Van Zile. All rights reserved.
//

import Foundation
import SpriteKit

class Missile: MovingObject {
    // The missile sprite
    private let missileNode = SKSpriteNode(imageNamed: Config.MissileLocation)
    
    // Name of the ship who fired the missile to make sure it doesn't collide with itself
    var missileOwner: String
    
    // Initialize the missile
    init(owner: String, position: Vector? = nil, heading: Vector? = nil, team: Int = Config.Team.NoTeam) {
        // Make sure we know who fired the missile so it doesn't cause an SD
        self.missileOwner = owner
        
        // Call the moving object and base class initializer
        super.init(position: position, heading: heading, team: team)
        
        // Overwrite with config velocity for a fighter ship
        mass = Config.MissileMass
        maxSpeed = Config.MissileMaxSpeed
        takeoffSpeed = Config.MissileTakeoffSpeed
        maxForce = Config.MissileMaxForce
        deceleration = Config.MissileDeceleration
        
        // Set the node's position and heading
        self.updateNode()
        
        //Set the team color
        missileNode.setScale(Config.MissileScale)
        if(team != Config.Team.NoTeam)
        {
            missileNode.color = Config.getTeamColor(team: self.team)
            missileNode.colorBlendFactor = 1
        }
        missileNode.zPosition = Config.RenderPriority.GameBottom
        
        // Grab the size of the node
        radius = (missileNode.size.width + missileNode.size.height) / 4
        
        // Set the name for this instance and for the sprite node
        name = self.missileOwner + "." + getUniqueName()
        missileNode.name = name
        
        // Initialize the physics body used for collision detection
        missileNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: missileNode.size.width / 2.0, height: missileNode.size.height))
        missileNode.physicsBody?.isDynamic = true
        missileNode.physicsBody?.affectedByGravity = false
        missileNode.physicsBody?.categoryBitMask = Config.BitMaskCategory.Missile
        missileNode.physicsBody?.contactTestBitMask = Config.BitMaskCategory.Missile + Config.BitMaskCategory.FighterShip + Config.BitMaskCategory.MotherShip
        missileNode.physicsBody?.collisionBitMask = 0x0
        
        // Setup the missile's steering behavior, go in the direction it was facing when created
        steeringBehavior?.setToGo(direction: self.heading)
        
        //print("Initialized \(self.name!)")
    }
    
    // Update function, return true if update successful, return false if this object is ready to be terminated
    override func update(dTime: TimeInterval) -> Bool {
        // If superclass indicates deletion or the missile flew out of bounds, return false
        if(!isActive || self.isOutOfBounds(scale: 1.3)) {
            return false
        }
        
        // Update and draw the object
        updateVelocity(timeElapsed: dTime)
        updatePosition(timeElapsed: dTime)
        updateNode()
        
        return true
    }
    
    // Handle a collision with an object
    override func handleCollision(_ object: BaseObject?) {
        // Check if hit by a missile
        if let _ = object as? Missile {
            // Create an explosion where the ship was destroyed
            ObjectManager.sharedInstance.addObject(object: Explosion(position: self.position, size: self.radius * 3, duration: 0.3, force: heading * self.radius * 10))
            
            // If this is someone else's missile, destroy this missile, unlucky
            destroy()
        }
        // Check if collided with a fighter ship
        else if let fighterShip = object as? FighterShip {
            // Check if this ship is the one who launched the missile, no collision should occur
            if(missileOwner != fighterShip.name) {
                // Create an explosion where the ship was destroyed
                ObjectManager.sharedInstance.addObject(object: Explosion(position: self.position + (heading * fighterShip.radius), size: self.radius * 3, duration: 0.3, force: heading * self.radius * 10))
                
                // Ran into another fighter ship, got em, destroy the missile
                destroy()
            }
        }
    }
    
    override func getNode() -> SKNode? {
        return missileNode
    }
}
