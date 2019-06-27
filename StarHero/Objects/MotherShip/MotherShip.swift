//
//  MotherShip.swift
//  StarHero
//
//  Created by Bryan Van Zile on 6/7/19.
//  Copyright © 2019 Bryan Van Zile. All rights reserved.
//

import Foundation
import SpriteKit

class MotherShip: MovingObject, ObjectPeripheralSight {
    
    
    // Sprite for motherships
    private let motherShipNode = SKSpriteNode(imageNamed: Config.MotherShipLocation)
    private var shieldNode: SKShapeNode? = nil
    
    // All of the fighter ships this mothership owns
    var fighterShips: [FighterShip] = [FighterShip]()
    
    // The peripheral vision of the mothership
    var peripheralNode: SKShapeNode = SKShapeNode()
    var objectsInPeripheral: [String : MovingObject] = [String : MovingObject]()
    
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
        
        shieldNode = SKShapeNode(circleOfRadius: radius * 1.1)
        shieldNode!.lineWidth = 2.0
        shieldNode!.fillColor = .clear
        shieldNode!.strokeColor = UIColor(red: 98, green: 227, blue: 255)
        shieldNode!.zPosition = Config.RenderPriority.GameFront
        
        let upScale: SKAction = SKAction.scale(to: 1.05, duration: 0.8)
        let downScale: SKAction = SKAction.scale(to: 1.0, duration: 0.8)
        let repeatScale: SKAction = SKAction.repeatForever(SKAction.sequence([upScale, downScale]))
        
        shieldNode!.run(repeatScale)
        
        motherShipNode.addChild(shieldNode!)
        
        // Create the mothership's boundary
        let circle = SKShapeNode(circleOfRadius: Config.MotherShipBoundaryLength)
        let pattern: [CGFloat] = [8.0, 8.0]
        let dashed = circle.path!.copy(dashingWithPhase: CGFloat(team) * 2, lengths: pattern)
        
        peripheralNode = SKShapeNode(path: dashed)
        peripheralNode.name = self.name! + ".Peripheral"
        peripheralNode.lineWidth = 2.0
        peripheralNode.fillColor = .clear
        peripheralNode.strokeColor = Config.getTeamColor(team: self.team)
        peripheralNode.zPosition = Config.RenderPriority.GameBottom
        peripheralNode.position = CGPoint(x: self.position.x, y: self.position.y)
        
        setupPeripheralPhysicsBody(radius: Config.MotherShipBoundaryLength, canSee: Config.BitMaskCategory.MotherShip)
        
        ObjectManager.sharedInstance.addNode(node: peripheralNode)
        setBoundary(origin: peripheralNode, distance: Config.MotherShipBoundaryLength)
        
        // Scale at the end
        motherShipNode.setScale(Config.MotherShipScale)
        
        // Add the mothership to the base node
        baseNode.addChild(motherShipNode)
        
        // Add a glow to the mother ship
//        let effectNode = SKEffectNode()
//        effectNode.shouldRasterize = true
//        fighterShipNode.addChild(effectNode)
//        effectNode.addChild(SKSpriteNode(texture: fighterShipNode.texture))
//        effectNode.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 30])
        
        // Initialize the state machine
        stateMachine = StateMachine(object: self)
        
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
        fighterShip.setBoundary(origin: boundaryOrigin!, distance: Config.MotherShipBoundaryLength)
        
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
    
    // A ship enters the peripheral range of this fighter ship
    override func objectInPeripheralRange(_ object: BaseObject?) {
        if let motherShip = object as? MotherShip {
            // Add the new spotted ship to the list
            if let name = motherShip.name {
                print("\(self.name!) sees \(name)")
                objectsInPeripheral[name] = motherShip
                
                // Keep track of enemies separately so we can dodge them
                if motherShip.team != self.team {
                    objectsToAvoid[name] = motherShip
                }
                
                // Move the boundary since a new mothership is in the fray
                moveBoundary()
            }
        }
    }
    
    // A ship leaves this ship's peripheral range
    override func objectOutOfPeripheralRange(_ object: BaseObject?) {
        if let motherShip = object as? MotherShip {
            if let name = motherShip.name {
                // Just try to remove it
                objectsInPeripheral.removeValue(forKey: name)
                objectsToAvoid.removeValue(forKey: name)
                
                // Move the boundary since a new mothership is in the fray
                moveBoundary()
            }
        }
    }
    
    // Move boundary
    func moveBoundary() {
        // Move to the average position of all motherships
        var newX: CGFloat = position.x, newY: CGFloat = position.y, count: Int = 1
        for (_, obj) in objectsInPeripheral {
            if let motherShip = obj as? MotherShip {
                newX += motherShip.position.x
                newY += motherShip.position.y
                count += 1
            }
        }
        
        newX = newX / CGFloat(count)
        newY = newY / CGFloat(count)
        
        // Move the boundary to the new position
        let moveAction = SKAction.move(to: CGPoint(x: newX, y: newY), duration: 2.0)
        peripheralNode.run(moveAction)
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
            shieldNode!.run(SKAction.fadeOut(withDuration: 0.2))
            print("\(name!) is vulnerable!")
        }
        else if attackable && !fighterShips.isEmpty {
            attackable = false
            shieldNode!.run(SKAction.fadeIn(withDuration: 0.2))
            print("\(name!) is protected again!")
        }
        
        // Clean up the objects in peripheral sight
        for (key, object) in objectsInPeripheral {
            if !object.isActive {
                objectsInPeripheral.removeValue(forKey: key)
                
                // If we no longer see a mothership, move the boundary again
                if let _ = object as? MotherShip {
                    moveBoundary()
                }
            }
        }
        
        // Clean up the objects to avoid
        for (key, object) in objectsToAvoid {
            if !object.isActive {
                objectsToAvoid.removeValue(forKey: key)
            }
        }
        
        // Update the fighter ship with the current state
        stateMachine?.update(dTime: dTime)
        
        return true
    }
    
    override func inputTouchDown(touchPos: CGPoint) {
        destroy()
        //spawnFighterShip()
    }
    
    override func destroy() {
        peripheralNode.removeFromParent()
        super.destroy()
    }
}
