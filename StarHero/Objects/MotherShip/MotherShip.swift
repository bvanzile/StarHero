//
//  MotherShip.swift
//  StarHero
//
//  Created by Bryan Van Zile on 6/7/19.
//  Copyright © 2019 Bryan Van Zile. All rights reserved.
//

import Foundation
import SpriteKit

class MotherShip: MovingObject, ObjectPeripheralSight, ObjectTouchControls {
    // Sprite for motherships
    private let motherShipNode = SKSpriteNode(imageNamed: Config.MotherShipLocation)
    private var shieldNode: SKShapeNode? = nil
    
    // All of the fighter ships this mothership owns
    var fighterShips: [FighterShip] = [FighterShip]()
    
    // Stubs from ObjectPeripheralSight: The peripheral vision of the mothership
    var peripheralNode: SKShapeNode = SKShapeNode()
    var objectsInPeripheral: [String : MovingObject] = [String : MovingObject]()
    
    // Stubs from ObjectTouchControls: The node for initializing touch controls for this object
    var touchNode: SKShapeNode?
    var line: SKShapeNode?
    var path: CGMutablePath?
    var lastTouchPos: CGPoint?
    var points: [CGPoint] = [CGPoint]()
    
    // The mothership state machine and steering behavior
    var stateMachine: StateMachine?
    
    // Cooldown before we can spawn a new fightership
    private var spawningCooldown: Double = Config.MotherShipSpawnCooldown
    
    // Node for labels to attach to
    private var labelNode: SKNode = SKNode()
    
    // Energy motherships need
    private var energy: Int = 100
    private var energyLabel: SKLabelNode = SKLabelNode(fontNamed: "HelveticaNeue")
    
    // Initialize the mother ship
    override init(position: Vector? = nil, heading: Vector? = nil, team: Int = Config.Team.NoTeam, userControlled: Bool = false) {
        super.init(position: position, heading: Vector(x: 0, y: 1), team: team, userControlled: userControlled)
        
        // Get all of the default fighter ship physics properties
        mass = Config.MotherShipMass
        maxSpeed = Config.MotherShipMaxSpeed
        takeoffSpeed = Config.MotherShipTakeoffSpeed
        maxForce = Config.MotherShipMaxForce
        deceleration = Config.MotherShipDeceleration
        
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
        baseNode.name = name! + ".Base"
        motherShipNode.name = name! + ".Sprite"
        
        let oneRevolution: SKAction = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 20)
        let repeatRotation: SKAction = SKAction.repeatForever(oneRevolution)
        
        motherShipNode.run(repeatRotation)
        
        // Initialize the physics body used for collision detection
        motherShipNode.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        motherShipNode.physicsBody!.isDynamic = true
        motherShipNode.physicsBody!.affectedByGravity = false
        motherShipNode.physicsBody!.categoryBitMask = Config.BitMaskCategory.MotherShip
        motherShipNode.physicsBody!.contactTestBitMask = Config.BitMaskCategory.Resource
        motherShipNode.physicsBody!.collisionBitMask = 0x0
        
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
        
        // Add the peripheral boundary node to the greater scene
        ObjectManager.sharedInstance.addNode(node: peripheralNode)
        
        // Setup the boundary reference for this mother ship
        setBoundary(origin: peripheralNode, distance: Config.MotherShipBoundaryLength)
        
        // Setup the touch control node
        touchNode = SKShapeNode(circleOfRadius: self.radius)
        touchNode!.name = self.name! + ".Touch"
        setupTouchNode()
        
        baseNode.addChild(touchNode!)
        
        // Setup the energy monitor
        energyLabel.text = "Energy: \(energy)"
        energyLabel.horizontalAlignmentMode = .left
        energyLabel.fontSize = 20
        energyLabel.position = CGPoint(x: -energyLabel.frame.maxX / 2, y: radius * 1.6)
        energyLabel.fontColor = SKColor.white
        
        baseNode.addChild(energyLabel)
        
        // Set the node's position and heading
        updateNode()
        
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
        stateMachine!.changeState(newState: MotherShipIdleState.sharedInstance)
        
        // Spawn 4 fighter ships off the start
        for _ in 0..<Config.MotherShipInitialSpawn {
            spawnFighterShip()
        }
        
        print("Initialized \(self.name!) on team \(self.team)")
    }
    
    // Spawn a fighter ship
    func spawnFighterShip(direction: Vector? = nil) {
        // Aim it at the closest enemy if they exist
        var spawnHeading: Vector?
        if let closest = closestEnemy() {
            spawnHeading = (closest.position - position).normalize()
        }
        
        let spawnToward = direction ?? spawnHeading ?? Vector(degrees: CGFloat.random(in: 0...360))
        let fighterShip = FighterShip(position: position, heading: spawnToward, team: team)
        fighterShip.setBoundary(origin: boundaryOrigin!, distance: Config.MotherShipBoundaryLength)
        fighterShip.userControlled = self.userControlled
        
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
        // Check if contacted with a resource
        else if let _ = object as? Resource {
            // Collect the resource
            energy += 25
        }
    }
    
    // A ship enters the peripheral range of this fighter ship
    override func objectInPeripheralRange(_ object: BaseObject?) {
        if let motherShip = object as? MotherShip {
            // Add the new spotted ship to the list
            if let name = motherShip.name {
                print("\(self.name!) sees \(name)")
                objectsInPeripheral[name] = motherShip
                
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
                
                // Move the boundary since a new mothership is in the fray
                moveBoundary()
            }
        }
    }
    
    // Get the closest enemy mothership in range
    func closestEnemy() -> MotherShip? {
        var closest: MotherShip?
        
        // Look for the closest mothership
        for (_, objInPeripheral) in self.objectsInPeripheral {
            if let motherShip = objInPeripheral as? MotherShip {
                if motherShip.isActive {
                    if closest == nil {
                        closest = motherShip
                    }
                    else {
                        if((closest!.position - position).length() > (motherShip.position - position).length()) {
                            closest = motherShip
                        }
                    }
                }
            }
        }
        
        return closest
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
        let moveAction = SKAction.move(to: CGPoint(x: newX, y: newY), duration: 0.5)
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
            }
        }
        
        // Update the boundary position
        moveBoundary()
        
        // Update the energy label
        energyLabel.text = "Energy: \(energy)"
        
        // Update the mothership with the current state
        stateMachine?.update(dTime: dTime)
        
        return true
    }
    
    override func inputTouchDown(touchPos: CGPoint) -> Bool {
        if userControlled {
            // Pause the game while user actions are taking place
            ObjectManager.sharedInstance.pause()
            
            // End the path
            releasePathNode()
            
            // Setup the line node
            line = SKShapeNode()
            path = CGMutablePath()
            line!.strokeColor = .lightGray
            line!.alpha = 0.5
            line!.lineWidth = 4
            
            // Start drawing the line if necessary
            if position.distanceBetween(vector: Vector(touchPos)) > radius * 1.25 {
                drawPath(pos: touchPos)
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
            if position.distanceBetween(vector: Vector(touchPos)) > radius * 1.25 {
                drawPath(pos: touchPos)
                points.append(touchPos)
            }
            
            return true
        }
        
        return false
    }
    
    override func inputTouchUp(touchPos: CGPoint) -> Bool {
        if userControlled && ObjectManager.sharedInstance.activeObject == self {
            // Unpause the game, as the move action is completed
            ObjectManager.sharedInstance.unpause()
            
            // Setup the steering behavior with the path array
            steeringBehavior!.setToFollowPath(path: points.reversed(), accuracy: 1.25)
            points.removeAll()
            
            // Change into the moving state
            stateMachine?.changeState(newState: MotherShipMoveState.sharedInstance)
            
            // Release self as active object
            ObjectManager.sharedInstance.activeObject = nil
            
            return true
        }
        
        return false
    }
    
    override func destroy() {
        if isActive {
            peripheralNode.removeFromParent()
            releasePathNode()
            
            // Remove the boundary for all of these fighter ships so they can be free
            for fighterShip in fighterShips {
                fighterShip.removeBoundary()
            }
        }
        
        super.destroy()
    }
}
