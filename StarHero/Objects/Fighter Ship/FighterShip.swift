//
//  FighterShip.swift
//  StarHero
//
//  Created by Bryan Van Zile on 5/17/19.
//  Copyright © 2019 Bryan Van Zile. All rights reserved.
//

import Foundation
import SpriteKit

class FighterShip: MovingObject {
    // Sprite for fighter ships
    private let fighterShipNode = SKSpriteNode(imageNamed: Config.FighterShipLocation)
    
    // The fighter ship state machine
    var stateMachine: StateMachine?
    
    // Initialize the fighter ship
    override init(position: CGPoint?, facingDegrees: CGFloat = 0.0, team: Int = Config.Team.NoTeam) {
        super.init(position: position, facingDegrees: facingDegrees, team: team)
        
        // Overwrite with config velocity for a fighter ship
        mass = Config.FighterShipMass
        maxSpeed = Config.FighterShipMaxSpeed
        takeoffSpeed = Config.FighterShipTakeoffSpeed
        maxForce = Config.FighterShipMaxForce
        
        // Set the node's position and heading
        self.updateNode()
        
        // Grab the size of the node
        radius = (fighterShipNode.size.width + fighterShipNode.size.height) / 4
        
        //Set the team color
        fighterShipNode.scale(to: CGSize(width: 30, height: 60))
        fighterShipNode.color = Config.getTeamColor(team: self.team)
        fighterShipNode.colorBlendFactor = 1
        
        // Set the name for this instance and for the sprite node
        name = getUniqueName()
        fighterShipNode.name = name
        
        // Initialize the state machine
        stateMachine = StateMachine(object: self)
        stateMachine?.changeState(newState: FighterShipWanderState.sharedInstance)
        
        print("Initialized \(self.name!)")
    }
    
    // Setup this fighter ship's sprite node and return it to the scene to be added
    override func addToScene() -> SKSpriteNode? {
        // If fighter ship is already active, node dosent need to be added to scene
        if isActive {
            return nil
        }
        
        // Activate the node and pass it back to be added to the scene
        isActive = true
        return fighterShipNode
    }
    
    // Destroy this fighter ship
    override func destroy() {
        fighterShipNode.removeFromParent()
    }
    
    // Update function, return true if update successful, return false if this object is ready to be terminated
    override func update(dTime: TimeInterval) -> Bool {
        // If superclass indicates deletion, return false
        if !isActive {
            return false
        }
        
        // Update the fighter ship with the current state
        stateMachine?.update(dTime: dTime)
        
        return true
    }
    
    override func inputTouchDown(touchPos: CGPoint) {
        // Setup the steering behavior and then change the state to seek
        self.steeringBehavior!.setToSeek(target: Vector(point: touchPos))
        stateMachine?.changeState(newState: FighterShipMoveState.sharedInstance)
    }
    
    // Update the node with the current heading and position
    override func updateNode() {
        // Simply apply the position to the node
        fighterShipNode.position = CGPoint(x: position.x, y: position.y)
        
        // Convert from x,y coordinates that start at the right to one that starts at the top
        fighterShipNode.zRotation = heading.toRads() - degreesToRads(degrees: 90)
    }
}
