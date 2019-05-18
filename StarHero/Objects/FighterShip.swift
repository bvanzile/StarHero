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
    
    // Initialize the fighter ship
    init(position: CGPoint?, heading: CGFloat = 0.0, team: Int = Config.Team.NoTeam) {
        super.init()
        
        // Update the position if default is given - unwrap
        if let pos = position {
            self.position.x = pos.x
            self.position.y = pos.y
        }
        
        // Set the node's position by default or through initializer
        self.fighterShipNode.position = Conversions.sharedInstance.coordToCGPoint(x: self.position.x, y: self.position.y)
        
        // Capture the initial heading direction
        self.heading = heading
        self.fighterShipNode.zRotation = self.heading
        
        // Capture the team this ship belongs to
        self.team = team
        
        //Set the team color
        self.fighterShipNode.color = self.getTeamColor()
        self.fighterShipNode.colorBlendFactor = 1
        
        // Set the name for this instance and for the sprite node
        self.name = getUniqueName()
        self.fighterShipNode.name = self.name
        
        print("Init fighter ship: \(self.fighterShipNode)")
    }
    
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
        self.fighterShipNode.removeFromParent()
    }
    
    // Update function, return true if update successful, return false if this object is ready to be terminated
    override func update() -> Bool {
        // If superclass indicates deletion, return false
        if !super.update() || !self.isActive {
            return false
        }
        
        self.position.y += 0.2
        self.fighterShipNode.position = Conversions.sharedInstance.coordToCGPoint(x: self.position.x, y: self.position.y)
        
        return true
    }
    
    // Get a unique name for a fighter ship
    override func getUniqueName() -> String {
        BaseObject.uniqueIdentifier += 1
        return "FighterShip\(BaseObject.uniqueIdentifier)"
    }
    
    // Return the sprite to be rendered
    func getNode() -> SKSpriteNode? {
        print("Entering get node")
        return self.fighterShipNode
    }
}
