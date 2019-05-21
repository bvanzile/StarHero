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
    var isActive: Bool = false {
        didSet {
            // If this object is turned to inactive, it should be destroyed
            if !isActive {
                // Should call the destroy class of the object sub class to remove the node from the scene
                destroy()
            }
        }
    }
    
    // Unique name of this object, also used for the node
    var name: String? = nil
    static var uniqueIdentifier: CUnsignedLong = 0
    
    // Team this object belongs to
    var team: Int = Config.Team.NoTeam
    
    // Position (x, y) and the direction this object is facing in clockwise degrees
    var position: Vector = Vector()
    var heading: CGFloat = 0.0
    
    // Default initializer
    init(position: CGPoint?, heading: CGFloat = 0.0, team: Int = Config.Team.NoTeam) {
        // Update the position if default is given - unwrap
        if let pos = position {
            self.position.x = pos.x
            self.position.y = pos.y
        }
        
        // Capture the initial heading direction
        self.heading = heading
        
        // Capture the team this ship belongs to
        self.team = team
    }
    
    
    // Get a unique name for the object, this method should always be overwritten
    internal func getUniqueName(objectType: String) -> String {
        // Increment the unique identifier and return it
        BaseObject.uniqueIdentifier = BaseObject.uniqueIdentifier + 1
        return "\(objectType)\(BaseObject.uniqueIdentifier)"
    }
    
    ///////
    /////// STUBS FOR ALL OBJECT SUB CLASS TO INHERIT
    ///////
    func addToScene() -> SKNode? { return nil }             // Call from the game scene to add the SKNode to the screen
    func update() -> Bool { return true }                   // Update the object
    func destroy() { }                                      // Remove the node from the screen
    func handleInput(touchPos: CGPoint) { }                 // Handle input from the game screen
    func getStateMachine() -> StateMachine? { return nil }  // Return the state machine for this object if it exists
}
