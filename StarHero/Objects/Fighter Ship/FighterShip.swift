//
//  FighterShip.swift
//  StarHero
//
//  Created by Bryan Van Zile on 5/17/19.
//  Copyright © 2019 Bryan Van Zile. All rights reserved.
//

import Foundation
import SpriteKit

class FighterShip: MovingObject, ObjectCanSee {
    // Sprite for fighter ships
    private let fighterShipNode = SKSpriteNode(imageNamed: Config.FighterShipLocation)
    
    // Declare the required sight node
    var sightNode = SKShapeNode()
    
    // The fighter ship state machine
    var stateMachine: StateMachine?
    
    // Reference to all of the objects the ship can currently see
    var objectsInSight: [String: MovingObject] = [String: MovingObject]()
    
    // The last known direction that a threat was known, useful after dodging
    var lastThreatHeading: Vector? = nil
    
    // Count of how many missiles this fighter ship has currently
    var missileCount: Int = Config.FighterShipMaxMissileCount
    var missileReloadCooldown: CGFloat = 0.0
    var missileLaunchSide: Int = Int.random(in: 0...1)
    
    var debugText: SKLabelNode = SKLabelNode(text: "test")
    
    // Initialize the fighter ship
    override init(position: Vector? = nil, heading: Vector? = nil, team: Int = Config.Team.NoTeam) {
        super.init(position: position, heading: heading, team: team)
        
        // Get all of the default fighter ship physics properties
        mass = Config.FighterShipMass
        maxSpeed = Config.FighterShipMaxSpeed
        takeoffSpeed = Config.FighterShipTakeoffSpeed
        maxForce = Config.FighterShipMaxForce
        deceleration = Config.FighterShipDeceleration
        
        // Set the node's position and heading
        self.updateNode()
        
        //Set the team color
        fighterShipNode.setScale(Config.FighterShipScale)
        fighterShipNode.color = Config.getTeamColor(team: self.team)
        fighterShipNode.colorBlendFactor = 1
        fighterShipNode.zPosition = Config.RenderPriority.GameDefault
        
        // Grab the size of the node
        radius = (fighterShipNode.size.width + fighterShipNode.size.height) / 4
        
        // Set the name for this instance and for the sprite node
        name = getUniqueName()
        fighterShipNode.name = name
        
        // Initialize the physics body used for collision detection
        fighterShipNode.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        fighterShipNode.physicsBody?.isDynamic = true
        fighterShipNode.physicsBody?.affectedByGravity = false
        fighterShipNode.physicsBody?.categoryBitMask = Config.BitMaskCategory.FighterShip
        fighterShipNode.physicsBody?.contactTestBitMask = Config.BitMaskCategory.FighterShip
        fighterShipNode.physicsBody?.collisionBitMask = 0x0
        
        // Move the sight to be in front of the ship and not visible
        sightNode.position = CGPoint(x: 0, y: radius + 0.01)
        sightNode.isHidden = true
        sightNode.name = self.name! + ".Sight"
        setupSightPhysicsBody(degrees: Config.FighterShipSightPeripheral, distance: Config.FighterShipSightDistance, canSee: Config.BitMaskCategory.FighterShip + Config.BitMaskCategory.Missile)
        
        // Add the sight node to the fighter ship
        fighterShipNode.addChild(sightNode)
        
        debugText.fontSize = 80
        debugText.position = CGPoint(x: 0, y: -150)
        debugText.fontColor = SKColor.yellow
        debugText.text = "0"
        fighterShipNode.addChild(debugText)
        
        // Initialize the state machine
        stateMachine = StateMachine(object: self)
        stateMachine?.changeState(newState: FighterShipWanderState.sharedInstance)
        
        print("Initialized \(self.name!) with color \(fighterShipNode.color)")
    }
    
    // Aim and start firing missiles
    func attackTarget() {
        // Make sure there is something to be attacking
        if let enemy = steeringBehavior?.pursuedTarget {
            // Vector to the enemy object's current position
            let distanceToTarget = enemy.position - self.position
            
            // Calculate how far in front of the enemy to be aiming
            let lookAheadTime = distanceToTarget.length() / Config.MissileMaxSpeed
            
            // Calculate what an accurate shot would look like
            let accurateShotVelocity = distanceToTarget + (enemy.velocity * lookAheadTime)
            
            // Check if our current heading is close enough to start firing
            if self.heading.dot(vector: accurateShotVelocity) < 0.2 {
                // Check if we can fire a missile
                if missileReloadCooldown <= 0 {
                    // Check if we have any rockets
                    if(missileCount > 0) {
                        // Offset the rocket's position when firing
                        let missileLaunchOffset: Vector = missileLaunchSide % 1 == 0 ? self.heading.left() * self.radius / 4 : self.heading.right() * self.radius / 4
                        missileLaunchSide += 1
                        
                        let missileLaunchHeading: Vector = accurateShotVelocity.normalize()
                        
                        // Fire a missile at the projected velocity
                        fireMissile(position: self.position + missileLaunchOffset, heading: missileLaunchHeading)
                        
                        // Handle the missile being fired
                        missileCount -= 1
                        
                        if missileCount <= 0 {
                            // Simulate a reload
                            missileCount = Config.FighterShipMaxMissileCount
                            missileReloadCooldown = Config.FighterShipReloadCooldown
                        }
                        else {
                            // Just use the limit for how many you can fire
                            missileReloadCooldown = Config.FighterShipFiringLimit
                        }
                    }
                }
            }
        }
    }
    
    // Check if this fighter ship sees any other fighter ships
    func seesEnemyFighterShip() -> Bool {
        // Simply check if we see anything at all first
        if !objectsInSight.isEmpty {
            // Look through what is in sight
            for (_, objInSight) in self.objectsInSight {
                // Try to cast to fighter ship
                if let enemy = objInSight as? FighterShip {
                    // Make sure it's not a friendly
                    if enemy.team != team {
                        // Found at least one, so just return true
                        return true
                    }
                }
            }
        }
        
        return false
    }
    
    // Get the closest fighter ship that is visible
    func getClosestEnemyFighterShip(to: Vector? = nil) -> FighterShip? {
        // Unwrap the position we are checking for closeness to, default is this ship's position
        let location = to ?? self.position
        
        // The closest moving object
        var closest: FighterShip?
        
        // Look through what this object can see and grab the closest
        for (_, objInSight) in self.objectsInSight {
            // Try to cast to fighter ship
            if let fighterShipInSight = objInSight as? FighterShip {
                // Check if this is the closest/an enemy and make it the new return value if so
                if fighterShipInSight.isActive && fighterShipInSight.team != team {
                    if closest == nil {
                        closest = fighterShipInSight
                    }
                    else {
                        if((closest!.position - location).length() > (fighterShipInSight.position - location).length()) {
                            closest = fighterShipInSight
                        }
                    }
                }
            }
        }
        
        return closest
    }
    
    // Fire a missile at the current direction we are facing
    func fireMissile(position: Vector? = nil, heading: Vector? = nil) {
        var pos: Vector, head: Vector
        
        // Unwrap the input or set the default
        if position != nil {
            pos = position!
        }
        else {
            pos = self.position
        }
        
        // Unwrap the input or set the default
        if heading != nil {
            head = heading!
        }
        else {
            head = self.heading
        }
        
        ObjectManager.sharedInstance.addObject(object: Missile(owner: name!, position: pos, heading: head))
    }
    
    // Handle a collision with an object
    override func handleCollision(_ object: BaseObject?) {
        // Check if hit by a missile
        if let missile = object as? Missile {
            // Ignore this missile it belongs to this ship
            if(missile.missileOwner != name) {
                // Create an explosion where the ship was destroyed
                ObjectManager.sharedInstance.addObject(object: Explosion(position: self.position, size: self.radius * 2.3, duration: 0.7))
                
                // If this is someone else's missile, destroy this ship
                destroy()
            }
        }
        // Check if ran into another fighter ship
        else if let fighterShip = object as? FighterShip {
            // Ignore if this ship is on our team
            if(fighterShip.team != team) {
                // Create an explosion where the ship was destroyed
                ObjectManager.sharedInstance.addObject(object: Explosion(position: self.position, size: self.radius * 2.3, duration: 0.7))
                
                // Ran into another fighter ship, destroy this ship
                destroy()
            }
        }
    }
    
    // Spot something
    override func seeObject(_ object: BaseObject?) {
        if let spottedFighterShip = object as? FighterShip {
            // Add the new spotted ship to the list
            if let name = spottedFighterShip.name {
                objectsInSight[name] = spottedFighterShip
                    
                // Don't attack the ship if they are on our team
                if spottedFighterShip.team != team {
                    
                    // Ignore if we are already attacking or dodging
                    if !stateMachine!.isInState(FighterShipAttackState.sharedInstance, FighterShipDodgeState.sharedInstance) {
                        // Make the spotted fighter ship the target
                        stateMachine?.changeState(newState: FighterShipAttackState.sharedInstance)
                    }
                }
            }
        }
        else if let spottedMissile = object as? Missile {
            // Vector for this ship's position and the spotted missile
            let missileDistance = self.position - spottedMissile.position
            
            // Calculate how far in front of the ship that the missile is aiming
            let lookAheadTime = missileDistance.length() / Config.MissileMaxSpeed
            
            // Calculate what the velocity of an accurate shot at this ship would look like
            let accurateShotVelocity = missileDistance + (self.velocity * lookAheadTime)
            
            // Check if the missile is close to aiming at this ship
            if spottedMissile.heading.dot(vector: accurateShotVelocity) < 0.2 {
                let dodgeVector = ((spottedMissile.heading * spottedMissile.maxSpeed) + self.velocity).normalize()
                
                if dodgeVector.dot(vector: self.velocity.right()) > 1.5708 {
                    // Go straight right
                    steeringBehavior?.setToGo(direction: self.heading.right())
                    stateMachine?.changeState(newState: FighterShipDodgeState.sharedInstance)
                }
                else {
                    // Go straight left
                    steeringBehavior?.setToGo(direction: self.heading.left())
                    stateMachine?.changeState(newState: FighterShipDodgeState.sharedInstance)
                }
            }
            else {
                // If we're just wandering, try to locate the shooter
                if stateMachine!.isInState(FighterShipWanderState.sharedInstance) {
                    // Head toward where the missile is coming from
                    let difference = spottedMissile.position - position
                    steeringBehavior?.setToGo(direction: difference + (spottedMissile.heading.reverse() * (difference.length() * 2)))
                    stateMachine?.changeState(newState: FighterShipTurnToLookState.sharedInstance)
                }
            }
        }
    }
    
    // Target moves out of sight
    override func loseSightOnObject(_ object: BaseObject?) {
        // Unwrap the spotted object
        if let spottedObject = object as? MovingObject {
            if let name = spottedObject.name {
                objectsInSight.removeValue(forKey: name)
            }
        }
    }
    
    // Update function, return true if update successful, return false if this object is ready to be terminated
    override func update(dTime: TimeInterval) -> Bool {
        // If superclass indicates deletion, return false
        if !isActive {
            return false
        }
        
        // Update the reload cooldown if necessary
        if missileReloadCooldown > 0 {
            missileReloadCooldown -= CGFloat(dTime)
        }
        
        // Clean up the seen objects
        for (seenName, seenObject) in objectsInSight {
            if !seenObject.isActive {
                objectsInSight.removeValue(forKey: seenName)
            }
        }
        
        // Return in bounds if we find ourselves outside the boundary
        if(isOutOfBounds() && !stateMachine!.isInState(FighterShipReturnToFieldState.sharedInstance, FighterShipDodgeState.sharedInstance)) {
            stateMachine?.changeState(newState: FighterShipReturnToFieldState.sharedInstance)
        }
        else if isOutOfBounds(scale: 2.0) {
            print("\(name!) has ran away! This is probably a bug.")
            destroy()
        }
        
        debugText.text = "\(objectsInSight.count)"
        
        // Update the fighter ship with the current state
        stateMachine?.update(dTime: dTime)
        
        return true
    }
    
    override func inputTouchDown(touchPos: CGPoint) {
        destroy()
    }
    
    override func getNode() -> SKNode? {
        return fighterShipNode
    }
}
