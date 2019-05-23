//
//  MovingObject.swift
//  StarHero
//
//  Created by Bryan Van Zile on 5/17/19.
//  Copyright © 2019 Bryan Van Zile. All rights reserved.
//

import Foundation
import SpriteKit

class MovingObject: BaseObject, VectorMath {
    
    // Things an object needs to move around
    var velocity: Vector = Vector()
    
    // Steering object
    var steeringBehavior: SteeringBehavior? = nil
    
    // Physics properties
    var mass: CGFloat = 0.0
    var takeoffSpeed: CGFloat = 0.0
    var maxSpeed: CGFloat = 0.0
    var maxForce: CGFloat = 0.0
    
    // Initializer
    override init(position: CGPoint?, facingDegrees: CGFloat = 0.0, team: Int = Config.Team.NoTeam) {
        super.init(position: position, facingDegrees: facingDegrees, team: team)
        
        steeringBehavior = SteeringBehavior(object: self)
    }
    
    // Make this object move towards where it wants to go
    func updateVelocity(timeElapsed: TimeInterval) {
        // Get the steering force
        let steeringForce = steeringBehavior!.calculateSteeringForce()
        
        // Apply acceleration and make sure we don't exceed max speed
        velocity = velocity + (steeringForce / mass).truncate(value: maxSpeed)
    }
    
    // Update this objects position based on the current velocity
    func updatePosition(timeElapsed: TimeInterval) {
        // Capture the current velocity and update the position
        position = position + (velocity * CGFloat(timeElapsed))
        
        // Update the heading based on the current velocity
        if(velocity.length() > 0) {
            heading = velocity.normalize()
            side = heading.perpendicularRight()
        }
        else {
            print("Zero velocity")
        }
    }
    
    // Update the node with the current heading and position
    func updateNode() {
        fatalError("Update node must be overwritten by base class that owns a node")
    }
    
    // Check whether this object is within the boundaries
    func isOutOfBounds() -> Bool {
        // Check if the ship has moved out of bounds and change the state to return
        if((position.x * position.x) > ((Config.FieldWidth / 2) * (Config.FieldWidth / 2)) || (position.y * position.y) > ((Config.FieldHeight / 2) * (Config.FieldHeight / 2))) {
            return true
        }
        return false
    }
}
