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
    
    // Reference to another object that the fighter ship can pursue and attack
    var target: MovingObject? = nil
    
    // Count of how many missiles this fighter ship has currently
    var missileCount: Int = Config.FighterShipMaxMissileCount
    var missileReloadCooldown: CGFloat = 0.0
    
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
        
        // Initialize the state machine
        stateMachine = StateMachine(object: self)
        stateMachine?.changeState(newState: FighterShipWanderState.sharedInstance)
        
        print("Initialized \(self.name!)")
    }
    
    // Fire a missile at the current direction we are facing
    func fireMissile() {
        if missileReloadCooldown <= 0 {
            if(missileCount > 0) {
                ObjectManager.sharedInstance.addObject(object: Missile(owner: name!, position: position, heading: heading))
                //missileCount -= 1
            }
            else {
                fullyReloadMissiles()
            }
            
            // Reset the cooldown
            missileReloadCooldown = Config.FighterShipReloadCooldown
        }
    }
    
    // Reload the fighter ship with the max amount of missiles it can carry
    func fullyReloadMissiles() {
        missileCount = Config.FighterShipMaxMissileCount
        print("\(name!) reloaded!")
    }
    
    // Handle a collision with an object
    override func handleCollision(_ object: BaseObject?) {
        // Check if hit by a missile
        if let missile = object as? Missile {
            // Ignore this missile it belongs to this ship
            if(missile.missileOwner != name) {
                // If this is someone else's missile, destroy this ship
                destroy()
            }
        }
        // Check if ran into another fighter ship
        else if let fighterShip = object as? FighterShip {
            // Ignore if this ship is on our team
            if(fighterShip.team != team) {
                // Ran into another fighter ship, destroy this ship
                destroy()
            }
        }
    }
    
    // Spot something
    override func seeObject(_ object: BaseObject?) {
        if let spottedFighterShip = object as? FighterShip {
            if target == nil || !stateMachine!.isInState(inState: FighterShipAttackState.sharedInstance) {
                // Make the spotted fighter ship the target
                target = spottedFighterShip
                stateMachine?.changeState(newState: FighterShipAttackState.sharedInstance)
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
        
        // Update the fighter ship with the current state
        stateMachine?.update(dTime: dTime)
        
        return true
    }
    
    override func inputTouchDown(touchPos: CGPoint) {
        fireMissile()
    }
    
    override func getNode() -> SKNode? {
        return fighterShipNode
    }
}
