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
    // Name of this type of object
    static let objectType: String = "FighterShip"
    
    // Sprite for fighter ships
    private let fighterShipNode = SKSpriteNode(imageNamed: Config.FighterShipLocation)
    
    // The fighter ship state machine
    private var stateMachine: StateMachine?
    
    // Initialize the fighter ship
    override init(position: CGPoint?, heading: CGFloat = 0.0, team: Int = Config.Team.NoTeam) {
        super.init(position: position, heading: heading, team: team)
        
        // Set the node's position and heading
        self.fighterShipNode.position = coordToCGPoint(x: self.position.x, y: self.position.y)
        self.fighterShipNode.zRotation = ConvertHeadingToSpriteRotation(heading: self.heading)
        
        // Overwrite with config velocity for a fighter ship
        self.velocity = Config.FighterShipVelocity
        
        //Set the team color
        self.fighterShipNode.color = Config.getTeamColor(team: self.team)
        self.fighterShipNode.colorBlendFactor = 1
        
        // Set the name for this instance and for the sprite node
        self.name = getUniqueName(objectType: FighterShip.objectType)
        self.fighterShipNode.name = self.name
        
        // Initialize the state machine
        stateMachine = StateMachine(object: self, currentState: FighterShipWanderState.sharedInstance, previousState: FighterShipWanderState.sharedInstance)
        stateMachine?.changeState(newState: FighterShipWanderState.sharedInstance)
        
        print("Initialized \(self.name!)")
    }
    
    // Setup this fighter ship's sprite node and return it to the scene to be added
    override func addToScene() -> SKSpriteNode? {
        // If fighter ship is already active, node dosent need to be added to scene
        if self.isActive {
            return nil
        }
        
        // Activate the node and pass it back to be added to the scene
        self.isActive = true
        return fighterShipNode
    }
    
    // Destroy this fighter ship
    override func destroy() {
        print("Destroying \(name!)")
        self.fighterShipNode.removeFromParent()
    }
    
    // Update function, return true if update successful, return false if this object is ready to be terminated
    override func update() -> Bool {
        // If superclass indicates deletion, return false
        if !super.update() || !self.isActive {
            return false
        }
        
        stateMachine?.update()
        
        return true
    }
    
    override func travelOnPath() {
        super.travelOnPath()
        self.fighterShipNode.position = coordToCGPoint(x: self.position.x, y: self.position.y)
    }
    
    override func handleInput(touchPos: CGPoint) {
        self.heading = GetDirection(firstPoint: CGPoint(x: self.position.x, y: self.position.y), secondPoint: touchPos)
        self.fighterShipNode.zRotation = ConvertHeadingToSpriteRotation(heading: self.heading)
    }
    
    // Get the object's state machine
    override func getStateMachine() -> StateMachine? {
        return stateMachine
    }
}
