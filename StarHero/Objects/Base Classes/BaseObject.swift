//
//  BaseObject.swift
//  StarHero
//
//  Created by Bryan Van Zile on 5/17/19.
//  Copyright © 2019 Bryan Van Zile. All rights reserved.
//

import Foundation
import SpriteKit

class BaseObject: Equatable {
    // State of the object
    var isActive: Bool = false
    
    // Base node that represents this object
    var baseNode: SKNode = SKNode()
    
    // Unique name of this object, also used for the node
    var name: String? = nil
    static var uniqueIdentifier: CUnsignedLong = 0
    
    // Team this object belongs to
    var team: Int = Config.Team.NoTeam
    var attackable: Bool = false
    
    // User controls
    var userControlled: Bool = false
    
    // Position (x, y) and the direction this object is facing in clockwise degrees
    var position: Vector = Vector()
    var heading: Vector = Vector(x: 1.0, y: 0.0)
    var side: Vector = Vector(x: 0.0, y: -1.0)
    var radius: CGFloat = 0.0
    
    // Default initializer
    init(position: Vector? = nil, heading: Vector? = nil, team: Int = Config.Team.NoTeam, userControlled: Bool = false) {
        // Update the position if default is given - unwrap
        if let pos = position {
            self.position = pos
        }
        
        // Update the heading if default is given - unwrap
        if let head = heading {
            self.heading = head
        }
        
        // Capture the initial heading direction
        side = self.heading.right()

        // Capture the team this object belongs to
        if(team == Config.Team.RandomTeam) {
            self.team = Config.Team.getRandomTeam()
        }
        else {
            self.team = team
        }
        
        // Set user controlled flag
        self.userControlled = userControlled
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
    
    // Destroy this object
    func destroy() {
        if isActive {
            isActive = false
            self.getNode().removeFromParent()
            //print("Destroying: \(self.name!)")
        }
    }
    
    // Explode when destroyed
    func explode(sizeScale: CGFloat = 1.0, duration: Double = 0.7, force: Vector = Vector(), forceFactor: CGFloat = 2.5) {
        // Create an explosion where the ship was destroyed
        ObjectManager.sharedInstance.addObject(object: Explosion(position: self.position, size: self.radius * 2 * sizeScale, duration: duration, force: force * self.radius * forceFactor))
    }
    
    ///////
    /////// Stub classes for base classes to inherit if needed
    ///////
    func getNode() -> SKNode { return baseNode }
    func update(dTime: TimeInterval) -> Bool { return false }       // Update the object
    func handleCollision(_ object: BaseObject?) { }                 // Handle a collision with the passed through object
    func handleStopColliding(_ object: BaseObject?) { }             // Handle when a collision ends
    func seeObject(_ object: BaseObject?) { }                       // Handle collision of sight box with an object
    func loseSightOnObject(_ object: BaseObject?) { }               // Handle losing collision on sight box with an object
    func objectInPeripheralRange(_ object: BaseObject?) { }         // Handle collision of peripheral sight box contacting with an object
    func objectOutOfPeripheralRange(_ object: BaseObject?) { }      // Handle losing collision of peripheral sight box with an object
    func inputTouchDown(touchPos: CGPoint) -> Bool { return false } // Handle the different inputs from the game screen
    func inputTouchUp(touchPos: CGPoint) -> Bool { return false }   // Handle the different inputs from the game screen
    func inputTouchMoved(touchPos: CGPoint) -> Bool { return false }// Handle the different inputs from the game screen
    
    // Compare two base objects to see if they are the same
    static func == (lhs: BaseObject, rhs: BaseObject) -> Bool {
        let leftName = lhs.name
        let rightName = rhs.name
        
        // Make sure the names are valid
        if leftName != nil && rightName != nil {
            // Return whether or not these names are the same
            return leftName == rightName
        }
        return false
    }
}
