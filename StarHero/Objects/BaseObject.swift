//
//  BaseObject.swift
//  StarHero
//
//  Created by Bryan Van Zile on 5/17/19.
//  Copyright © 2019 Bryan Van Zile. All rights reserved.
//

import Foundation
import SpriteKit

class BaseObject {
    // State of the object
    var isActive: Bool = false
    
    // Unique name of this object, also used for the node
    var name: String? = nil
    static var uniqueIdentifier: CUnsignedLong = 0
    
    // Team this object belongs to
    var team: Int = Config.Team.NoTeam
    
    // Position (x, y) and the direction this object is facing in clockwise degrees
    var position: Vector = Vector()
    var heading: Vector = Vector(x: 1.0, y: 0.0)
    var side: Vector = Vector(x: 0.0, y: -1.0)
    var radius: CGFloat = 0.0
    
    // Default initializer
    init(position: Vector? = nil, heading: Vector? = nil, team: Int = Config.Team.NoTeam) {
        // Update the position if default is given - unwrap
        if let pos = position {
            self.position = pos
        }
        
        // Update the heading if default is given - unwrap
        if let head = heading {
            self.heading = head
        }
        
        // Capture the initial heading direction
        side = self.heading.perpendicularRight()

        // Capture the team this object belongs to
        if(team == Config.Team.RandomTeam) {
            self.team = Int.random(in: 0...4)
        }
        else {
            self.team = team
        }
    }
    
    // Get a unique name for the object, this method should always be overwritten
    func getUniqueName() -> String {
        // Increment the unique identifier and return it
        BaseObject.uniqueIdentifier = BaseObject.uniqueIdentifier + 1
        return "\(String(describing: type(of: self)))\(BaseObject.uniqueIdentifier)"
    }
    
    // Setup this fighter ship's sprite node and return it to the scene to be added
    func addToScene() -> SKNode? {
        // If fighter ship is already active, node dosent need to be added to scene
        if isActive {
            return nil
        }
        
        // Activate the node and pass it back to be added to the scene
        isActive = true
        return self.getNode()
    }
    
    // Destroy this fighter ship
    func destroy() {
        if isActive {
            isActive = false
            self.getNode()?.removeFromParent()
            //print("Destroying: \(self.name!)")
        }
    }
    
    ///////
    /////// STUBS FOR ALL OBJECT SUB CLASS TO INHERIT
    ///////
    func getNode() -> SKNode? { return nil }
    func update(dTime: TimeInterval) -> Bool { return false }   // Update the object
    func handleCollision(_ object: BaseObject?) { }             // Handle a collision with the passed through object
    func seeObject(_ object: BaseObject?) { }                   // Handle collision of vision box with an object
    func inputTouchDown(touchPos: CGPoint) { }                  // Handle the different inputs from the game screen
    func inputTouchUp(touchPos: CGPoint) { }                    // Handle the different inputs from the game screen
    func inputTouchMoved(touchPos: CGPoint) { }                 // Handle the different inputs from the game screen
}
