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
    var objectsToAvoid: [String : MovingObject] = [String : MovingObject]()
    
    // Physics properties
    var mass: CGFloat = 0.0
    var takeoffSpeed: CGFloat = 0.0
    var maxSpeed: CGFloat = 0.0
    var maxForce: CGFloat = 0.0
    var deceleration: CGFloat = 0.0
    
    // Boundary properties
    var boundaryOrigin: SKShapeNode? = nil
    var boundaryDistance: CGFloat? = nil
    
    // Initializer
    override init(position: Vector? = nil, heading: Vector? = nil, team: Int = Config.Team.NoTeam, userControlled: Bool = false) {
        super.init(position: position, heading: heading, team: team, userControlled: userControlled)
        
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
            side = heading.right()
        }
    }
    
    // Update the node with the current heading and position
    func updateNode(ignoreHeading: Bool = false) {
        // Simply apply the position to the node
        getNode().position = CGPoint(x: position.x, y: position.y)
        
        // Convert from x,y coordinates that start at the right to one that starts at the top
        if !ignoreHeading {
            getNode().zRotation = heading.toRads() - degreesToRads(degrees: 90)
        }
    }
    
    // Setup the boundary for this object
    func setBoundary(origin: SKShapeNode, distance: CGFloat) {
        boundaryOrigin = origin
        boundaryDistance = distance
    }
    
    // Remove the boundary for this object
    func removeBoundary() {
        boundaryOrigin = nil
        boundaryDistance = nil
    }
    
    // Check whether this object is within the boundaries
    func isOutOfBounds(scale: CGFloat = 1.0) -> Bool {
        // Check if the ship has moved out of bounds and change the state to return
        //if((position.x * position.x) > ((Config.FieldWidth / 2) * (Config.FieldWidth / 2) * scale) || (position.y * position.y) > ((Config.FieldHeight / 2) * (Config.FieldHeight / 2)) * scale) {
        if let origin = boundaryOrigin, let distance = boundaryDistance {
            if (position - Vector(origin.position)).length() > distance {
                return true
            }
        }
        else if position.x > Config.MaxFieldWidth * 0.6 || position.x < -Config.MaxFieldWidth * 0.6 {
            return true
        }
        else if position.y > Config.MaxFieldHeight * 0.6 || position.y < -Config.MaxFieldHeight * 0.6 {
            return true
        }
        
        return false
    }
}
