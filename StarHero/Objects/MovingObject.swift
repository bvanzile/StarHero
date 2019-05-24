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
    var deceleration: CGFloat = 0.0
    
    // Initializer
    override init(position: Vector? = nil, heading: Vector? = nil, team: Int = Config.Team.NoTeam) {
        super.init(position: position, heading: heading, team: team)
        
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
        // Simply apply the position to the node
        self.getNode()?.position = CGPoint(x: position.x, y: position.y)
        
        // Convert from x,y coordinates that start at the right to one that starts at the top
        self.getNode()?.zRotation = heading.toRads() - degreesToRads(degrees: 90)
    }
    
    // Check whether this object is within the boundaries
    func isOutOfBounds(scale: CGFloat = 1.0) -> Bool {
        // Check if the ship has moved out of bounds and change the state to return
        if((position.x * position.x) > ((Config.FieldWidth / 2) * (Config.FieldWidth / 2) * scale) || (position.y * position.y) > ((Config.FieldHeight / 2) * (Config.FieldHeight / 2)) * scale) {
            return true
        }
        return false
    }
}
