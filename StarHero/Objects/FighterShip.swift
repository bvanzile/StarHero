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
    
    // Sprite
    private let fighterShipNode = SKSpriteNode(imageNamed: Config.FighterShipLocation)
    private var position: Position = Position()
    
    // Initialize the fighter ship
    init(position: CGPoint?) {
        // Update the position if default is given
        if let pos = position {
            self.position.x = pos.x
            self.position.y = pos.y
        }
        
        self.fighterShipNode.position = Conversions.sharedInstance.coordToCGPoint(x: self.position.x, y: self.position.y)
        
        super.init()
        print("Init fighter ship")
    }
    
    override func addToScene() -> SKSpriteNode? {
        // Fighter ship is already active, node dosent need to be added to scene
        if self.isActive {
            return nil
        }
        
        self.isActive = true
        return fighterShipNode
    }
    
    // Destroy this fighter ship
//    func tearDown() {
//        self.fighterShipSprite.removeFromParent()
//    }
    
    // Update function
    override func update() {
        self.position.y += 0.2
        self.fighterShipNode.position = Conversions.sharedInstance.coordToCGPoint(x: self.position.x, y: self.position.y)
        
        super.update()
        print("FighterShip updating")
    }
    
    // Return the sprite to be rendered
    func getNode() -> SKSpriteNode? {
        print("Entering get node")
        return self.fighterShipNode
    }
}
