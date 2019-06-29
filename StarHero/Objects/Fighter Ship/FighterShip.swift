//
//  FighterShip.swift
//  StarHero
//
//  Created by Bryan Van Zile on 5/17/19.
//  Copyright © 2019 Bryan Van Zile. All rights reserved.
//

import Foundation
import SpriteKit

class FighterShip: MovingObject, ObjectCanSee, ObjectPeripheralSight, ObjectTouchControls {
    // Sprite for fighter ships
    private let fighterShipNode = SKSpriteNode(imageNamed: Config.FighterShipLocation)
    
    // Controls whether the fightership can attack right now
    var canAttack: Bool = true
    
    // Declare the required sight nodes
    var sightNode = SKShapeNode()
    var peripheralNode = SKShapeNode()
    
    // Reference to all of the objects the ship can currently see
    var objectsInSight: [String : MovingObject] = [String : MovingObject]()
    var objectsInPeripheral: [String : MovingObject] = [String : MovingObject]()
    
    // Node for touch controls
    var touchNode: SKShapeNode?
    var line: SKShapeNode?
    var path: CGMutablePath?
    var lastTouchPos: CGPoint?
    var points: [CGPoint] = [CGPoint]()
    
    // The last known direction that a threat was known, useful after dodging
    var lastThreatHeading: Vector? = nil
    
    // Count of how many missiles this fighter ship has currently
    var missileCount: Int = Config.FighterShipMaxMissileCount
    var missileReloadCooldown: CGFloat = 0.0
    var missileLaunchSide: Int = Int.random(in: 0...1)
    
    let debugging: Bool = false
    var debugText: SKLabelNode = SKLabelNode(text: "test")
    
    // The fighter ship state machine
    var stateMachine: StateMachine?
    
    // Initialize the fighter ship
    override init(position: Vector? = nil, heading: Vector? = nil, team: Int = Config.Team.NoTeam, userControlled: Bool = false) {
        super.init(position: position, heading: heading, team: team, userControlled: userControlled)
        
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
        attackable = true
        
        // Set the name for this instance and for the sprite node
        name = getUniqueName()
        baseNode.name = name! + ".Base"
        fighterShipNode.name = name! + ".Sprite"
        
        // Initialize the physics body used for collision detection
        fighterShipNode.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        fighterShipNode.physicsBody?.isDynamic = true
        fighterShipNode.physicsBody?.affectedByGravity = false
        fighterShipNode.physicsBody?.categoryBitMask = Config.BitMaskCategory.FighterShip
        fighterShipNode.physicsBody?.contactTestBitMask = Config.BitMaskCategory.FighterShip + Config.BitMaskCategory.MotherShip
        fighterShipNode.physicsBody?.collisionBitMask = 0x0
        
        // Move the sight to be in front of the ship and not visible
        sightNode.position = CGPoint(x: 0, y: radius + 0.01)
        sightNode.isHidden = true
        sightNode.name = self.name! + ".Sight"
        setupSightPhysicsBody(degrees: Config.FighterShipSightFOV, distance: Config.FighterShipSightDistance, canSee: Config.BitMaskCategory.FighterShip + Config.BitMaskCategory.Missile + Config.BitMaskCategory.MotherShip)
        
        // Add the sight node to the base node
        baseNode.addChild(sightNode)
        
        // Create the peripheral vision node for the fighter ship
        peripheralNode.position = CGPoint(x: 0, y: Config.FighterShipPeripheralRadius / 2)
        peripheralNode.isHidden = true
        peripheralNode.name = self.name! + ".Peripheral"
        setupPeripheralPhysicsBody(radius: Config.FighterShipPeripheralRadius, canSee: Config.BitMaskCategory.FighterShip + Config.BitMaskCategory.MotherShip)
        
        // Add the peripheral node to the fighter ship
        baseNode.addChild(peripheralNode)
        
        // Setup the touch control node
        touchNode = SKShapeNode(circleOfRadius: self.radius * 3)
        touchNode!.name = self.name! + ".Touch"
        setupTouchNode()
        
        baseNode.addChild(touchNode!)
        
        // Add a glow to the fighter ship
//        let effectNode = SKEffectNode()
//        effectNode.shouldRasterize = true
//        fighterShipNode.addChild(effectNode)
//        effectNode.addChild(SKSpriteNode(texture: fighterShipNode.texture))
//        effectNode.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 30])
        
        debugText.fontSize = 25
        debugText.position = CGPoint(x: 0, y: -50)
        debugText.fontColor = SKColor.yellow
        debugText.text = "0"
        if debugging {
            baseNode.addChild(debugText)
        }
        
        // Add the fighter ship to the base node
        baseNode.addChild(fighterShipNode)
        
        // Initialize the state machine
        stateMachine = StateMachine(object: self)
        stateMachine?.changeState(newState: FighterShipWanderState.sharedInstance)
        
        //print("Initialized \(self.name!) on team \(self.team)")
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
            
            // Measure the size of the angle to be accurate
            let accurateShotAngle = atan(enemy.radius / accurateShotVelocity.length())
            
            // Check if our current heading is close enough to start firing
            if self.heading.dot(vector: accurateShotVelocity) <= accurateShotAngle * 1.2 {
                
                // Now we need to check if we would hit a friendly
                if objectsInSight.count > 1 {
                    // There is more than just the one that we are firing at in sight, so let's look through the list
                    for (_, object) in objectsInSight {
                        // Check if this one is on our team
                        if object.team == self.team {
                            // Now check if it's closer than the enemy
                            let distanceToFriendly = object.position - position
                            
                            if distanceToFriendly.length() < distanceToTarget.length() {
                                // Let's measure if a shot might hit it
                                let time = distanceToFriendly.length() / Config.MissileMaxSpeed
                                let accurateFriendlyShot = distanceToFriendly * time
                                let accurateFriendlyShotAngle = atan(object.radius / accurateFriendlyShot.length())
                                
                                if self.heading.dot(vector: accurateFriendlyShot) < accurateFriendlyShotAngle + 0.1 {
                                    // Firing a missile right now would hit an ally
                                    return
                                }
                            }
                        }
                    }
                }
                
                // Now check if an ally is right on top of us, and if we're behind it, move a little
                if objectsInPeripheral.count > 0 {
                    // Check each one to see who's there
                    for (_, object) in objectsInPeripheral {
                        if object.team == team && (object.position - position).length() < radius * 2 {
                            // Determine if we are the one behind the other
                            if heading.dot(vector: object.position - position) < 1.5708 {
                                // We're too close, so dodge a little to the left or right to get a better angle
                                print("Dodging to get a better angle!")
                                steeringBehavior?.returnHeading = heading
                                steeringBehavior?.setToGo(direction: (Bool.random() ? self.heading.right() : self.heading.left()) + heading)
                                stateMachine?.changeState(newState: FighterShipDodgeState.sharedInstance)
                            }
                            else {
                                // It's not safe to fire yet so wait a bit
                                return
                            }
                        }
                    }
                }
                
                // Check if we can fire a missile
                if missileReloadCooldown <= 0 {
                    // Check if we have any rockets
                    if(missileCount > 0) {
                        // Offset the rocket's position when firing
                        //let missileLaunchOffset: Vector = missileLaunchSide % 1 == 0 ? self.heading.left() * self.radius / 4 : self.heading.right() * self.radius / 4
                        //missileLaunchSide += 1
                        let missileLaunchOffset: Vector = heading * radius
                        
                        let missileLaunchHeading: Vector = accurateShotVelocity.normalize()
                        
                        // Fire a missile at the projected velocity
                        fireMissile(position: self.position + missileLaunchOffset, heading: missileLaunchHeading)
                        
                        // Handle the missile being fired
                        //missileCount -= 1
                        
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
    func seesAttackableEnemy() -> Bool {
        // Simply check if we see anything at all first
        if !objectsInSight.isEmpty {
            // Look through what is in sight
            for (_, objInSight) in self.objectsInSight {
                // Make sure it's not a friendly
                if objInSight.team != team && objInSight.attackable {
                    // Found at least one, so just return true
                    return true
                }
            }
        }
        return false
    }
    
    // Get the closest fighter ship that is visible
    func getClosestEnemyToAttack(to: Vector? = nil) -> MovingObject? {
        // Unwrap the position we are checking for closeness to, default is this ship's position
        let location = to ?? self.position
        
        // The closest moving object
        var closest: MovingObject?
        
        // Look through what this object can see and grab the closest
        for (_, objectInSight) in self.objectsInSight {
            // Check if this is the closest/an enemy and make it the new return value if so
            if objectInSight.isActive && objectInSight.team != team && objectInSight.attackable {
                if closest == nil {
                    closest = objectInSight
                }
                else {
                    if((closest!.position - location).length() > (objectInSight.position - location).length()) {
                        closest = objectInSight
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
                // Determine the force behind the explosion and then explode
                let force = ((velocity * mass) + (missile.velocity * missile.mass)).normalize()
                explode(sizeScale: 1.15, force: force, forceFactor: 2.5)
                
                // If this is someone else's missile, destroy this ship
                destroy()
            }
        }
        // Check if ran into another fighter ship
        else if let fighterShip = object as? FighterShip {
            // Ignore if this ship is on our team
            if(fighterShip.team != team) {
                // Determine the force behind the explosion and then explode
                let force = ((velocity * mass) + (fighterShip.velocity * fighterShip.mass)).normalize()
                explode(sizeScale: 1.0, force: force, forceFactor: 3)
                
                // Ran into another fighter ship, destroy this ship
                destroy()
            }
        }
        // Check if ran into another mother ship
        else if let motherShip = object as? MotherShip {
            // Ignore if this ship is on our team
            if(motherShip.team != team) {
                // Determine the force behind the explosion
                let force = ((velocity * mass) + (motherShip.velocity * motherShip.mass)).normalize()
                
                // Create an explosion where the ship was destroyed
                ObjectManager.sharedInstance.addObject(object: Explosion(position: self.position, size: self.radius * 2, duration: 0.9, force: force * self.radius * 3))
                
                // Ran into a mothership, destroy this ship
                destroy()
            }
            else {
                //print("\(name!) is safe in their mothership")
                attackable = false
                canAttack = false
            }
        }
    }
    
    // Handle a collision with an object
    override func handleStopColliding(_ object: BaseObject?) {
        // If we have left the mothership, become active
        if let _ = object as? MotherShip {
            //print("Left the safety of the mothership")
            attackable = true
            canAttack = true
        }
    }
    
    // Spot something
    override func seeObject(_ object: BaseObject?) {
        if let spottedFighterShip = object as? FighterShip {
            // Add the new spotted ship to the list
            if let name = spottedFighterShip.name {
                objectsInSight[name] = spottedFighterShip
            }
        }
        else if let spottedMotherShip = object as? MotherShip {
            // Add the new spotted ship to the list
            if let name = spottedMotherShip.name {
                objectsInSight[name] = spottedMotherShip
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
    
    // A ship enters the peripheral range of this fighter ship
    override func objectInPeripheralRange(_ object: BaseObject?) {
        if let fighterShip = object as? FighterShip {
            // Add the new spotted ship to the list
            if let name = fighterShip.name {
                objectsInPeripheral[name] = fighterShip
                
                // Keep track of enemies separately so we can dodge them
                if fighterShip.team != self.team {
                    objectsToAvoid[name] = fighterShip
                }
            }
        }
        else if let motherShip = object as? MotherShip {
            // Add the new spotted ship to the list
            if let name = motherShip.name {
                objectsInPeripheral[name] = motherShip
                
                // Keep track of enemies separately so we can dodge them
                if motherShip.team != self.team {
                    objectsToAvoid[name] = motherShip
                }
            }
        }
    }
    
    // A ship leaves this ship's peripheral range
    override func objectOutOfPeripheralRange(_ object: BaseObject?) {
        if let fighterShip = object as? FighterShip {
            if let name = fighterShip.name {
                // Just try to remove it
                objectsInPeripheral.removeValue(forKey: name)
                objectsToAvoid.removeValue(forKey: name)
            }
        }
        else if let motherShip = object as? MotherShip {
            if let name = motherShip.name {
                // Just try to remove it
                objectsInPeripheral.removeValue(forKey: name)
                objectsToAvoid.removeValue(forKey: name)
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
        
        // Clean up the seen objects
        for (seenName, seenObject) in objectsInPeripheral {
            if !seenObject.isActive {
                objectsInPeripheral.removeValue(forKey: seenName)
            }
        }
        
        // Clean up the objects to avoid
        for (seenName, seenObject) in objectsToAvoid {
            if !seenObject.isActive {
                objectsToAvoid.removeValue(forKey: seenName)
            }
        }
        
        // Return in bounds if we find ourselves outside the boundary
        if(isOutOfBounds() && !stateMachine!.isInState(FighterShipReturnToFieldState.sharedInstance, FighterShipDodgeState.sharedInstance)) {
            stateMachine?.changeState(newState: FighterShipReturnToFieldState.sharedInstance)
        }
        
        debugText.text = "\(objectsToAvoid.count)"
        
        // Update the fighter ship with the current state
        stateMachine?.update(dTime: dTime)
        
        return true
    }
    
    override func inputTouchDown(touchPos: CGPoint) -> Bool {
        if userControlled {
            // Pause everything while the action takes place
            ObjectManager.sharedInstance.pause()
            
            // Setup the path
            path = CGMutablePath()
            let firstPoint = (position + (velocity.normalize() * radius * 1.25)).toCGPoint()
            path!.move(to: firstPoint)
            points.append(firstPoint)
            lastTouchPos = touchPos
            
            // Remove the previous line node asap if it is still running an action
            releasePathNode()
            
            // Setup the line node
            line = SKShapeNode()
            line!.strokeColor = .gray
            line!.alpha = 0.5
            line!.lineWidth = 4
            
            // Start drawing the line if necessary
            if position.distanceBetween(vector: Vector(touchPos)) > radius * 1.25 {
                points.append(drawPath(pos: touchPos))
                lastTouchPos = touchPos
            }
            
            // Add this node to the scene
            ObjectManager.sharedInstance.addNode(node: line!)
            ObjectManager.sharedInstance.activeObject = self
            
            return true
        }
        
        return false
    }
    
    override func inputTouchMoved(touchPos: CGPoint) -> Bool {
        if userControlled {
            // Start drawing the line when necessary
            if position.distanceBetween(vector: Vector(touchPos)) > radius * 1.25 && path != nil {
                points.append(drawPath(pos: touchPos))
                lastTouchPos = touchPos
            }
            
            return true
        }
        
        return false
    }
    
    override func inputTouchUp(touchPos: CGPoint) -> Bool {
        if userControlled && ObjectManager.sharedInstance.activeObject == self {
            // Unpause the game, as the move action is completed
            ObjectManager.sharedInstance.unpause()
            
            // End the path
            addArrow()
            releasePathNode(maxSpeed)
            lastTouchPos = nil
            
            // Setup the steering behavior with the path array
            steeringBehavior!.setToFollowPath(path: points.reversed(), accuracy: 2.0)
            points.removeAll()
            
            // Change into the moving state
            stateMachine?.changeState(newState: FighterShipMoveState.sharedInstance)
            
            // Release self as active object
            ObjectManager.sharedInstance.activeObject = nil
            
            return true
        }
        
        return false
    }
}
