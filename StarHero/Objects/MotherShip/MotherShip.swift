//
//  MotherShip.swift
//  StarHero
//
//  Created by Bryan Van Zile on 6/7/19.
//  Copyright © 2019 Bryan Van Zile. All rights reserved.
//

import Foundation
import SpriteKit

class MotherShip: MovingObject {
    // Sprite for motherships
    private let motherShipNode = SKSpriteNode(imageNamed: Config.MotherShipLocation)
    private var motherShipShieldNode: SKShapeNode? = nil
    
    // All of the fighter ships this mothership owns
    var fighterShips: [FighterShip] = [FighterShip]()
    
    // The mothership state machine
    var stateMachine: StateMachine?
    
    // Cooldown before we can spawn a new fightership
    var spawningCooldown: Double = Config.MotherShipSpawnCooldown
    
    // Initialize the mother ship
    override init(position: Vector? = nil, heading: Vector? = nil, team: Int = Config.Team.NoTeam) {
        super.init(position: position, heading: heading, team: team)
        
        // Get all of the default fighter ship physics properties
        mass = Config.MotherShipMass
        maxSpeed = Config.MotherShipMaxSpeed
        takeoffSpeed = Config.MotherShipTakeoffSpeed
        maxForce = Config.MotherShipMaxForce
        deceleration = Config.MotherShipDeceleration
        
        // Set the node's position and heading
        self.updateNode()
        
        //Set the team color
        motherShipNode.color = Config.getTeamColor(team: self.team)
        motherShipNode.colorBlendFactor = 1
        motherShipNode.zPosition = Config.RenderPriority.GameFront
        
        // Grab the size of the node
        radius = (motherShipNode.size.width + motherShipNode.size.height) / 4
        attackable = false
        
        print("\(motherShipNode.size) + \(radius)")
        
        // Set the name for this instance and for the sprite node
        name = getUniqueName()
        motherShipNode.name = name
        
        let oneRevolution: SKAction = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 20)
        let repeatRotation: SKAction = SKAction.repeatForever(oneRevolution)
        
        motherShipNode.run(repeatRotation)
        
        // Initialize the physics body used for collision detection
        motherShipNode.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        motherShipNode.physicsBody?.isDynamic = true
        motherShipNode.physicsBody?.affectedByGravity = false
        motherShipNode.physicsBody?.categoryBitMask = Config.BitMaskCategory.MotherShip
        motherShipNode.physicsBody?.contactTestBitMask = 0x0
        motherShipNode.physicsBody?.collisionBitMask = 0x0
        
        motherShipShieldNode = SKShapeNode(circleOfRadius: radius * 1.1)
        motherShipShieldNode!.lineWidth = 2.0
        motherShipShieldNode!.fillColor = .clear
        motherShipShieldNode!.strokeColor = UIColor(red: 98, green: 227, blue: 255)
        motherShipShieldNode!.zPosition = Config.RenderPriority.GameFront
        
        let upScale: SKAction = SKAction.scale(to: 1.05, duration: 0.8)
        let downScale: SKAction = SKAction.scale(to: 1.0, duration: 0.8)
        let repeatScale: SKAction = SKAction.repeatForever(SKAction.sequence([upScale, downScale]))
        
        motherShipShieldNode!.run(repeatScale)
        
        motherShipNode.addChild(motherShipShieldNode!)
        
        // Scale at the end
        motherShipNode.setScale(Config.MotherShipScale)
        
        // Add a glow to the mother ship
//        let effectNode = SKEffectNode()
//        effectNode.shouldRasterize = true
//        fighterShipNode.addChild(effectNode)
//        effectNode.addChild(SKSpriteNode(texture: fighterShipNode.texture))
//        effectNode.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 30])
        
        // Initialize the state machine
        stateMachine = StateMachine(object: self)
        //stateMachine?.changeState(newState: FighterShipWanderState.sharedInstance)
        
        // Spawn 4 fighter ships off the start
        for _ in 0..<Config.MotherShipInitialSpawn {
            spawnFighterShip()
        }
        
        print("Initialized \(self.name!) on team \(self.team)")
    }
    
    // Spawn a fighter ship
    func spawnFighterShip(direction: Vector? = nil) {
        let spawnToward = direction ?? position.reverse()
        let fighterShip = FighterShip(position: position, heading: spawnToward, team: team)
        
        fighterShips.append(fighterShip)
        
        ObjectManager.sharedInstance.addObject(object: fighterShip)
    }
    
    // Handle a collision with an object
    override func handleCollision(_ object: BaseObject?) {
        // Check if hit by a missile
        if let missile = object as? Missile {
            // Ignore this missile it belongs to this ship
            if(missile.missileOwner != name) {
                // Destroy the mothership if it is vulnerable
                if attackable {
                    // Explode
                    explode(duration: 1.5)
                    destroy()
                }
            }
        }
        // Check if ran into another fighter ship
        else if let fighterShip = object as? FighterShip {
            // Ignore if this ship is on our team
            if(fighterShip.team != team) {
                // Destroy the mothership if it is vulnerable
                if attackable {
                    // Explode
                    explode(duration: 1.5)
                    destroy()
                }
            }
        }
    }
    
    // Update function, return true if update successful, return false if this object is ready to be terminated
    override func update(dTime: TimeInterval) -> Bool {
        // If superclass indicates deletion, return false
        if !isActive {
            return false
        }
        
        // Check if we can spawn a fighter ship
        if spawningCooldown < 0 {
            spawnFighterShip()
            
            spawningCooldown += Config.MotherShipSpawnCooldown
        }
        spawningCooldown -= dTime
        
        // Clean up dead fighter ships
        fighterShips.removeAll(where: {$0.isActive == false})
        
        // Update the mother ship with its current status
        if !attackable && fighterShips.isEmpty {
            attackable = true
            motherShipShieldNode!.run(SKAction.fadeOut(withDuration: 0.2))
            print("\(name!) is vulnerable!")
        }
        else if attackable && !fighterShips.isEmpty {
            attackable = false
            motherShipShieldNode!.run(SKAction.fadeIn(withDuration: 0.2))
            print("\(name!) is protected again!")
        }
        
        // Update the fighter ship with the current state
        stateMachine?.update(dTime: dTime)
        
        return true
    }
    
    override func inputTouchDown(touchPos: CGPoint) {
        //destroy()
        //spawnFighterShip()
    }
    
    override func getNode() -> SKNode? {
        return motherShipNode
    }
}
