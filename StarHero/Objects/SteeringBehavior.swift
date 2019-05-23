//
//  SteeringBehavior.swift
//  StarHero
//
//  Created by Bryan Van Zile on 5/21/19.
//  Copyright © 2019 Bryan Van Zile. All rights reserved.
//

import Foundation
import SpriteKit

enum SteeringBehaviors {
    case Seek
    case Arrive
    case Flee
    case Wander
    case Idle
}

class SteeringBehavior {
    // The vehicle that is using this steering behavior
    var movingObject: MovingObject
    
    // The current active steering behavior
    var activeSteeringBehavior: SteeringBehaviors = SteeringBehaviors.Idle
    
    // Target vector
    var targetPosition: Vector = Vector()
    
    // Constants used for wandering behavior
    var wanderCircle: Vector = Vector()
    let wanderJitter: CGFloat = 2.0
    let wanderRadius: CGFloat = 20.0
    let wanderDistance: CGFloat = 0.0
    
    // Initializer
    init(object: MovingObject) {
        self.movingObject = object
    }
    
    // Set the current behavior
    func setToIdle() { activeSteeringBehavior = SteeringBehaviors.Idle }
    func setToSeek(target: Vector) {
        activeSteeringBehavior = SteeringBehaviors.Seek
        targetPosition = target
    }
    func setToArrive(target: Vector) {
        activeSteeringBehavior = SteeringBehaviors.Arrive
        targetPosition = target
    }
    func setToFlee(target: Vector) {
        activeSteeringBehavior = SteeringBehaviors.Flee
        targetPosition = target
    }
    func setToWander() {
        activeSteeringBehavior = SteeringBehaviors.Wander
        wanderCircle = movingObject.heading * wanderRadius
        targetPosition = wanderCircle + movingObject.position
    }
    
    // Function for getting the steering force
    func calculateSteeringForce() -> Vector {        
        var desiredVelocity = Vector()
        
        // Get the desired velocity based on the active steering behavior
        switch activeSteeringBehavior {
        case .Seek:
            // Calculate the desired velocity
            desiredVelocity = seek(target: targetPosition)
            
        case .Arrive:
            desiredVelocity = arrive(target: targetPosition)
            
            // Return a 0 velocity if arrived
            if(desiredVelocity.length() == 0) {
                return desiredVelocity
            }
            
        case .Flee:
            break
            
        case .Wander:
            desiredVelocity = wander()
            
        case .Idle: // .Idle
            return desiredVelocity
        }
        
        // Need to adjust the steering force if the desired velocity is behind the object so it turns smoothly
        if(movingObject.velocity.dotProductDegrees(vector: desiredVelocity) > 90) {
            if(movingObject.heading.perpendicularRight().dotProductDegrees(vector: desiredVelocity) > 90)
            {
                // Turn straight left
                desiredVelocity = movingObject.heading.perpendicularLeft() * desiredVelocity.length()
            }
            else {
                // Turn straight right
                desiredVelocity = movingObject.heading.perpendicularRight() * desiredVelocity.length()
            }
        }
        
        // Return the steering force vector
        return (desiredVelocity - movingObject.velocity).truncate(value: movingObject.maxForce)
    }

    private func seek(target: Vector) -> Vector {
        return (target - movingObject.position).normalize() * movingObject.maxSpeed
    }
    
    private func arrive(target: Vector) -> Vector {
        // Get the distance to the target
        let vectorToTarget = target - movingObject.position
        let distance = vectorToTarget.length()
        
        // Check if we aren't there yet
        if(distance > (movingObject.radius / 10)) {
            // Calculate speed given the desired deceleration rate
            var speed = distance / Config.FighterShipDeceleration
            
            // Make sure we aren't moving faster than the max speed
            speed = speed < movingObject.maxSpeed ? speed : movingObject.maxSpeed
            
            // Update the velocity
            return vectorToTarget * (speed / distance)
        }
        else {
            // Distance is close enough that we have arrived at the destination
            return Vector()
        }
    }
    
    private func wander() -> Vector {
        // Add some randomness to the target circle radius
        wanderCircle = (wanderCircle + Vector(x: CGFloat.random(in: -1..<1) * wanderJitter, y: CGFloat.random(in: -1..<1) * wanderJitter)).normalize() * wanderRadius
        
        // Project the wander circle in front of the moving object
        targetPosition = movingObject.position + ((movingObject.heading * wanderDistance) + wanderCircle)
        
        // Return a desired velocity where we seek the position on the wander circle
        return seek(target: targetPosition)
    }
}
